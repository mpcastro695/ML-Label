//
//  MissingImages.swift
//  ML Label
//
//  Created by Martin Castro on 7/8/22.
//

import SwiftUI

struct MissingImages: View {
    
    @EnvironmentObject var mlSet: MLSet
    
    var body: some View {
        
        VStack{
            ZStack{
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
                Image(systemName: "plus.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .offset(x: 30, y: -30)
            }
            .padding(.bottom, 5)
            
            Text("Drag and drop or select images from file")
                .foregroundColor(.secondary)
                .font(.footnote)
            
        }//END VSTACK
        .padding(30)
        .background(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 2, dash: [5,5])).foregroundColor(.secondary).opacity(0.3))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
}
