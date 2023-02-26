//
//  BoundingBox.swift
//  ML Label
//
//  Created by Martin Castro on 7/29/22.
//

import SwiftUI
import Vision

enum NodePosition {
    case top
    case bottom
    case left
    case right
}

/// A view for vizualizing and editing a bounding box annotation
///
/// If the editing mode is set to `rectEnabled` you can recieve updates to gestures detected on the editing nodes
struct BoundingBox: View {
    
    @EnvironmentObject var mlSet: MLSet
    @EnvironmentObject var userSelections: UserSelections
    
    @ObservedObject var annotation: MLBoundingBox
    
    var cgRect: CGRect
    var color: Color{
        mlSet.classes.first(where: {$0.label == annotation.label})?.color.toColor() ?? .gray
    }
    var mlImage: MLImage
    var imageCGSize: CGSize
    
    @State private var isEditing: Bool = false
    @State private var editingRect: CGRect = CGRect()
    
    var body: some View {
  
        if isEditing {
            RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                .path(in: editingRect)
                .stroke(color, style: StrokeStyle(lineWidth: 1, lineCap: .round, dash: [5,10]))
        }
        
        ZStack{
            //Fill
            RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                .path(in: cgRect)
                .fill(color)
                .opacity(userSelections.mlBox?.id == annotation.id ? 0.25 : 0.10)
                .allowsHitTesting(false)
            //Stroke
            RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                .path(in: cgRect)
                .stroke(color,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round))
                .opacity(userSelections.mlBox?.id == annotation.id ? 1.0 : 0.9)
                .allowsHitTesting(false)
            
            if userSelections.mlBox?.id == annotation.id {
                //Highlight Stroke
                RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                    .path(in: cgRect)
                    .stroke(.white,
                            style: StrokeStyle(lineWidth: 1, lineCap: .round))
                    .allowsHitTesting(false)
                
                //MARK: - Box Editing Nodes

                let nodeHandle = Circle()
                    .foregroundColor(color)
                    .frame(width: 8, height: 8)
                    .overlay(Circle().foregroundColor(.white).frame(width: 7, height: 7))
                
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
                                editingRect = CGRect(origin: newOrigin, size: newSize)
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
                                editingRect = CGRect(origin: cgRect.origin, size: newSize)
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
                                editingRect = CGRect(origin: newOrigin, size: newSize)
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
                                editingRect = CGRect(origin: cgRect.origin, size: newSize)
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
                    .foregroundColor(.white)
                    .font(.headline)
    
            }
            
            
        }//END BOX ZSTACK
        .opacity(isEditing ? 0.5 : 1)
    
    }
}

//MARK: - BoundingBoxTagView
struct BoundingBoxTagView: View {
    
    @EnvironmentObject var mlSet: MLSet
    @EnvironmentObject var userSelections: UserSelections
    
    @ObservedObject var annotation: MLBoundingBox
    @ObservedObject var mlImage: MLImage
    
    var color: Color{
        mlSet.classes.first(where: {$0.label == annotation.label})?.color.toColor() ?? .gray
    }
    
    @State var opacity: CGFloat = 1
    
    var body: some View {
        
            HStack{
                Text("\(annotation.label)")
                    .font(.caption)
                    .foregroundColor(.white)
                if userSelections.mode == .removeEnabled {
                    Image(systemName: "xmark")
                }
    
            
        }//END VSTACK
        .padding(3)
        .frame(minWidth: 40)
        .background(color)
        .clipShape(RoundedRectangle(cornerRadius: 5))
        .onHover { isHovering in
            if isHovering {
                opacity = 0.4
            }else{
                opacity = 1
            }
        }
        .onTapGesture {
            if userSelections.mode == .removeEnabled {
                mlImage.annotations.removeAll(where: {$0.id == annotation.id})
                //Also remove instance from MLClass
                if let mlClass = mlSet.classes.first(where: {$0.label == annotation.label}){
                    mlClass.removeInstance(mlImage: mlImage, boundingBox: annotation) // FIX THIS
                }
            }
            userSelections.mlBox = annotation
        }
        .opacity(opacity)
        
    }
}
