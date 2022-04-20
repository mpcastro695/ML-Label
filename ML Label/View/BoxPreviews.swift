//
//  MLBoxPreviews.swift
//  ML Label
//
//  Created by Martin Castro on 4/9/22.
//

import SwiftUI

struct BoxPreviews: View {
    
    @ObservedObject var image: MLImage
    @EnvironmentObject var mlSet: MLSet
    
    // Make selectedClassLabel an ObservedObject?
    @Binding var selectedClassLabel: MLClass
    @Binding var showDrawingPreview: Bool
    @Binding var boxPreview: CGRect
    
    let labeler: Labeler

    
    var body: some View {
        
        GeometryReader{ imgGeometry in
            
            // Shows box preview during drag gesture
            if showDrawingPreview {
                RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                    .path(in: boxPreview)
                    .stroke(selectedClassLabel.color.toColor(), style: StrokeStyle(lineWidth: 3,
                                                                         lineCap: .round, dash: [5,10]))
            }
            
            // Overlays for each bounding box
            ZStack{
                ForEach(image.annotations, id: \.id) { boundBox in
                    
                    let mlClass = mlSet.classes.first(where: {$0.label == boundBox.label})!
                    let classColor = mlClass.color.toColor()
                    
                    // Caclculate Bounding box placement using ratios.
                    // CGRect Paths are drawn from TOP LEFT corner
                    let x = (imgGeometry.size.width/CGFloat(image.width)) * CGFloat(boundBox.coordinates.x - boundBox.coordinates.width/2)
                    let y = (imgGeometry.size.height/CGFloat(image.height)) * CGFloat(boundBox.coordinates.y-boundBox.coordinates.height/2)
                    let width = (imgGeometry.size.width/CGFloat(image.width)) * CGFloat(boundBox.coordinates.width)
                    let height = (imgGeometry.size.height/CGFloat(image.height)) * CGFloat(boundBox.coordinates.height)
                    
                    // Displays an opacity overlay with a dashed stroke
                    ZStack{
                        RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                            .path(in: CGRect(x: x, y: y, width: width, height: height))
                            .fill(classColor)
                            .opacity(0.3)
                        RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                            .path(in: CGRect(x: x, y: y, width: width, height: height))
                            .stroke(classColor, style: StrokeStyle(lineWidth: 3,
                                                                             lineCap: .round, dash: [5,10]))
                        // Adds a label to the box overlay showing label name, height, width, etc.
                        PreviewLabel(annotation: boundBox, color: classColor)
                            .position(x: x, y: y)
                            .onTapGesture {
                                // Remove box on tap
                                image.annotations.removeAll { annotation in
                                    annotation.id == boundBox.id
                                }
                            }
                    }
                    
//                        // Move box on drag
//                        .gesture(DragGesture(minimumDistance: 5, coordinateSpace: .local).onChanged({ gestureValue in
//                            // Issue compiling, maybe DONT use an inout parameter
//                            // labeler.moveBox(&boundBox, by: gestureValue, on: image, at: imgGeometry.size)
//                            print("Moved by \(gestureValue)")
//                        }))
                }
                
            }
            
            
        }
    }
}
