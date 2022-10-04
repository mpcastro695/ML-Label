//
//  ImageInformation.swift
//  ML Label
//
//  Created by Martin Castro on 5/13/22.
//

import SwiftUI

struct ImageInformation: View {
    
    @EnvironmentObject var mlSet: MLSetDocument
    
    @Binding var imageSelection: MLImage?
    @Binding var classSelection: MLClass?
    @Binding var annotationSelection: MLBoundingBox?
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            if let img = imageSelection {
                VStack(alignment: .leading){
                    // Image Details
                    HStack {
                        VStack(alignment: .leading){
                            Text("\(img.name)")
                                .font(.headline)
                            Text("\(img.width) x \(img.height) px")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }// END VSTACK
                        Spacer()
                        // Image Number
                        Text("\(mlSet.images.firstIndex(of: img)! + 1) / \(mlSet.images.count)")
                            .foregroundColor(.secondary)
                    }// END HSTACK
                    .padding(.bottom)
                    
                    AnnotationList(mlImage: img, annotationSelection: $annotationSelection)
                    
                }//END VSTACK
                .padding()
            }else{
                    
                Text("View an image's details and annotations")
                    .font(.caption)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.secondary.opacity(0.8))
                
                .padding()
                
            }//END IMAGE DETAILS + ANNOTATIONLIST
            
        }
    }
}
