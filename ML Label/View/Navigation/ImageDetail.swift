//
//  ImageDetail.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import SwiftUI

struct ImageDetail: View {
    
    
    @ObservedObject var image: MLImage
    
    // Used for calculating bounding box from drag gesture
    @Binding var selectedClassLabel: MLClass
    
   
    
    var body: some View {
        
        if NSImage(contentsOf: image.filePath) != nil {
            
            AnnotationView(image: image, selectedClassLabel: $selectedClassLabel)
                        
                .toolbar{
                            
                    LabelPicker(selectedClassLabel: $selectedClassLabel)
                        .padding(.horizontal, 10)
                            
                    Button(action: {image.annotations.removeLast()}, label: {
                        Image(systemName: "arrow.uturn.backward").font(.body.weight(.heavy))
                    }).disabled(image.annotations.count == 0)
                    
                    Button(action: {print("Manually add bounding box via window")}, label: {
                        Image(systemName: "plus.rectangle").font(.body.weight(.heavy))
                    }).disabled(selectedClassLabel.label == "No Class Labels")
                    
                    Spacer()
                    
                    Button(action: {print("Delete")}, label: {
                        Image(systemName: "trash").font(.body.weight(.heavy))
                    })
                }
        }else{
            VStack{
                Image(systemName: "photo")
                Text("Cant find the image file")
            }
        }

        
        
    }
}

//struct ImageDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageDetail()
//    }
//}
