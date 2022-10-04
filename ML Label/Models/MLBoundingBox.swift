//
//  MLBoundingBox.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import Foundation
import Vision

class MLBoundingBox: Identifiable, Codable, ObservableObject {
    
    var id = UUID()
    
    @Published var label: String
    @Published var coordinates: MLCoordinates
    
    init(label: String, coordinates: MLCoordinates) {
        self.label = label
        self.coordinates = coordinates
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        label = try container.decode(String.self, forKey: .label)
        coordinates = try container.decode(MLCoordinates.self, forKey: .coordinates)
    }
    
    func changeBoxDimensions(normalizedEndPoint: CGPoint, node: NodePosition, image: MLImage){
        
        // MLBoundingBoxes are in COREML coordinate space (upper left to lower right)
        // CGRects (in SwiftUI) have a similar coordinate space (upper left to lower right)
        
        let newPixelPoint = VNImagePointForNormalizedPoint(normalizedEndPoint, image.width, image.height)
        
        if node == .top {
            let oldPixelY = self.coordinates.y - self.coordinates.height/2
            let pixelDelta = Int(newPixelPoint.y) - oldPixelY // Up, negative. Down, positive
            let newCoordinates = MLCoordinates(x: self.coordinates.x,
                                               y: self.coordinates.y + pixelDelta/2,
                                               width: self.coordinates.width,
                                               height: self.coordinates.height - pixelDelta)
            self.coordinates = newCoordinates
            
        }else if node == .bottom {
            let oldPixelY = self.coordinates.y + self.coordinates.height/2
            let pixelDelta = Int(newPixelPoint.y) - oldPixelY // Up negative. Down, positive
            let newCoordinates = MLCoordinates(x: self.coordinates.x,
                                               y: self.coordinates.y + pixelDelta/2 ,
                                               width: self.coordinates.width,
                                               height: self.coordinates.height + pixelDelta)
            self.coordinates = newCoordinates
            
        }else if node == .left {
            let oldPixelX = self.coordinates.x - self.coordinates.width/2
            let pixelDelta = Int(newPixelPoint.x) - oldPixelX // Left, negative. Right, Positive
            let newCoordinates = MLCoordinates(x: self.coordinates.x + pixelDelta/2,
                                               y: self.coordinates.y,
                                               width: self.coordinates.width - pixelDelta,
                                               height: self.coordinates.height)
            self.coordinates = newCoordinates
            
        }else if node == .right {
            let oldPixelX = self.coordinates.x + self.coordinates.width/2
            let pixelDelta = Int(newPixelPoint.x) - oldPixelX //Left, negative. Right, positive
            let newCoordinates = MLCoordinates(x: self.coordinates.x + pixelDelta/2,
                                               y: self.coordinates.y,
                                               width: self.coordinates.width + pixelDelta,
                                               height: self.coordinates.height)
            self.coordinates = newCoordinates
        }
    }
    
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
extension MLBoundingBox {
    
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
