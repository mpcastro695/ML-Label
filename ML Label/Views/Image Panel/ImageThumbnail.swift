//
//  ImageThumbnail.swift
//  ML Label
//
//  Created by Martin Castro on 7/13/22.
//

import SwiftUI

struct ImageThumbnail: View {
    
    @ObservedObject var mlImage: MLImage
    @Binding var imageSelection: MLImage?
    
    var body: some View {
        
        if #available(macOS 12.0, *) {
            AsyncImage(url: mlImage.fileURL) { phase in
                if let image = phase.image {
                    // Displays the loaded image.
                    ZStack(alignment: .bottomTrailing){
                        image
                            .resizable()
                            .scaledToFit()
                            .scaleEffect(0.97)
                            .border(imageSelection == mlImage ? Color.primary : Color.clear, width: 5)
                            .onTapGesture {
                                imageSelection = mlImage
                            }
                        if mlImage.annotations.count != 0 {
                            Text("\(mlImage.annotations.count)")
                                .fontWeight(.heavy)
                                .padding(5)
                                .background(.gray)
                                .clipShape(Circle())
                                .padding(8)
                        }
                    }
                } else if phase.error != nil {
                    // Indicates an error.
                    Image(systemName: "questionmark.square.dashed")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.95) // Indicates an error.
                } else {
                    ProgressView() // Acts as a placeholder.
                }
            }
        } else {
            if let nsImage = NSImage(contentsOf: mlImage.fileURL) {
                ZStack(alignment: .bottomTrailing){
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.97)
                        .border(imageSelection == mlImage ? Color.primary : Color.clear, width: 5)
                        .onTapGesture {
                            imageSelection = mlImage
                        }
                    if mlImage.annotations.count != 0 {
                        Text("\(mlImage.annotations.count)")
                            .fontWeight(.heavy)
                            .padding(5)
                            .background(.gray)
                            .clipShape(Circle())
                            .padding(8)
                    }
                }
            }else{
                Image(systemName: "questionmark.square.dashed")
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(0.95)
            }
        }
        //Fallback on earlier versions
        
    }
}
