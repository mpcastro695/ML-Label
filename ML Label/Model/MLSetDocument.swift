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

class MLSetDocument: FileDocument, Codable, ObservableObject, DropDelegate {
    
    static private var id = UUID()
    static var readableContentTypes: [UTType] = [.mlSetDocument]

    @Published var images: [MLImage]
    @Published var classes: [MLClass]
    
    init() {
        self.images = []
        self.classes = []
    }
    
    // FileDocument Conformance
    required init(configuration: ReadConfiguration) throws {
        let data = configuration.file.regularFileContents!
        let decodedJSONData = try JSONDecoder().decode(MLSetDocument.self, from: data)
        self.images = decodedJSONData.images
        self.classes = decodedJSONData.classes
    }
    
    // Decodable Conformance
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.images = try container.decode([MLImage].self, forKey: .images)
        self.classes = try container.decode([MLClass].self, forKey: .classes)
    }
    
// MARK: - Image Functions

        func performDrop(info: DropInfo) -> Bool {
            
            guard info.hasItemsConforming(to: [.png, .jpeg, .fileURL]) else {
                return false
            }
            
            let imageDropData = info.itemProviders(for: [.png, .jpeg, .fileURL])
            
            for image in imageDropData {
                    
                // Loads data from fileURL drop and creates an instance of imageData for each image.
                image.loadDataRepresentation(forTypeIdentifier: "public.file-url") { data, error in
                    DispatchQueue.main.async {
                        if let imageData = data {
                            if let imagePathString = NSString(data: imageData, encoding: 4){
                                if let imageURL = URL(string: imagePathString as String){
                                    if NSImage(contentsOf: imageURL) != nil{
                                        // Our final MLImage Object
                                        let mlImage = MLImage(url: imageURL)
                                        if !self.images.contains(where: {$0.name == mlImage.name}){
                                            self.images.append(mlImage)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                
            }
            return true
        }
    
    //Consider replacing with Dictionary lookup
    func removeImage(name: String) {
        images.removeAll(where: {$0.name == name})
    }
    
//MARK: - Class Functions
    func addClass(label: String, color: MLColor) {
        let newClassLabel = MLClass(label: label, color: color)
        classes.append(newClassLabel)
    }
    
    func removeClass(label: String) {
        classes.removeAll(where: {$0.label == label})
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

extension MLSetDocument {
        
        enum CodingKeys: String, CodingKey {
            case images
            case classes
        }

        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(images, forKey: .images)
            try container.encode(classes, forKey: .classes)
        }
}

//MARK: - FileDocument Conformance

extension MLSetDocument {
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(self)
        return FileWrapper(regularFileWithContents: data)
        
    }
}
