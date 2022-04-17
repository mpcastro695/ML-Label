//
//  MLBoundingBox.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import Foundation

struct MLAnnotation: Identifiable, Codable {
    
    var id = UUID()
    
    let label: String
    let coordinates: MLCoordinates
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: JSONCodingKeys.self)
        try container.encode(label, forKey: .label)
        try container.encode(coordinates, forKey: .coordinates)
    }
    
    enum JSONCodingKeys: CodingKey {
        case label
        case coordinates
    }
}
