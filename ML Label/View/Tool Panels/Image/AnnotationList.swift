//
//  AnnotationList.swift
//  ML Label
//
//  Created by Martin Castro on 7/8/22.
//


import SwiftUI

struct AnnotationList: View {
    
    @ObservedObject var mlImage: MLImage
    @EnvironmentObject var mlSet: MLSet
    
    var body: some View {
        
        if mlImage.annotations.count != 0 {
            List(mlImage.annotations) { annotation in
                HStack{
                    Text("\(annotation.label)")
                    Spacer()
                    Image(systemName: "eye")
                    Image(systemName: "trash")
                        .onTapGesture {
                            mlImage.removeAnnotation(id: annotation.id)
                        }

                }
            }
        }else{
            Text("No Annotations")
                .font(.caption)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(.secondary)
        }
        
    }
}
