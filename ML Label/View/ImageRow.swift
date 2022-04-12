//
//  ImageRow.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import SwiftUI

struct ImageRow: View {
    
    @ObservedObject var image: MLImage
    
    var body: some View {
        
        HStack{
            
            // Image in a 30x30 rounded frame
            Image(nsImage: NSImage(contentsOf: image.filePath)!)
                .resizable()
                .scaledToFill()
                .frame(width: 30, height: 30, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            
            // Vstack of image name and dimensions
            VStack(alignment: .leading){
                Text(image.name)
                Text("\(image.width) x \(image.height)")
                    .font(.caption)
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
    }
}

//struct ImageListRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageRow()
//    }
//}
