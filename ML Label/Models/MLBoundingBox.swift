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
    
    func changeBoxDimensions(normalizedEndPoint: CGPoint, node: NodePosition, image: MLImage){
        
        // MLBoundingBoxes are in COREML coordinate space (upper left to lower right)
        // CGRects (in SwiftUI) have a similar coordinate space (upper left to lower right)
        
        let newPixelPoint = VNImagePointForNormalizedPoint(normalizedEndPoint, image.width, image.height)
        
        // Current box boundaries in pixel space
        let currentX = self.coordinates.x
        let currentY = self.coordinates.y
        let currentW = self.coordinates.width
        let currentH = self.coordinates.height
        
        // Determine edges: Right = Left + Width and Bottom = Top + Height
        let topEdge = currentY - currentH / 2
        let bottomEdge = topEdge + currentH
        let leftEdge = currentX - currentW / 2
        let rightEdge = leftEdge + currentW
        
        var newTop = topEdge
        var newBottom = bottomEdge
        var newLeft = leftEdge
        var newRight = rightEdge
        
        // Update boundaries based on node being dragged
        switch node {
        case .top:
            newTop = Int(newPixelPoint.y)
        case .bottom:
            newBottom = Int(newPixelPoint.y)
        case .left:
            newLeft = Int(newPixelPoint.x)
        case .right:
            newRight = Int(newPixelPoint.x)
        case .topLeft:
            newTop = Int(newPixelPoint.y)
            newLeft = Int(newPixelPoint.x)
        case .topRight:
            newTop = Int(newPixelPoint.y)
            newRight = Int(newPixelPoint.x)
        case .bottomLeft:
            newBottom = Int(newPixelPoint.y)
            newLeft = Int(newPixelPoint.x)
        case .bottomRight:
            newBottom = Int(newPixelPoint.y)
            newRight = Int(newPixelPoint.x)
        }
        
        // Re-calculate Center, Width, Height
        // Use min/max/abs to handle flipping (e.g. dragging left edge past right edge)
        let finalLeft = min(newLeft, newRight)
        let finalRight = max(newLeft, newRight)
        let finalTop = min(newTop, newBottom)
        let finalBottom = max(newTop, newBottom)
        
        let newWidth = finalRight - finalLeft
        let newHeight = finalBottom - finalTop
        let newCenterX = finalLeft + newWidth / 2
        let newCenterY = finalTop + newHeight / 2
        
        self.coordinates = MLCoordinates(x: newCenterX, y: newCenterY, width: newWidth, height: newHeight)
    }
    
}

struct MLCoordinates: Codable {
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
