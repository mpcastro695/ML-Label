//
//  MLBoundingBox.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import Foundation
import Vision

/// Coordinates are in CreateML format with a center (x, y), width and height.
/// Origin (0,0) is top-left.

class MLBoundingBox: Identifiable, Codable, ObservableObject {
    
    let id: UUID
    
    @Published var label: String
    @Published var coordinates: MLCoordinates
    
    init(label: String, coordinates: MLCoordinates) {
        self.id = UUID()
        self.label = label
        self.coordinates = coordinates
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        label = try container.decode(String.self, forKey: .label)
        coordinates = try container.decode(MLCoordinates.self, forKey: .coordinates)
    }
    
}

struct MLCoordinates: Codable, Equatable {
    let x: Int
    let y: Int
    let width: Int
    let height: Int
}


//MARK: - Codable Conformance
extension MLBoundingBox {
    
    enum CodingKeys: CodingKey {
        case id
        case label
        case coordinates
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(label, forKey: .label)
        try container.encode(coordinates, forKey: .coordinates)
    }
}
