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
    
}

struct MLCoordinates: Codable {
    
    // Coordinates use CreateML format
    // X & Y in the center, with a width and height, measured from top left corner
    let x: Int
    let y: Int
    let width: Int
    let height: Int
}


//MARK: - Codable Conformance
extension MLAnnotation {
    
    enum CodingKeys: CodingKey {
        case label
        case coordinates
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(label, forKey: .label)
        try container.encode(coordinates, forKey: .coordinates)
    }
}
