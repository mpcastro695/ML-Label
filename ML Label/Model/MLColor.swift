//
//  MLColor.swift
//  ML Label
//
//  Created by Martin Castro on 4/11/22.
//

import Foundation

//MARK: - MLColor
struct MLColor: Identifiable, Codable, Hashable {
    
    var id = UUID()
    var red: Double
    var green: Double
    var blue: Double
    
    static func == (lhs: MLColor, rhs: MLColor) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
