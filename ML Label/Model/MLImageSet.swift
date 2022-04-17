//
//  ImageHandler.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import SwiftUI

class MLImageSet: ObservableObject, DropDelegate {

    //Consider making Dictionary
    @Published var images: [MLImage]
    
    init() {
        self.images = []
    }
    
// MARK:  Drop Functionality

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
                                    let mlImage = MLImage(filePath: imageURL)
                                    if !self.images.contains(where: {$0.image == mlImage.image}){
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
        images.removeAll(where: {$0.image == name})
    }
    
}
