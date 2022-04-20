//
//  ImageDataItem.swift
//  ML Label
//
//  Created by Martin Castro on 10/16/21.
//

import SwiftUI

class MLImage: Identifiable, Codable, ObservableObject {
    
    var id = UUID()
    let filePath: URL
    
    let image: String
    @Published var annotations: [MLAnnotation]
    
    let width: Int
    let height: Int
    
    // URL is checked before initializing MLImage Instances via DropDelegate
    init(filePath: URL) {
        self.filePath = filePath
        self.image = filePath.lastPathComponent
        self.width = Int(NSImage(contentsOf: filePath)?.size.width ?? 0)
        self.height = Int(NSImage(contentsOf: filePath)?.size.height ?? 0)
        
        self.annotations = []
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        filePath = try container.decode(URL.self, forKey: .filepath)
        image = try container.decode(String.self, forKey: .image)
        annotations = try container.decode([MLAnnotation].self, forKey: .annotations)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        
    }
}

//MARK: - Codable Conformance
extension MLImage {
        
        enum CodingKeys: String, CodingKey {
            case filepath
            case image
            case annotations
            case width
            case height
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(filePath, forKey: .filepath)
            try container.encode(image, forKey: .image)
            try container.encode(annotations, forKey: .annotations)
            try container.encode(width, forKey: .width)
            try container.encode(height, forKey: .height)
        }
}
