//
//  MLSet.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import SwiftUI
import UniformTypeIdentifiers
import Vision

extension UTType {
    static let mlSetDocument = UTType(exportedAs: "com.martincastro.ML-Label.mlset")
}

/// A reference-based file document that contains data on images, classes, and annotations.
class MLSet: ReferenceFileDocument, Codable, Hashable, ObservableObject, DropDelegate {
    
    // ReferenceFileDocument uses Snapshot for safe background writing.
    typealias Snapshot = Data
    
    static var readableContentTypes: [UTType] = [.mlSetDocument]

    @Published var imageSources: [MLImageSource]
    @Published var classes: [MLClass]
    
    // Track starting coordinates for ongoing edits
    private var editStartCoordinates: [UUID: MLCoordinates] = [:]
    
    let id: UUID
    
    init() {
        self.id = UUID()
        self.imageSources = []
        self.classes = []
    }
    
    // ReferenceFileDocument Conformance: Read
    required init(configuration: ReadConfiguration) throws {
        let data = configuration.file.regularFileContents!
        let decodedJSONData = try PropertyListDecoder().decode(MLSet.self, from: data)
        self.id = decodedJSONData.id
        self.imageSources = decodedJSONData.imageSources
        self.classes = decodedJSONData.classes
    }
    
    // ReferenceFileDocument Conformance: Snapshot
    func snapshot(contentType: UTType) throws -> Data {
        return try PropertyListEncoder().encode(self)
    }
    
