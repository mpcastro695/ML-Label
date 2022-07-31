//
//  BoundingBoxView.swift
//  ML Label
//
//  Created by Martin Castro on 7/29/22.
//

import SwiftUI
import Vision

struct BoundingBoxView: View {
    
    @EnvironmentObject var mlSet: MLSetDocument
    @ObservedObject var boundingBox: MLBoundingBox
    
    var cgRect: CGRect
    var color: Color{
        mlSet.classes.first(where: {$0.label == boundingBox.label})?.color.toColor() ?? .gray
    }
    var mlImage: MLImage
    var imageCGSize: CGSize
    
    var removeEnabled: Bool
    
    @Binding var annotationSelection: MLBoundingBox?
    
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
                .opacity(annotationSelection?.id == boundingBox.id ? 0.25 : 0.10)
                .onTapGesture {
                    annotationSelection = boundingBox
                }
            //Stroke
            RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                .path(in: cgRect)
                .stroke(color,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .opacity(annotationSelection?.id == boundingBox.id ? 1.0 : 0.9)
            
//MARK: - Box Editing Nodes
            
            if annotationSelection?.id == boundingBox.id {
                //Editing Nodes
                let nodeHandle = Rectangle()
                    .foregroundColor(color)
                    .frame(width: 10, height: 10)
                    .overlay(Rectangle().foregroundColor(.white).frame(width: 6, height: 6))
                
                /// Top, Bottom, Left, Right
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
                                boundingBox.changeBoxDimensions(normalizedEndPoint: normalizedEndPoint, node: .top, image: mlImage)
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
                                boundingBox.changeBoxDimensions(normalizedEndPoint: normalizedEndPoint, node: .bottom, image: mlImage)
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
                                boundingBox.changeBoxDimensions(normalizedEndPoint: normalizedEndPoint, node: .left, image: mlImage)
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
                                boundingBox.changeBoxDimensions(normalizedEndPoint: normalizedEndPoint, node: .right, image: mlImage)
                                mlImage.update()
                                isEditing = false
                            }))
                
                Image(systemName: "scope")
                    .position(x: cgRect.midX, y: cgRect.midY)
                    .font(.headline)
    
                BoundingBoxTagView(boundingBox: boundingBox, color: color, removeEnabled: removeEnabled)
                    .position(x: cgRect.midX, y: cgRect.minY - 35)
                    .onTapGesture {
                        mlImage.annotations.removeAll(where: {$0.id == boundingBox.id})
                    }.disabled(!removeEnabled)
            }
        }//END BOX ZSTACK
        .zIndex(annotationSelection?.id == boundingBox.id ? 1 : 0)
        .opacity(isEditing ? 0.1 : 1)
    
    }
}

//MARK: - Box Tag View

struct BoundingBoxTagView: View {
    
    @ObservedObject var boundingBox: MLBoundingBox
    var color: Color
    
    var removeEnabled: Bool
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            HStack{
                Text("\(boundingBox.label)")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                if removeEnabled {
                    Image(systemName: "xmark")
                }
            }//END HSTACK
            VStack(alignment: .leading){
                HStack{
                    Text("X: \(boundingBox.coordinates.x)")
                    Text("Y: \(boundingBox.coordinates.y)")
                }
                HStack{
                    Text("W: \(boundingBox.coordinates.width)")
                    Text("H: \(boundingBox.coordinates.height)")
                }
            }//END VSTACK
            .font(.caption)
            .foregroundColor(.white)
            
        }//END VSTACK
        .padding(5)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .frame(width: 100, height: 50)
        
    }
}

//MARK: - NodePosition enum
enum NodePosition {
    case top
    case bottom
    case left
    case right
}
