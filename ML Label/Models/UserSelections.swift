//
//  UserSelections.swift
//  ML Label
//
//  Created by Martin Castro on 10/14/22.
//

import SwiftUI

class UserSelections: ObservableObject {
    @Published var mlImage: MLImage? 
    @Published var mlClass: MLClass?
    @Published var mlBox: MLBoundingBox?
    @Published var imageSource: MLImageSource?
    
    @Published var mode: Mode = .rectEnabled
    
    @Published var cursorGuidesEnabled: Bool = true
    @Published var showBoundingBoxes: Bool = true
    
    
    func update(){
        objectWillChange.send()
    }
    
}

enum Mode {
    case rectEnabled
    case editEnabled
    case autoEnabled
    case removeEnabled
}

