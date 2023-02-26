//
//  ImageRow.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import SwiftUI

struct ImageRow: View {
    
    @EnvironmentObject var userSelections: UserSelections
    @ObservedObject var image: MLImage
    
    var body: some View {
        
        HStack{
            // Image in a 30x30 rounded frame
            Image(nsImage: NSImage(contentsOf: image.fileURL)!)
                .resizable()
                .scaledToFill()
                .frame(width: 20, height: 20, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            
            // Vstack of image name and dimensions
            VStack(alignment: .leading){
                Text(image.name)
                Text("\(image.width) x \(image.height)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            // If annotations are have been made, an annotation count
            if image.annotations.count > 0 {
                Spacer()
                Text("\(image.annotations.count)")
                    .font(.caption)
                    .bold()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.3))
                    .clipShape(Capsule())
            }
            
        }
        .onTapGesture {
            userSelections.mlImage = image
        }
    }
}
