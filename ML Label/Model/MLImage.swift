//
//  ImageDataItem.swift
//  ML Label
//
//  Created by Martin Castro on 10/16/21.
//

import SwiftUI

class MLImage: Identifiable, Codable, ObservableObject {
    
    var id = UUID()
    
    let name: String
    let width: Int
    let height: Int
    
    let filePath: URL
    
    @Published var annotations: [MLBoundingBox]
    
    init(name: String, width: Int, height: Int, filePath: URL) {
        self.name =  name
        self.width = width
        self.height = height
        self.filePath = filePath
        
        self.annotations = []
    }
    
//MARK: - Codable Conformance
    
    enum CodingKeys: CodingKey {
        case id
        case name
        case width
        case height
        case filePath
        case annotations
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
        filePath = try container.decode(URL.self, forKey: .filePath)
        annotations = try container.decode([MLBoundingBox].self, forKey: .annotations)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(width, forKey: .width)
        try container.encode(height, forKey: .height)
        try container.encode(filePath, forKey: .filePath)
        try container.encode(annotations, forKey: .annotations)
    }
    
}
