//
//  BoundingBox.swift
//  ML Label
//
//  Created by Martin Castro on 7/29/22.
//

import SwiftUI
import Vision

struct BoundingBox: View {
    
    @EnvironmentObject var mlSet: MLSetDocument
    @ObservedObject var annotation: MLBoundingBox
    
    var cgRect: CGRect
    var color: Color{
        mlSet.classes.first(where: {$0.label == annotation.label})?.color.toColor() ?? .gray
    }
    var mlImage: MLImage
    var imageCGSize: CGSize
    
    var annotationSelection: MLBoundingBox?
    var mode: Mode
    
    @State private var isEditing: Bool = false
    @State private var previewRect: CGRect = CGRect()
    
    var body: some View {
  
        if isEditing {
            RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                .path(in: previewRect)
                .stroke(color, style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5,10]))
        }
        
        ZStack{
            //Fill
            RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                .path(in: cgRect)
                .fill(color)
                .opacity(annotationSelection?.id == annotation.id ? 0.25 : 0.10)
                .allowsHitTesting(false)
            //Stroke
            RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                .path(in: cgRect)
                .stroke(color,
                        style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .opacity(annotationSelection?.id == annotation.id ? 1.0 : 0.9)
                .allowsHitTesting(false)
            
//MARK: - Box Editing Nodes
            
            if annotationSelection?.id == annotation.id {
                
                //Highlight Stroke
                RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                    .path(in: cgRect)
                    .stroke(.white,
                            style: StrokeStyle(lineWidth: 1, lineCap: .round))
                    .allowsHitTesting(false)

                let nodeHandle = Circle()
                    .foregroundColor(color)
                    .frame(width: 10, height: 10)
                    .overlay(Circle().foregroundColor(.white).frame(width: 6, height: 6))
                
                nodeHandle.position(x: cgRect.origin.x + cgRect.width/2, y: cgRect.origin.y) //TOP
                    .gesture(
                        DragGesture(minimumDistance: 1, coordinateSpace: .named("cgImageSpace"))
                            .onChanged({ gesture in
                                /// Note: CGRects have origin in the upper left
                                let cgDelta = (gesture.location.y - cgRect.origin.y) // Up, negative
                                let newOrigin = CGPoint(x: cgRect.origin.x,
                                                        y: cgRect.origin.y + cgDelta)
                                let newSize = CGSize(width: cgRect.width,
                                                     height: cgRect.height - cgDelta)
                                previewRect = CGRect(origin: newOrigin, size: newSize)
                                isEditing = true
                            })
                            .onEnded({ gesture in
                                let normalizedEndPoint = VNNormalizedPointForImagePoint(gesture.location,
                                                                                Int(imageCGSize.width),
                                                                                Int(imageCGSize.height))
                                annotation.changeBoxDimensions(normalizedEndPoint: normalizedEndPoint, node: .top, image: mlImage)
                                mlImage.update()
                                isEditing = false
                            }))

                nodeHandle.position(x: cgRect.origin.x + cgRect.width/2, y: cgRect.origin.y + cgRect.height) //BOTTOM
                    .gesture(
                        DragGesture(minimumDistance: 1, coordinateSpace: .named("cgImageSpace"))
                            .onChanged({ gesture in
                                let cgDelta = (gesture.location.y - (cgRect.origin.y + cgRect.height)) // Down, positive
                                let newSize = CGSize(width: cgRect.width,
                                                     height: cgRect.height + cgDelta)
                                previewRect = CGRect(origin: cgRect.origin, size: newSize)
                                isEditing = true
                            })
                            .onEnded({ gesture in
                                let normalizedEndPoint = VNNormalizedPointForImagePoint(gesture.location,
                                                                            Int(imageCGSize.width),
                                                                            Int(imageCGSize.height))
                                annotation.changeBoxDimensions(normalizedEndPoint: normalizedEndPoint, node: .bottom, image: mlImage)
                                mlImage.update()
                                isEditing = false
                            }))
                
                nodeHandle.position(x: cgRect.origin.x, y: cgRect.origin.y + cgRect.height/2) //LEFT
                    .gesture(
                        DragGesture(minimumDistance: 1, coordinateSpace: .named("cgImageSpace"))
                            .onChanged({ gesture in
                                let cgDelta = (gesture.location.x - cgRect.origin.x) // Left, negative
                                let newOrigin = CGPoint(x: cgRect.origin.x + cgDelta,
                                                        y: cgRect.origin.y)
                                let newSize = CGSize(width: cgRect.width - cgDelta,
                                                     height: cgRect.height)
                                previewRect = CGRect(origin: newOrigin, size: newSize)
                                isEditing = true
                            })
                            .onEnded({ gesture in
                                let normalizedEndPoint = VNNormalizedPointForImagePoint(gesture.location,
                                                                            Int(imageCGSize.width),
                                                                            Int(imageCGSize.height))
                                annotation.changeBoxDimensions(normalizedEndPoint: normalizedEndPoint, node: .left, image: mlImage)
                                mlImage.update()
                                isEditing = false
                            }))
                
                nodeHandle.position(x: cgRect.origin.x + cgRect.width, y: cgRect.origin.y + cgRect.height/2) //RIGHT
                    .gesture(
                        DragGesture(minimumDistance: 1, coordinateSpace: .named("cgImageSpace"))
                            .onChanged({ gesture in
                                let cgDelta = (gesture.location.x - (cgRect.origin.x + cgRect.width)) // Right, positive
                                let newSize = CGSize(width: cgRect.width + cgDelta,
                                                     height: cgRect.height)
                                previewRect = CGRect(origin: cgRect.origin, size: newSize)
                                isEditing = true
                            })
                            .onEnded({ gesture in
                                let normalizedEndPoint = VNNormalizedPointForImagePoint(gesture.location,
                                                                            Int(imageCGSize.width),
                                                                            Int(imageCGSize.height))
                                annotation.changeBoxDimensions(normalizedEndPoint: normalizedEndPoint, node: .right, image: mlImage)
                                mlImage.update()
                                isEditing = false
                            }))
                
                Image(systemName: "scope")
                    .position(x: cgRect.midX, y: cgRect.midY)
                    .font(.headline)
    
            }
            
            
        }//END BOX ZSTACK
        .opacity(isEditing ? 0.5 : 1)
    
    }
}

//MARK: - NodePosition enum
enum NodePosition {
    case top
    case bottom
    case left
    case right
}
