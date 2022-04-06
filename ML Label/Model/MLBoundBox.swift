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
    
    let x: Int
    let y: Int
    let width: Int
    let height: Int
}
