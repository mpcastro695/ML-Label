//
//  BoundingBoxTag.swift
//  ML Label
//
//  Created by Martin Castro on 9/16/22.
//

import SwiftUI

struct BoundingBoxTag: View {
    
    @ObservedObject var annotation: MLBoundingBox
    var color: Color
    
    @Binding var annotationSelection: MLBoundingBox?
    var mode: Mode
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            HStack{
                Text("\(annotation.label)")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                if mode == .removeEnabled {
                    Image(systemName: "xmark")
                }
            }//END HSTACK
            
            if annotationSelection?.id == annotation.id {
                VStack(alignment: .leading){
                    HStack{
                        Text("X: \(annotation.coordinates.x)")
                        Text("Y: \(annotation.coordinates.y)")
                    }
                    HStack{
                        Text("W: \(annotation.coordinates.width)")
                        Text("H: \(annotation.coordinates.height)")
                    }
                }//END VSTACK
                .font(.caption)
                .foregroundColor(.white)
            }
            
        }//END VSTACK
        .padding(5)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .frame(width: 100, height: 50)
        
    }
}
