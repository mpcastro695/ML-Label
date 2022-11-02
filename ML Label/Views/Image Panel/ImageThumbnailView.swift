//
//  ImageThumbnail.swift
//  ML Label
//
//  Created by Martin Castro on 7/13/22.
//

import SwiftUI

struct ImageThumbnailView: View {
    
    @ObservedObject var mlImage: MLImage
    @EnvironmentObject var userSelections: UserSelections
    
    var body: some View {
        
        if #available(macOS 12.0, *) {
            AsyncImage(url: mlImage.fileURL, scale: 0.2) { phase in
            
                if let image = phase.image {
                    //Thumbnail is cropped to a 1:1 square
                    ZStack(alignment: .bottomTrailing){
                        Rectangle()
                            .aspectRatio(1, contentMode: .fit)
                            .overlay {
                                image
                                    .resizable()
                                    .scaledToFill()
                            }
                            .clipped()
                            .border(userSelections.mlImage == mlImage ? Color.white : Color.clear, width: 5)
                            .scaleEffect(0.97)
                        
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
                        .scaleEffect(0.8) // Indicates an error.
                        .onAppear {
                            print(phase.error.debugDescription)
                        }
                } else {
                    // Acts as a placeholder.
                    ProgressView()
                }
            }
        } else {
            if let nsImage = NSImage(contentsOf: mlImage.fileURL) {
                ZStack(alignment: .bottomTrailing){
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.97)
                        .border(userSelections.mlImage == mlImage ? Color.primary : Color.clear, width: 5)
        
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
