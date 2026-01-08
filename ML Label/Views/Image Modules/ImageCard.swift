//
//  ImageThumbnail.swift
//  ML Label
//
//  Created by Martin Castro on 7/13/22.
//

import SwiftUI

struct ImageCard: View {
    
    @ObservedObject var mlImage: MLImage
    @EnvironmentObject var userSelections: UserSelections
    
    var body: some View {
        
        //Thumbnail is cropped to a 1:1 square
        ZStack(alignment: .bottomTrailing){
            Rectangle()
                .aspectRatio(1, contentMode: .fill)
                .overlay {
                    Image(nsImage: NSImage(byReferencing: mlImage.fileURL))
                        .resizable()
                        .scaledToFill()
                }
            HStack{ //Card Details
                Text("\(mlImage.name)")
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .padding(.leading, 5)
                Spacer()
                if mlImage.annotations.count != 0 {
                    Text("\(mlImage.annotations.count)")
                        .font(.caption)
                        .padding(5)
                        .background(.gray.opacity(0.5))
                        .clipShape(Circle())
                        .padding(8)
                }
            }//END HSTACK
            .frame(height: 25)
            .background(.thickMaterial)
        }//END ZSTACK
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
}
