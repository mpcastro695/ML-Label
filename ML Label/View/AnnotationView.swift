//
//  AnnotationView.swift
//  ML Label
//
//  Created by Martin Castro on 4/19/22.
//

import Vision
import SwiftUI

struct AnnotationView: View {
    
    @ObservedObject var mlImage: MLImage
    
    @Binding var selectedClassLabel: MLClass
    @EnvironmentObject var mlSet: MLSet
    
    @State private var showBoxPreview: Bool = false
    @State private var previewRect: CGRect = CGRect()
    @State private var cgSize = CGSize()
    
    var body: some View {
        Image(nsImage: mlImage.image!)
            .resizable()
            .scaledToFit()
            
            // Reports current size via SizeReader class
            .sizeReader(size: $cgSize)
            
// MARK: - Drag Gesture
            
            // Used to to create bounding box.
            // Disabled if no class labels.
            .gesture(
                DragGesture(minimumDistance: 5, coordinateSpace: .local)
                        
                // Sets and enables preview
                .onChanged({ gesture in
                    previewRect = CGRect(x: gesture.startLocation.x,
                                         y: gesture.startLocation.y,
                                         width: max(0, min(gesture.location.x, cgSize.width)) - gesture.startLocation.x,
                                         height: max(0, min(gesture.location.y, cgSize.height)) - gesture.startLocation.y)
                    showBoxPreview = true
                })
                
                // Creates annotation and disables preview
                .onEnded({ gesture in
                    mlImage.annotations.append(MLBoundingBoxFromDragGesture(gesture: gesture))
                    showBoxPreview = false
                })
            ).disabled(selectedClassLabel.label == "No Class Labels")
            
        
// MARK: - Overlay

            // Overlay displaying bounding boxes
            .overlay(
                GeometryReader{ geo in
                    
                    // For drag preview
                    if showBoxPreview {
                        RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                            .path(in: previewRect)
                            .stroke(selectedClassLabel.color.toColor(), style: StrokeStyle(lineWidth: 3,
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
                            PreviewLabel(boundingBox: boundingBox, color: color)
                                .position(x: cgRect.minX, y: cgRect.minY)
                                .onTapGesture {
                                    mlImage.annotations.removeAll(where: {$0.id == boundingBox.id})
                                }
                            
                        }
                    }
                }
            )
        
            .scaleEffect(0.97)
            .shadow(radius: 10)
        
    }
    
//MARK: - Methods
    
    private func MLBoundingBoxFromDragGesture (gesture: DragGesture.Value) -> MLBoundingBox {
        
        let origin = gesture.startLocation
        let width = max(0, min(gesture.location.x, cgSize.width)) - gesture.startLocation.x
        let height = max(0, min(gesture.location.y, cgSize.height)) - gesture.startLocation.y
        
        let cgRect = CGRect(origin: origin, size: CGSize(width: width, height: height)).standardized
        
        let normalizedRect = VNNormalizedRectForImageRect(cgRect, Int(cgSize.width), Int(cgSize.height))
        let projectedPixelRect = VNImageRectForNormalizedRect(normalizedRect, mlImage.width, mlImage.height)
        
        return MLBoundingBox(label: selectedClassLabel.label,
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

//struct AnnotationView_Previews: PreviewProvider {
//    static var previews: some View {
//        AnnotationView()
//    }
//}
