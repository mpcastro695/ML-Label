//
//  ClassData.swift
//  ML Label
//
//  Created by Martin Castro on 10/16/21.
//

import SwiftUI

class MLClass: Identifiable, Codable, ObservableObject, Hashable {
    
    let id: UUID
    let label: String
    
    var color: MLColor
    var tags: [String]
    var description: String
    
    @Published var instances: [MLImage : [MLBoundingBox]]
    
    init(label: String, color: MLColor, description: String = "", tags: [String] = []){
        self.id = UUID()
        self.label = label
        self.color = color
        self.tags = tags
        self.description = description
        self.instances = [:]
    }
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.label = try container.decode(String.self, forKey: .label)
        self.color = try container.decode(MLColor.self, forKey: .color)
        self.tags = try container.decode([String].self, forKey: .tags)
        self.description = try container.decode(String.self, forKey: .description)
        self.instances = try container.decode([MLImage : [MLBoundingBox]].self, forKey: .instances)
    }
    
    func addInstance(mlImage: MLImage, boundingBox: MLBoundingBox) {
        if instances[mlImage] == nil {
            instances[mlImage] = [boundingBox]
        }else{
            instances[mlImage]?.append(boundingBox)
        }
    }
    
    func removeInstance(mlImage: MLImage, boundingBox: MLBoundingBox) {
        if instances[mlImage] == nil {
            return
        }else{
            instances[mlImage]?.removeAll(where: {$0.id == boundingBox.id})
            if instances[mlImage]!.isEmpty{
                instances[mlImage] = nil
            }
        }
    }
    
    func tagCount() -> Int {
        var tagCount = 0
        for image in instances {
            tagCount += image.value.count
        }
        return tagCount
    }
    
}

//MARK: - Codable Conformance
extension MLClass {

    enum CodingKeys: CodingKey {
        case id
        case label
        case color
        case tags
        case description
        case instances
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(label, forKey: .label)
        try container.encode(color, forKey: .color)
        try container.encode(tags, forKey: .tags)
        try container.encode(description, forKey: .description)
        try container.encode(instances, forKey: .instances)
    }
    
}

//MARK: - Hashable Conformance
extension MLClass {
    static func == (lhs: MLClass, rhs: MLClass) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
