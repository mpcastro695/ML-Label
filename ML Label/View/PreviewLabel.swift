//
//  BoundingBoxTag.swift
//  ML Label
//
//  Created by Martin Castro on 10/16/21.
//

import SwiftUI

struct PreviewLabel: View {
    
    var annotation: MLAnnotation
    var color: Color
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            Text("\(annotation.label)")
                .font(.subheadline)
                .bold()
                .foregroundColor(.white)
            
            HStack{
                Text("X: \(annotation.coordinates.x)")
                Text("Y: \(annotation.coordinates.y)")
                Text("W: \(annotation.coordinates.width)")
                Text("H: \(annotation.coordinates.height)")
            }
            .font(.caption)
            .foregroundColor(.white)
        }
        .padding(5)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .frame(width: 200, height: 50)
        
    }
}

//struct BoundingBoxTag_Previews: PreviewProvider {
//    static var previews: some View {
//        BoundingBoxTag()
//    }
//}
