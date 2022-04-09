//
//  ImageHandler.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import SwiftUI

class ImageHandler: ObservableObject, DropDelegate {

    //Consider making Dictionary
    @Published var images: [ImageData]
    
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
                        if let imagePath = NSString(data: imageData, encoding: 4){
                            if let imageURL = URL(string: imagePath as String){
                                if let nsImage = NSImage(contentsOf: imageURL){
                                    let finalImage = Image(nsImage: nsImage)
                                    // Our final ImageInfo Object
                                    let imageInfo = ImageData(name: imageURL.lastPathComponent, width: Int(nsImage.size.width), height: Int(nsImage.size.height), image: finalImage)
                                    if !self.images.contains(where: {$0.name == imageInfo.name}){
                                        self.images.append(imageInfo)
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
        images.removeAll { imgData in
            imgData.name == name
        }
    }
    
}
