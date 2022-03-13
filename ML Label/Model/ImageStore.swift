//
//  ImageStore.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import SwiftUI

// MARK: Image Data Model

class ImageStore: ObservableObject, DropDelegate {

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
                                    let image = Image(nsImage: nsImage)
                                    // Our final ImageInfo Object
                                    let imageInfo = ImageData(name: imageURL.lastPathComponent, width: Int(nsImage.size.width), height: Int(nsImage.size.height), image: image)
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
    
}
