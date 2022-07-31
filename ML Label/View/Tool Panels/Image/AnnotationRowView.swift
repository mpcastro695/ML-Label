//
//  AnnotationRowView.swift
//  ML Label
//
//  Created by Martin Castro on 7/17/22.
//

import SwiftUI

struct AnnotationRowView: View {
    
    @EnvironmentObject var mlSet: MLSetDocument
    
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
            } label: {
                Image(systemName: "xmark")
                    .font(.subheadline)
            }.buttonStyle(.plain)
            
        }//END HSTACK
        
    }
}

