//
//  MLBoundingBox.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import Foundation

struct MLBoundingBox: Identifiable, Codable {
    
    var id = UUID()
    
    let imageName: String
    let label: String
    
    // Coordinates use CreateML format
    // X & Y in the center, with a width and height, measured from top left corner
    let x: Int
    let y: Int
    let width: Int
    let height: Int
}
