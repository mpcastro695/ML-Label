//
//  ImageHandler.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import SwiftUI

class MLSet: ObservableObject, DropDelegate {

    @Published var images = [MLImage]()
    @Published var classes = [MLClass]()
    
// MARK: - Image Functions

        func performDrop(info: DropInfo) -> Bool {
            
            guard info.hasItemsConforming(to: [.png, .jpeg, .fileURL]) else {
                return false
            }
            
            let imageDropData = info.itemProviders(for: [.png, .jpeg, .fileURL])
            
            for image in imageDropData {
                    
                // Loads data from fileURL drop and creates an instance of imageData for each image.
                image.loadDataRepresentation(forTypeIdentifier: "public.file-url") { data, error in
                    DispatchQueue.main.async {
                        if let imageData = data {
                            if let imagePathString = NSString(data: imageData, encoding: 4){
                                if let imageURL = URL(string: imagePathString as String){
                                    if NSImage(contentsOf: imageURL) != nil{
                                        // Our final MLImage Object
                                        let mlImage = MLImage(url: imageURL)
                                        if !self.images.contains(where: {$0.name == mlImage.name}){
                                            self.images.append(mlImage)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                
                
            }
            
            return true
        }
    
    //Consider replacing with Dictionary lookup
    func removeImage(name: String) {
        images.removeAll(where: {$0.name == name})
    }
    
    
//MARK: - Class Functions
    func addClass(label: String, color: MLColor) {
        let newClassLabel = MLClass(label: label, color: color)
        classes.append(newClassLabel)
    }
    
    func removeClass(label: String) {
        classes.removeAll(where: {$0.label == label})
    }
    
    
// MARK: - Export Functions
    
    func exportJSON(images: [MLImage]) throws -> Data {
        var jsonObjects = [JSONAnnotation]()
        let encoder = JSONEncoder()
        for image in images {
            let jsonObject = JSONAnnotation(image: image.name, annotations: image.annotations)
            jsonObjects.append(jsonObject)
        }
        return try encoder.encode(jsonObjects)
        
    }
    
}
