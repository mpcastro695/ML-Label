//
//  ClassStore.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import SwiftUI

//MARK: Class Label Data Model

class ClassStore: ObservableObject {
    
    @Published var classes: [ClassData]
    
    init() {
        self.classes = []
    }
    
    
    func addClass(label: String, color: Color) {
        let newClassLabel = ClassData(label: label, color: color)
        classes.append(newClassLabel)
    }
}
