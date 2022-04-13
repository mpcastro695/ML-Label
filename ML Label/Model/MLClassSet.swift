//
//  ClassHandler.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import SwiftUI

class MLClassSet: ObservableObject {
    
    // Consider making a Dictionary
    @Published var classes: [MLClass]
    
    init() {
        self.classes = []
    }
    
    
    func addClass(label: String, color: MLColor) {
        let newClassLabel = MLClass(label: label, color: color)
        classes.append(newClassLabel)
    }
    
    func removeClass(label: String) {
        classes.removeAll(where: {$0.label == label})
    }
}
