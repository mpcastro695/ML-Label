//
//  MLImageSource.swift
//  ML Label
//
//  Created by Martin Castro on 11/26/22.
//

import Foundation

/// A reference to a folder on disk that contains image data
class MLImageSource: Identifiable, Codable, ObservableObject, Hashable {
    
    let id: UUID
    var folderPath: String
    var folderName: String
    
    var images: [MLImage]
    
    @available(macOS 13.0, *)
    init (folderURL: URL) {
        self.id = UUID()
        self.folderPath = folderURL.path(percentEncoded: false)
        self.folderName = folderURL.lastPathComponent
        self.images = []
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.folderPath = try container.decode(String.self, forKey: .folderPath)
        self.folderName = try container.decode(String.self, forKey: .folderName)
        self.images = try container.decode([MLImage].self, forKey: .images)
    }
    
    //MARK: - Helper Functions
    
    func addImage(image: MLImage) {
        if !self.images.contains(where: {$0.name == image.name}){
            self.images.append(image)
        }
    }
    
    func removeImage(id: UUID) {
        images.removeAll {$0.id == id}
    }

}

//MARK: - Codable Conformance
extension MLImageSource {
        enum CodingKeys: String, CodingKey {
            case id
            case folderPath
            case folderName
            case images
        }
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(folderPath, forKey: .folderPath)
            try container.encode(folderName, forKey: .folderName)
            try container.encode(images, forKey: .images)
        }
}

//MARK: - Hashable Conformance
extension MLImageSource {
    static func == (lhs: MLImageSource, rhs: MLImageSource) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
