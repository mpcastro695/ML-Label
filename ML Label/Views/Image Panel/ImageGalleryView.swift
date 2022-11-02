//
//  ImageGallery.swift
//  ML Label
//
//  Created by Martin Castro on 10/8/22.
//

import SwiftUI

struct ImageGalleryView: View {
    
    @EnvironmentObject var mlSet: MLSetDocument
    @EnvironmentObject var userSelections: UserSelections
    
    let thumbnailHeight: CGFloat = 60
    let thumbnailWidth: CGFloat = 80
    let thumbPadding: CGFloat = 0
    
    var body: some View {
        GeometryReader{ geometry in
            
            if geometry.size.height < 160 {
    
                ScrollView(.horizontal) {
                    LazyHGrid(rows: [GridItem(.flexible(minimum: thumbnailHeight, maximum: .infinity), spacing: thumbPadding)], spacing: 0){
                        ForEach(mlSet.images) { mlImage in
                            ImageThumbnailView(mlImage: mlImage)
                                .onTapGesture {
                                    userSelections.mlImage = mlImage
                                }
                        }
                    }
                }
                
            }else{

                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: thumbnailWidth), spacing: thumbPadding)], spacing: 0) {
                        ForEach(mlSet.images) { mlImage in
                            ImageThumbnailView(mlImage: mlImage)
                                .onTapGesture {
                                    userSelections.mlImage = mlImage
                                }
                        }
                    }
                }
            }
        }
    }
}
