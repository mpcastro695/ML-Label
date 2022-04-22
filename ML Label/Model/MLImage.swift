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
    
    let name: String
    let image: NSImage?
    
    @Published var annotations: [MLAnnotation]
    
    let width: Int
    let height: Int
    
    // URL is checked before initializing MLImage Instances via DropDelegate
    init(filePath: URL) {
        self.filePath = filePath
        self.name = filePath.lastPathComponent
        self.image = NSImage(contentsOf: self.filePath)
        self.width = Int(NSImage(contentsOf: self.filePath)?.size.width ?? 0)
        self.height = Int(NSImage(contentsOf: self.filePath)?.size.height ?? 0)
        
        self.annotations = []
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        filePath = try container.decode(URL.self, forKey: .filepath)
        image = NSImage(contentsOf: filePath)
        name = try container.decode(String.self, forKey: .name)
        annotations = try container.decode([MLAnnotation].self, forKey: .annotations)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        
    }
}

//MARK: - Codable Conformance
extension MLImage {
        
        enum CodingKeys: String, CodingKey {
            case filepath
            case name
            case annotations
            case width
            case height
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(filePath, forKey: .filepath)
            try container.encode(name, forKey: .name)
            try container.encode(annotations, forKey: .annotations)
            try container.encode(width, forKey: .width)
            try container.encode(height, forKey: .height)
        }
}
