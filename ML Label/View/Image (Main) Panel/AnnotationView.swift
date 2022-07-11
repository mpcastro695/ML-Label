//
//  AnnotationView.swift
//  ML Label
//
//  Created by Martin Castro on 4/19/22.
//

import Vision
import SwiftUI

struct AnnotationView: View {
    
    @EnvironmentObject var mlSet: MLSet
    
    @ObservedObject var mlImage: MLImage
    var classSelection: MLClass?
    
    var addEnabled: Bool = true
    var removeEnabled: Bool = false
    
    @State private var cgSize = CGSize()
    @State private var dragGestureActive: Bool = false
    @State private var previewRect: CGRect = CGRect()
    
    var body: some View {
        Image(nsImage: mlImage.image!)
            .resizable()
            .scaledToFit()

// MARK: - Custom Size Reader
        
            // Reports current size via SizeReader class
            .sizeReader(size: $cgSize)
            
// MARK: - Drag Gesture
        
            .gesture(
                DragGesture(minimumDistance: 5, coordinateSpace: .local)
                    // Enables gesture preview
                    .onChanged({ gesture in
                        previewRect = CGRect(x: gesture.startLocation.x,
                                             y: gesture.startLocation.y,
                                             width: max(0, min(gesture.location.x, cgSize.width)) - gesture.startLocation.x,
                                             height: max(0, min(gesture.location.y, cgSize.height)) - gesture.startLocation.y)
                        dragGestureActive = true
                    })
                    // Creates annotation and disables preview
                    .onEnded({ gesture in
                        mlImage.annotations.append(MLBoundingBoxFromDragGesture(gesture: gesture))
                        dragGestureActive = false
                    })
            ).disabled(classSelection == nil || !addEnabled)
            
        
// MARK: - Bounding Box Overlay
            /// Overlay that displays all the images current annotations
        
            .overlay(
                GeometryReader{ geo in
                    // Draws box during a drag gesture
                    if dragGestureActive {
                        RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                            .path(in: previewRect)
                            .stroke(classSelection!.color.toColor(), style: StrokeStyle(lineWidth: 3,
                                                                        lineCap: .round, dash: [5,10]))
                    }
                    ZStack{
                        ForEach(mlImage.annotations, id: \.id) { boundingBox in
                            let cgRect = CGRectForBoundingBox(boundingBox: boundingBox)
                            let color = mlSet.classes.first(where: {$0.label == boundingBox.label})?.color.toColor() ?? .gray
                            //Fill
                            RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                                .path(in: cgRect)
                                .fill(color)
                                .opacity(0.3)
                            //Stroke
                            RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                                .path(in: cgRect)
                                .stroke(color,
                                        style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [5,10]))
                            // Clicking on the label removes the MLBoundingBox
                            LabelTag(boundingBox: boundingBox, color: color)
                                .position(x: cgRect.minX, y: cgRect.minY)
                                .onTapGesture {
                                    mlImage.annotations.removeAll(where: {$0.id == boundingBox.id})
                                }.disabled(!removeEnabled)
                            
                        }
                    }
                }
            )
        
            .scaleEffect(0.97)
            .shadow(radius: 10)
        
    }
    
//MARK: - Methods
    /// Methods for turning gestures into MLBoundingBox's and back into CGRect coordinates

    private func MLBoundingBoxFromDragGesture (gesture: DragGesture.Value) -> MLBoundingBox {
        
        let origin = gesture.startLocation
        let width = max(0, min(gesture.location.x, cgSize.width)) - gesture.startLocation.x
        let height = max(0, min(gesture.location.y, cgSize.height)) - gesture.startLocation.y
        
        let cgRect = CGRect(origin: origin, size: CGSize(width: width, height: height)).standardized
        
        let normalizedRect = VNNormalizedRectForImageRect(cgRect, Int(cgSize.width), Int(cgSize.height))
        let projectedPixelRect = VNImageRectForNormalizedRect(normalizedRect, mlImage.width, mlImage.height)
        
        return MLBoundingBox(label: classSelection!.label,
                            coordinates: MLCoordinates(x: Int(projectedPixelRect.midX),
                                                       y: Int(projectedPixelRect.midY),
                                                       width: Int(projectedPixelRect.width),
                                                       height: Int(projectedPixelRect.height)))
    }
    
    private func CGRectForBoundingBox(boundingBox: MLBoundingBox) -> CGRect {
        
        let origin = CGPoint(x: boundingBox.coordinates.x - boundingBox.coordinates.width/2,
                             y: boundingBox.coordinates.y - boundingBox.coordinates.height/2)
        let size = CGSize(width: boundingBox.coordinates.width, height: boundingBox.coordinates.height)
        
        let normalizedRect = VNNormalizedRectForImageRect(CGRect(origin: origin, size: size), mlImage.width, mlImage.height)
        
        return VNImageRectForNormalizedRect(normalizedRect, Int(cgSize.width), Int(cgSize.height))
    }
    
}
