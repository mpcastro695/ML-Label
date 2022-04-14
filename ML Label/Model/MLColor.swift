//
//  MLColor.swift
//  ML Label
//
//  Created by Martin Castro on 4/11/22.
//

import SwiftUI

struct MLColor: Identifiable, Codable, Hashable {
    
    var id = UUID()
    
    let red: Double
    let green: Double
    let blue: Double
    
    func toColor() -> Color {
        return Color(red: self.red, green: self.green, blue: self.blue)
    }
    
    static func == (lhs: MLColor, rhs: MLColor) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
