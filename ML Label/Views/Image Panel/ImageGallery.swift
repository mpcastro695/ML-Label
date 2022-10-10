//
//  ImageGallery.swift
//  ML Label
//
//  Created by Martin Castro on 10/8/22.
//

import SwiftUI

struct ImageGallery: View {
    
    @EnvironmentObject var mlSet: MLSetDocument
    @Binding var imageSelection: MLImage?
    
    let thumbnailHeight: CGFloat = 60
    let thumbnailWidth: CGFloat = 80
    let thumbPadding: CGFloat = 0
    
    var body: some View {
        GeometryReader{ geometry in
            
            if geometry.size.height < 160 {
    
                ScrollView(.horizontal) {
                    LazyHGrid(rows: [GridItem(.flexible(minimum: thumbnailHeight, maximum: .infinity), spacing: thumbPadding)], spacing: 0){
                        ForEach(mlSet.images) { mlImage in
                            ImageThumbnail(mlImage: mlImage, imageSelection: $imageSelection)
                        }
                    }
                }
                
            }else{

                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: thumbnailWidth), spacing: thumbPadding)], spacing: 0) {
                        ForEach(mlSet.images) { mlImage in
                            ImageThumbnail(mlImage: mlImage, imageSelection: $imageSelection)
                        }
                    }
                }
            }
        }
    }
}
