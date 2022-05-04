//
//  ClassData.swift
//  ML Label
//
//  Created by Martin Castro on 10/16/21.
//

import SwiftUI

class MLClass: Identifiable, Codable, ObservableObject, Hashable {
    
    var id = UUID()
    
    let label: String
    var color: MLColor
    
    @Published var annotations: [MLBoundingBox]
    
    
    init(label: String, color: MLColor){
        self.label = label
        self.color = color
        
        self.annotations = []
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        label = try container.decode(String.self, forKey: .label)
        color = try container.decode(MLColor.self, forKey: .color)
        annotations = try container.decode([MLBoundingBox].self, forKey: .annotations)
        
    }
    
}

//MARK: - Codable Conformance
extension MLClass {

    enum CodingKeys: CodingKey {
        case id
        case label
        case color
        case annotations
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(label, forKey: .label)
        try container.encode(color, forKey: .color)
        try container.encode(annotations, forKey: .annotations)
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
