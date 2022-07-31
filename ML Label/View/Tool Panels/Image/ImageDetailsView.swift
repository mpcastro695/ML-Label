//
//  ImageTools.swift
//  ML Label
//
//  Created by Martin Castro on 5/13/22.
//

import SwiftUI

struct ImageDetailsView: View {
    
    @EnvironmentObject var mlSet: MLSetDocument
    
    @Binding var addEnabled: Bool
    @Binding var removeEnabled: Bool
    
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
                    
                    AnnotationListView(mlImage: img, annotationSelection: $annotationSelection)
                    
                }//END VSTACK
                .padding()
            }else{
                VStack(alignment: .leading){
                    Text("---")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("---")
                        .font(.callout)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 20)
                    Text("Select an image to view annotations")
                        .font(.caption)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .foregroundColor(.secondary)
                }
                .padding()
                
            }//END IMAGE DETAILS + ANNOTATIONLIST
            
        }
    }
}
