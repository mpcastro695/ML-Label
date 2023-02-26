//
//  ImageHandler.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import SwiftUI
import UniformTypeIdentifiers

extension UTType {
    static let mlSetDocument = UTType(exportedAs: "com.example.MLLabel.mlset")
}

/// A file document that contains data on images, classes, and annotations
class MLSet: FileDocument, Codable, Hashable, ObservableObject, DropDelegate {
    
    static var readableContentTypes: [UTType] = [.mlSetDocument]

    @Published var imageSources: [MLImageSource]
    @Published var images: [MLImage]
    @Published var classes: [MLClass]
    
    let id: UUID
    
    init() {
        self.id = UUID()
        self.imageSources = []
        self.images = []
        self.classes = []
    }
    
    // FileDocument Conformance
    required init(configuration: ReadConfiguration) throws {
        let data = configuration.file.regularFileContents!
        let decodedJSONData = try PropertyListDecoder().decode(MLSet.self, from: data)
        self.id = decodedJSONData.id
        self.imageSources = decodedJSONData.imageSources
        self.images = decodedJSONData.images
        self.classes = decodedJSONData.classes
    }
    
    // Decodable Conformance
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.imageSources = try container.decode([MLImageSource].self, forKey: .imageSources)
        self.images = try container.decode([MLImage].self, forKey: .images)
        self.classes = try container.decode([MLClass].self, forKey: .classes)
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
                                    // Fallback on earlier versions
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
    func addImageFromURL(url: URL) {
        if NSImage(contentsOf: url) != nil{
            let mlImage = MLImage(fileURL: url)
            let folderPath = url.deletingLastPathComponent().path(percentEncoded: false)
            
            if imageSources.contains(where: {$0.folderPath == folderPath}){
                //Add to an existing MLImageSource
                let imageSource = imageSources.first(where: {$0.folderPath == folderPath})!
                imageSource.images.append(mlImage) //FIX THIS WITH HELPER FUNC
            }else{
                //Create new MLImageSource and add image
                let newSource = MLImageSource(folderURL: url.deletingLastPathComponent())
                newSource.images.append(mlImage)
                imageSources.append(newSource)
            }
    
            //Images not appending becuase their names are the same
            if !self.images.contains(where: {$0.id == mlImage.id}){
                self.images.append(mlImage)
            }
        }
    }
    
    
    //MARK: - Class Functions
    
    func addClass(label: String, color: MLColor, description: String = "", tags: [String] = []) {
        let newClassLabel = MLClass(label: label, color: color, description: description, tags: tags)
        classes.append(newClassLabel)
    }
    
    func removeClass(label: String) {
        classes.removeAll(where: {$0.label == label})
    }
    
    //Consider replacing with Dictionary lookup
    func removeImage(name: String) {
        images.removeAll(where: {$0.name == name})
    }
    
    func allImages() -> [MLImage] {
        var allImages: [MLImage] = []
        for imageSource in imageSources {
            allImages += imageSource.images
        }
        return allImages
    }
    
    
    // MARK: - Export Functions
    
    func exportCoreMLAnnotations(images: [MLImage]) throws -> Data {
        var jsonObjects = [JSONObject]()
        let encoder = JSONEncoder()
        for image in images {
            let jsonObject = JSONObject(image: image.name, annotations: image.annotations)
            jsonObjects.append(jsonObject)
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
            try container.encode(images, forKey: .images)
            try container.encode(classes, forKey: .classes)
        }
}

//MARK: - FileDocument Conformance

extension MLSet {
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        var data: Data
        do{
            data = try PropertyListEncoder().encode(self)
            print("encoder worked?")
        }catch{
            print("encoder failed")
            data = Data() // Blank
        }
        return FileWrapper(regularFileWithContents: data)
    }
    
    func currentFileName() -> String {
        //
        //
        return("")
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
