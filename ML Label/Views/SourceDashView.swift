//
//  ImageSourceView.swift
//  ML Label
//
//  Created by Martin Castro on 11/26/22.
//

import SwiftUI

@available(macOS 13.0, *)
struct SourceDashView: View {
    
    var imageSource: MLImageSource
    
    var body: some View {
        VStack{
            HStack{
                //Source Details
                VStack(alignment: .leading) {
                    HStack{
                        Text("\(Image(systemName: "folder")) \(imageSource.folderName)")
                            .font(.title)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 5)
                        Button {
                            print("Open Document in Finder")
                        } label: {
                            Image(systemName: "arrow.forward.circle")
                        }.buttonStyle(.plain)
                    }
                    Text(imageSource.folderPath)
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                Spacer()
                
                //Image and Annotation Count
                VStack{
                    Text("\(Image(systemName: "photo")) \(imageSource.images.count)")
                        .padding(.bottom, 5)
                    Text("\(Image(systemName: "tag")) \(imageSource.images.count)")
                }
                .foregroundColor(.secondary)
                .padding(5)
            }
            .padding()
            .padding(.bottom)
            
            GalleryView(imageSources: [imageSource])
        }
        
    }
}
