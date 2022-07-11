//
//  BoundingBoxTag.swift
//  ML Label
//
//  Created by Martin Castro on 10/16/21.
//

import SwiftUI

struct LabelTag: View {
    
    var boundingBox: MLBoundingBox
    var color: Color
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            Text("\(boundingBox.label)")
                .font(.subheadline)
                .bold()
                .foregroundColor(.white)
            
            HStack{
                Text("X: \(boundingBox.coordinates.x)")
                Text("Y: \(boundingBox.coordinates.y)")
                Text("W: \(boundingBox.coordinates.width)")
                Text("H: \(boundingBox.coordinates.height)")
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
