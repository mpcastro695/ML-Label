//
//  ClassData.swift
//  ML Label
//
//  Created by Martin Castro on 10/16/21.
//

import SwiftUI

// MARK:  Class Data Structure

class ClassData: Identifiable, ObservableObject, Hashable {
    
    
    var id = UUID()
    var label: String
    var color: Color
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
    
    @Published var annotations: [MLBoundBox]
    
    init(label: String, color: Color){
        self.label = label
        self.color = color
        
        self.annotations = []
    }
    
    static func == (lhs: ClassData, rhs: ClassData) -> Bool {
        return lhs.id == rhs.id
    }
    
}
