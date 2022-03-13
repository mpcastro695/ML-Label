//
//  BoundingBoxTag.swift
//  ML Label
//
//  Created by Martin Castro on 10/16/21.
//

import SwiftUI

struct BoxLabel: View {
    
    var annotation: MLBoundBox
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            Text("\(annotation.label.label)")
                .font(.subheadline)
                .bold()
                .foregroundColor(.white)
            
            HStack{
                Text("X: \(annotation.x)")
                Text("Y: \(annotation.y)")
                Text("W: \(annotation.width)")
                Text("H: \(annotation.height)")
            }
            .font(.caption)
            .foregroundColor(.white)
        }
        .padding(5)
        .background(annotation.label.color)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .frame(width: 200, height: 50)
        
    }
}

//struct BoundingBoxTag_Previews: PreviewProvider {
//    static var previews: some View {
//        BoundingBoxTag()
//    }
//}