    // ReferenceFileDocument Conformance: Write
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        return FileWrapper(regularFileWithContents: snapshot)
    }
    
    // Decodable Conformance
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.imageSources = try container.decode([MLImageSource].self, forKey: .imageSources)
        self.classes = try container.decode([MLClass].self, forKey: .classes)
    }
    
    func update() {
        objectWillChange.send()
    }
    
    // MARK: - Image / DropDelegate Conformance

    func performDrop(info: DropInfo) -> Bool {
        
        guard info.hasItemsConforming(to: [.fileURL]) else {
            return false
        }
        let imageDropData = info.itemProviders(for: [.fileURL])
        
        for image in imageDropData {
                
            // Loads data from fileURL drop and creates an instance of imageData for each image.
            image.loadDataRepresentation(forTypeIdentifier: "public.file-url") { data, error in
                DispatchQueue.main.async {
                    if let imageData = data {
                        if let imagePathString = NSString(data: imageData, encoding: 4){
                            if let imageURL = URL(string: imagePathString as String){
                                if #available(macOS 13.0, *) {
                                    self.addImageFromURL(url: imageURL)
                                } else {
                                    // Supports macOS 14+
                                }
                            }
                        }
                    }
                }
            }
        }
        return true
    }
    
    @available(macOS 13.0, *)
    func addImageFromURL(url: URL, undoManager: UndoManager? = nil) {
        if NSImage(contentsOf: url) != nil {
            
            let mlImage = MLImage(fileURL: url)
            let folderPath = url.deletingLastPathComponent().path(percentEncoded: false)
            
            // Do not append images with same file name
            if allImages().contains(where: {$0.name == mlImage.name}){return}
            
            // Register Undo
            undoManager?.registerUndo(withTarget: self) { target in
                target.deleteImage(mlImage, undoManager: undoManager)
            }
            
            if imageSources.contains(where: {$0.folderPath == folderPath}) {
                // Add to an existing MLImageSource
                let imageSource = imageSources.first(where: {$0.folderPath == folderPath})!
                imageSource.images.append(mlImage)
                
            }else{
                // Create new MLImageSource and add image
                let newSource = MLImageSource(folderURL: url.deletingLastPathComponent())
                newSource.images.append(mlImage)
                imageSources.append(newSource)
            }
            update()
        }
    }
    
    func allImages() -> [MLImage] {
        return imageSources.flatMap({ $0.images})
    }
    
    func deleteImage(_ image: MLImage, undoManager: UndoManager? = nil) {
        // Capture context for undo restoration
        var sourceWithImage: (MLImageSource, Int)? = nil
        for source in imageSources {
            if let idx = source.images.firstIndex(where: { $0.id == image.id }) {
                sourceWithImage = (source, idx)
                break
            }
        }
        
        var classInstances: [UUID: [MLBoundingBox]] = [:]
        for mlClass in classes {
            if let boxes = mlClass.instances[image] {
                classInstances[mlClass.id] = boxes
            }
        }
        
        // Register Undo
        undoManager?.registerUndo(withTarget: self) { target in
            if let (source, index) = sourceWithImage {
                if index <= source.images.count {
                    source.images.insert(image, at: index)
                } else {
                    source.images.append(image)
                }
            }
            
            for mlClass in target.classes {
                if let boxes = classInstances[mlClass.id] {
                    mlClass.instances[image] = boxes
                }
            }
            target.update()
            
            // Register Redo
            undoManager?.registerUndo(withTarget: target) { target in
                target.deleteImage(image, undoManager: undoManager)
            }
        }
        
        for source in imageSources {
            source.images.removeAll(where: {$0.id == image.id})
        }
        // Remove from Sources
        for source in imageSources {
            source.removeImage(id: image.id)
        }
        // Remove from classes
        for mlClass in classes {
            mlClass.instances.removeValue(forKey: image)
        }
        update()
    }
    
    func percentAnnotated() -> Float {
        let imageCount: Int = allImages().count
        if imageCount == 0 { return 0 }
        var annotatedCount: Int = 0
        for image in allImages() {
            if !image.annotations.isEmpty {
                annotatedCount += 1
            }
        }
        return Float(annotatedCount) / Float(allImages().count) * 100
    }
    
    // MARK: - Annotation Operations with Undo Support
    
    func addAnnotationFromNormalizedRect(_ normalizedRect: CGRect, to image: MLImage, label: String, undoManager: UndoManager? = nil) {
        let pixelRect = VNImageRectForNormalizedRect(normalizedRect, image.width, image.height)
        let imageBounds = CGRect(x: 0, y: 0, width: CGFloat(image.width), height: CGFloat(image.height))
        
        let clampedRect = pixelRect.intersection(imageBounds)
        guard !clampedRect.isNull, !clampedRect.isEmpty else { return }
        
        let mlCoordinates = MLCoordinates(
            x: Int(clampedRect.midX),
            y: Int(clampedRect.midY),
            width: Int(clampedRect.width),
            height: Int(clampedRect.height)
        )
        
        let boundingBox = MLBoundingBox(label: label, coordinates: mlCoordinates)
        addAnnotationFromBoundingBox(boundingBox, to: image, undoManager: undoManager)
    }
    
    func addAnnotationFromBoundingBox(_ boundingBox: MLBoundingBox, to image: MLImage, undoManager: UndoManager? = nil) {
        // Register Undo
        undoManager?.registerUndo(withTarget: self) { target in
            target.removeAnnotation(boundingBox, from: image, undoManager: undoManager)
        }
        
        image.annotations.append(boundingBox)
        if let mlClass = classes.first(where: { $0.label == boundingBox.label }) {
            mlClass.addInstance(mlImage: image, boundingBox: boundingBox)
        }
        image.update()
        update()
    }
    
    func removeAnnotation(_ boundingBox: MLBoundingBox, from image: MLImage, undoManager: UndoManager? = nil) {
        // Register Undo
        undoManager?.registerUndo(withTarget: self) { target in
            target.addAnnotationFromBoundingBox(boundingBox, to: image, undoManager: undoManager)
        }
        
        image.annotations.removeAll(where: { $0.id == boundingBox.id })
        if let mlClass = classes.first(where: { $0.label == boundingBox.label }) {
            mlClass.removeInstance(mlImage: image, boundingBox: boundingBox)
        }
        image.update()
        update()
    }
    
    func changeBoxDimensions(for boundingBox: MLBoundingBox, normalizedEndPoint: CGPoint, node: NodePosition, image: MLImage, isEditing: Bool, undoManager: UndoManager? = nil) {
        
        if editStartCoordinates[boundingBox.id] == nil {
            // Capture state before changes start to create a clean undo action
            editStartCoordinates[boundingBox.id] = boundingBox.coordinates
        }
        
        // MLBoundingBoxes are in CoreML coordinate space (upper left to lower right)
        // CGRects (in SwiftUI) have a similar coordinate space (upper left to lower right)
        let newPixelPoint = VNImagePointForNormalizedPoint(normalizedEndPoint, image.width, image.height)
        
        // Current box boundaries in pixel space
        let currentX = boundingBox.coordinates.x
        let currentY = boundingBox.coordinates.y
        let currentW = boundingBox.coordinates.width
        let currentH = boundingBox.coordinates.height
        
        // Determine edges: Right = Left + Width and Bottom = Top + Height
        let topEdge = currentY - currentH / 2
        let bottomEdge = topEdge + currentH
        let leftEdge = currentX - currentW / 2
        let rightEdge = leftEdge + currentW
        
        var newTop = topEdge
        var newBottom = bottomEdge
        var newLeft = leftEdge
        var newRight = rightEdge
        
        // Update boundaries based on node being dragged
        switch node {
        case .top:
            newTop = Int(newPixelPoint.y)
        case .bottom:
            newBottom = Int(newPixelPoint.y)
        case .left:
            newLeft = Int(newPixelPoint.x)
        case .right:
            newRight = Int(newPixelPoint.x)
        case .topLeft:
            newTop = Int(newPixelPoint.y)
            newLeft = Int(newPixelPoint.x)
        case .topRight:
            newTop = Int(newPixelPoint.y)
            newRight = Int(newPixelPoint.x)
        case .bottomLeft:
            newBottom = Int(newPixelPoint.y)
            newLeft = Int(newPixelPoint.x)
        case .bottomRight:
            newBottom = Int(newPixelPoint.y)
            newRight = Int(newPixelPoint.x)
        }
        
        // Re-calculate Center, Width, Height
        // Use min/max/abs to handle flipping (e.g. dragging left edge past right edge)
        let finalLeft = min(newLeft, newRight)
        let finalRight = max(newLeft, newRight)
        let finalTop = min(newTop, newBottom)
        let finalBottom = max(newTop, newBottom)
        
        let newWidth = finalRight - finalLeft
        let newHeight = finalBottom - finalTop
        let newCenterX = finalLeft + newWidth / 2
        let newCenterY = finalTop + newHeight / 2
        
        boundingBox.coordinates = MLCoordinates(x: newCenterX, y: newCenterY, width: newWidth, height: newHeight)
        
        if !isEditing {
            // Drag has ended, check if a change was actually made, and register to undoManager
            if let oldCoords = editStartCoordinates[boundingBox.id] {
                let newCoords = boundingBox.coordinates
                if oldCoords != newCoords {
                    undoManager?.registerUndo(withTarget: self) { target in
                        target.restoreBoxCoordinates(for: boundingBox, to: oldCoords, image: image, undoManager: undoManager)
                    }
                }
            }
            editStartCoordinates.removeValue(forKey: boundingBox.id)
        }
        
        image.update()
        update()
    }
    
    func restoreBoxCoordinates(for boundingBox: MLBoundingBox, to coordinates: MLCoordinates, image: MLImage, undoManager: UndoManager? = nil) {
        let currentCoords = boundingBox.coordinates
        undoManager?.registerUndo(withTarget: self) { target in
            target.restoreBoxCoordinates(for: boundingBox, to: currentCoords, image: image, undoManager: undoManager)
        }
        boundingBox.coordinates = coordinates
        image.update()
        update()
    }
    
    //MARK: - Class Functions
    
    func addClass(label: String, color: MLColor, description: String = "", tags: [String] = [], undoManager: UndoManager? = nil) {
        let newClassLabel = MLClass(label: label, color: color, description: description, tags: tags)
        
        // Register Undo
        undoManager?.registerUndo(withTarget: self) { target in
            target.deleteClass(label: label, undoManager: undoManager)
        }
        
        classes.append(newClassLabel)
        update()
    }
    
    func deleteClass(label: String, undoManager: UndoManager? = nil) {
        guard let classToDelete = classes.first(where: { $0.label == label }) else { return }
        
        // Preserve annotation bindings across all images for undo state
        let instancesCopy = classToDelete.instances
        var removedAnnotations: [UUID: [MLBoundingBox]] = [:]
        
        for source in imageSources {
            for image in source.images {
                let matches = image.annotations.filter { $0.label == label }
                if !matches.isEmpty {
                    removedAnnotations[image.id] = matches
                }
            }
        }
        
        // Register Undo
        undoManager?.registerUndo(withTarget: self) { target in
            target.classes.append(classToDelete)
            classToDelete.instances = instancesCopy
            
            for source in target.imageSources {
                for image in source.images {
                    if let boxes = removedAnnotations[image.id] {
                        image.annotations.append(contentsOf: boxes)
                        image.update()
                    }
                }
            }
            target.update()
            
            // Register Redo
            undoManager?.registerUndo(withTarget: target) { target in
                target.deleteClass(label: label, undoManager: undoManager)
            }
        }
        
        classes.removeAll(where: { $0.label == label })
        
        // Remove class instances from all images
        for source in imageSources {
            for image in source.images {
                image.annotations.removeAll(where: { $0.label == label })
                image.update()
            }
        }
        update()
    }
    
    
    // MARK: - Export Functions
    
    public func saveAnnotationsToDisk() {
        let savePanel = NSSavePanel()
        savePanel.allowedContentTypes = [.json]
        savePanel.isExtensionHidden = false
        savePanel.allowsOtherFileTypes = true
        savePanel.title = "Export Your Annotations"
        
        let response = savePanel.runModal()
        guard response == .OK, let saveURL = savePanel.url else { return }
        try? CoreMLAnnotations().write(to: saveURL)
    }
    
    private func CoreMLAnnotations() throws -> Data {
        var jsonObjects = [JSONObject]()
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        for image in allImages() {
            if !image.annotations.isEmpty{
                let jsonObject = JSONObject(imagefilename: image.name, annotation: image.annotations)
                jsonObjects.append(jsonObject)
            }
        }
        return try encoder.encode(jsonObjects)
    }
}

//MARK: - Codable Conformance

extension MLSet {
        
        enum CodingKeys: String, CodingKey {
            case id
            case imageSources
            case images
            case classes
        }
    
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(imageSources, forKey: .imageSources)
            try container.encode(classes, forKey: .classes)
        }
}

//MARK: - Hashable Conformance
extension MLSet {
    static func == (lhs: MLSet, rhs: MLSet) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

