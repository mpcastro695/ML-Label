//
//  MLCoordinates.swift
//  ML Label
//
//  Created by Martin Castro on 4/17/22.
//

import Foundation

struct MLCoordinates: Codable {
    
    // Coordinates use CreateML format
    // X & Y in the center, with a width and height, measured from top left corner
    let x: Int
    let y: Int
    let width: Int
    let height: Int
}
