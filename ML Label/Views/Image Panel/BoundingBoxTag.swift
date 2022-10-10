//
//  BoundingBoxTag.swift
//  ML Label
//
//  Created by Martin Castro on 9/16/22.
//

import SwiftUI

struct BoundingBoxTag: View {
    
    @EnvironmentObject var mlSet: MLSetDocument
    @ObservedObject var annotation: MLBoundingBox
    var color: Color{
        mlSet.classes.first(where: {$0.label == annotation.label})?.color.toColor() ?? .gray
    }
    
    @Binding var annotationSelection: MLBoundingBox?
    var mode: Mode
    
    var body: some View {
        
        VStack(alignment: .center){
            HStack{
                Text("\(annotation.label)")
                    .font(.headline)
                    .foregroundColor(.white)
                if mode == .removeEnabled {
                    Image(systemName: "xmark")
                }
            }//END HSTACK
            
//            if annotationSelection?.id == annotation.id {
//                HStack(){
//
//                    Text("X: \(annotation.coordinates.x)")
//                    Text("Y: \(annotation.coordinates.y)")
//                    Text("W: \(annotation.coordinates.width)")
//                    Text("H: \(annotation.coordinates.height)")
//
//                }//END VSTACK
//                .font(.caption)
//                .foregroundColor(.white)
//            }
            
        }//END VSTACK
        .padding(5)
        .frame(minWidth: 60)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        
    }
}
