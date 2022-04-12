//
//  GridBox.swift
//  ML Label
//
//  Created by Martin Castro on 10/16/21.
//

import SwiftUI

struct GridBox: View {
    
    let image: MLImage
    let boundBox: MLBoundingBox
    
    @State private var  cgSize = CGSize()
    
    var body: some View {
        
        let x = cgSize.width * CGFloat(boundBox.x - boundBox.width/2)/CGFloat(image.width)
        let y = cgSize.height * CGFloat(boundBox.y-boundBox.height/2)/CGFloat(image.height)
        let width = cgSize.width * CGFloat(boundBox.width)/CGFloat(image.width)
        let height = cgSize.height * CGFloat(boundBox.height)/CGFloat(image.height)
        
        Image(nsImage: NSImage(contentsOf: image.filePath)!)
            .resizable()
            .sizeReader(size: $cgSize)
            .clipShape(
                Rectangle()
                    .path(in: CGRect(x: x, y: y, width: width, height: height))
            )
        
        
    }
}

//struct GridBox_Previews: PreviewProvider {
//    static var previews: some View {
//        GridBox()
//    }
//}
