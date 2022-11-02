//
//  BoundingBoxTag.swift
//  ML Label
//
//  Created by Martin Castro on 9/16/22.
//

import SwiftUI

struct BoundingBoxTagView: View {
    
    @EnvironmentObject var mlSet: MLSetDocument
    @EnvironmentObject var userSelections: UserSelections
    
    @ObservedObject var annotation: MLBoundingBox
    
    var color: Color{
        mlSet.classes.first(where: {$0.label == annotation.label})?.color.toColor() ?? .gray
    }
    
    @State var opacity: CGFloat = 1
    
    var body: some View {
        
            HStack{
                Text("\(annotation.label)")
                    .font(.headline)
                    .foregroundColor(.white)
                if userSelections.mode == .removeEnabled {
                    Image(systemName: "xmark")
                }
    
            
        }//END VSTACK
        .padding(5)
        .frame(minWidth: 60)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .onHover { isHovering in
            if isHovering {
                opacity = 0.4
            }else{
                opacity = 1
            }
        }
        .onTapGesture {
            if userSelections.mode == .removeEnabled {
                userSelections.mlImage?.annotations.removeAll(where: {$0.id == annotation.id})
                
                if let mlClass = mlSet.classes.first(where: {$0.label == annotation.label}){
                    mlClass.removeInstance(mlImage: userSelections.mlImage!, boundingBox: annotation)
                }
            }
            userSelections.mlBox = annotation
        }
        .opacity(opacity)
        
    }
}
