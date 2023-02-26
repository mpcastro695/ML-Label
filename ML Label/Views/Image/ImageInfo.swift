//
//  ImageInformation.swift
//  ML Label
//
//  Created by Martin Castro on 5/13/22.
//

import SwiftUI

struct ImageInfo: View {
    
    @EnvironmentObject var mlSet: MLSet
    @EnvironmentObject var userSelections: UserSelections
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            if let mlImage = userSelections.mlImage {
                VStack(alignment: .leading){
                    // Image Details
                    HStack {
                        VStack(alignment: .leading){
                            Text("\(mlImage.name)")
                                .font(.headline)
                            Text("\(mlImage.width) x \(mlImage.height) px")
                                .font(.callout)
                                .foregroundColor(.secondary)
                        }// END VSTACK
                        Spacer()
                        // Image Number
                        Text("\(mlSet.images.firstIndex(of: mlImage)! + 1) / \(mlSet.images.count)")
                            .foregroundColor(.secondary)
                    }// END HSTACK
                    .padding(.bottom)
                    
                    AnnotationList(mlImage: mlImage)
                    
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
