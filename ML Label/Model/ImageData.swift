//
//  ImageData.swift
//  ML Label
//
//  Created by Martin Castro on 10/16/21.
//

import SwiftUI

class ImageData: Identifiable, ObservableObject {
    
    var id = UUID()
    
    var name: String
    var width: Int
    var height: Int
    
    var image: Image
    
    @Published var annotations: [MLBoundBox]
    
    init(name: String, width: Int, height: Int, image: Image) {
        self.name =  name
        self.width = width
        self.height = height
        self.image = image
        
        self.annotations = []
    }
    
}
