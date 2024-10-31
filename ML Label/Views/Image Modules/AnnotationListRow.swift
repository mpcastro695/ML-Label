//
//  AnnotationRow.swift
//  ML Label
//
//  Created by Martin Castro on 7/17/22.
//

import SwiftUI

struct AnnotationListRow: View {
    
    @EnvironmentObject var mlSet: MLSet
    
    @ObservedObject var mlImage: MLImage
    var annotation: MLBoundingBox
    
    @State var isVisible: Bool = true
    
    var body: some View {
        
        HStack{
            
            /// Dot and Label Name
            Text("\(Image(systemName: "circlebadge.fill"))")
                .foregroundColor(mlSet.classes.first(where: {$0.label == annotation.label})!.color.toColor())
            Text("\(annotation.label)")
            
            Spacer()

            Button {
                mlImage.removeAnnotation(id: annotation.id)
                if let mlClass = mlSet.classes.first(where: {$0.label == annotation.label}){
                    mlClass.removeInstance(mlImage: mlImage, boundingBox: annotation)
                }
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }.buttonStyle(.plain)
            
        }//END HSTACK
        .padding(.horizontal, 5)
        
    }
}

