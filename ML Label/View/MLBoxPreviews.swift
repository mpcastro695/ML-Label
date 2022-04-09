//
//  MLBoxPreviews.swift
//  ML Label
//
//  Created by Martin Castro on 4/9/22.
//

import SwiftUI

struct MLBoxPreviews: View {
    
    @ObservedObject var image: ImageData
    
    @Binding var boxPreview: CGRect
    @Binding var showBoxPreview: Bool
    
    // Make selectedClassLabel an ObservedObject?
    @Binding var selectedClassLabel: ClassData
    
    var body: some View {
        GeometryReader{ imgGeometry in
            
            // Shows box preview during drag gesture
            if showBoxPreview {
                RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                    .path(in: boxPreview)
                    .stroke(selectedClassLabel.color, style: StrokeStyle(lineWidth: 3,
                                                                         lineCap: .round, dash: [5,10]))
            }
            // Overlays for each bounding box
            ZStack{
                ForEach(image.annotations, id: \.id) { boundBox in
                    
                    // Caclculate Bounding box placement using ratios.
                    // CGRect Paths are drawn from TOP LEFT corner
                    let x = (imgGeometry.size.width/CGFloat(image.width)) * CGFloat(boundBox.x - boundBox.width/2)
                    let y = (imgGeometry.size.height/CGFloat(image.height)) * CGFloat(boundBox.y-boundBox.height/2)
                    let width = (imgGeometry.size.width/CGFloat(image.width)) * CGFloat(boundBox.width)
                    let height = (imgGeometry.size.height/CGFloat(image.height)) * CGFloat(boundBox.height)
                    
                    // Displays an opacity overlay with a dashed stroke
                    ZStack{
                        RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                            .path(in: CGRect(x: x, y: y, width: width, height: height))
                            .fill(boundBox.label.color.opacity(0.3))
                        RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                            .path(in: CGRect(x: x, y: y, width: width, height: height))
                            .stroke(boundBox.label.color, style: StrokeStyle(lineWidth: 3,
                                                                             lineCap: .round, dash: [5,10]))
                    }
                    
                    // Adds a label to the box overlay showing label name, height, width, etc.
                    BoxLabel(annotation: boundBox)
                        .position(x: x, y: y)
                }
                
            }
            
            
        }
    }
}
