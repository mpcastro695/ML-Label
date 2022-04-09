//
//  MLBoundBox.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import SwiftUI

// MARK: Bounding Box Struct

struct MLBoundBox: Identifiable {
    
    let id = UUID()
    
    let imageName: String
    
    let label: ClassData
    
    // Coordinates use CreateML format
    // X & Y in the center, with a width and height, measured from top left corner
    var x: Int
    var y: Int
    var width: Int
    var height: Int
}
