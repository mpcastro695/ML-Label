//
//  ImageAnnotator.swift
//  ML Label
//
//  Created by Martin Castro on 4/19/22.
//

import Vision
import SwiftUI

struct ImageAnnotator: View {
    
    @EnvironmentObject var mlSet: MLSetDocument
    @ObservedObject var mlImage: MLImage
    
    var classSelection: MLClass?
    @Binding var annotationSelection: MLBoundingBox?
    var mode: Mode
    
    @State private var cgSize = CGSize()
    @State private var dragGestureActive: Bool = false
    @State private var previewRect: CGRect = CGRect()
    
    @State private var cursorIsInside: Bool = false
    @State private var cursorPosition: CGPoint = CGPoint()
    
    var body: some View {
        
        if #available(macOS 12.0, *) {
            AsyncImage(url: mlImage.fileURL) { phase in
                if let image = phase.image {
                    // Display the image
                    image
                        .resizable()
                        .scaledToFit()
                        .sizeReader(size: $cgSize)
                        .cursorTracker({ isInside, position in
                            cursorIsInside = isInside
                            cursorPosition = position
                        })
                        .cursorGuides(cursorIsInside: cursorIsInside, cursorPosition: cursorPosition)
                        .coordinateSpace(name: "cgImageSpace")
                        .gesture(
                            DragGesture(minimumDistance: 5, coordinateSpace: .named("cgImageSpace"))
                                // Enables gesture preview
                                .onChanged({ gesture in
                                    NSApp.windows.forEach { $0.disableCursorRects() }
                                    previewRect = CGRect(x: gesture.startLocation.x,
                                                         y: gesture.startLocation.y,
                                                         width: max(0, min(gesture.location.x, cgSize.width)) - gesture.startLocation.x,
                                                         height: max(0, min(gesture.location.y, cgSize.height)) - gesture.startLocation.y)
                                    dragGestureActive = true
                                })
                                // Creates annotation from gesture value and disables preview
                                .onEnded({ gesture in
                                    NSApp.windows.forEach { $0.enableCursorRects() }
                                    let boundingBox = MLBoundingBoxForDragGesture(gesture: gesture)
                                    mlImage.annotations.append(boundingBox)
                                    classSelection?.annotations.append(boundingBox)
                                    annotationSelection = boundingBox
                                    dragGestureActive = false
                                })
                        ).disabled(classSelection == nil || mode != .rectEnabled)
                    
                        // Bounding Boxes Overlay
                        .overlay(
                            GeometryReader{ _ in
                                if dragGestureActive { //Bounding box preview
                                    RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                                        .path(in: previewRect)
                                        .stroke(classSelection!.color.toColor(),
                                                style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5,5]))
                                }
                                ZStack{ // Bounding boxes
                                    ForEach(mlImage.annotations, id: \.id) { annotation in
                                        let cgRect = CGRectForBoundingBox(boundingBox: annotation)
                                        BoundingBox(annotation: annotation,
                                                    cgRect: cgRect,
                                                    mlImage: mlImage,
                                                    imageCGSize: cgSize,
                                                    annotationSelection: annotationSelection,
                                                    mode: mode)
                                        .zIndex(annotation.id == annotationSelection?.id ? 1 : 0)
                                        
                                    }
                                    
                                }
                                ZStack{ //Bounding box tags
                                    ForEach(mlImage.annotations, id: \.id) { annotation in
                                        let cgRect = CGRectForBoundingBox(boundingBox: annotation)
                                        BoundingBoxTag(annotation: annotation, annotationSelection: $annotationSelection, mode: mode)
                                            .position(x: cgRect.midX - cgRect.width/2 + 35, y: cgRect.minY + 20)
                                            .onTapGesture {
                                                if mode == .removeEnabled {
                                                    mlImage.annotations.removeAll(where: {$0.id == annotation.id})
                                                }else{
                                                    annotationSelection = annotation
                                                }
                                            }
                                            .zIndex(2)
                                    }
                                }.zIndex(2)
                        
                            }//END GEOMETRY READER
                        )// END OVERLAY
                        .shadow(radius: 10)
                    
                }else if phase.error != nil {
                    // Indicates an error.
                    Image(systemName: "questionmark.square.dashed")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.95)
                } else {
                    // Acts as a placeholder.
                    ProgressView()
                }
            }//END ASYNC IMAGE
            
        } else {
            Image(nsImage: NSImage(contentsOf: mlImage.fileURL)!)
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
                            let boundingBox = MLBoundingBoxForDragGesture(gesture: gesture)
                            mlImage.annotations.append(boundingBox)
                            classSelection?.annotations.append(boundingBox)
                            annotationSelection = boundingBox
                            dragGestureActive = false
                        })
                ).disabled(classSelection == nil || mode != .rectEnabled)
                
    // MARK: - Bounding Boxes Overlay
            
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
                            ForEach(mlImage.annotations, id: \.id) { annotation in

                                BoundingBox(annotation: annotation,
                                                cgRect: CGRectForBoundingBox(boundingBox: annotation),
                                                mlImage: mlImage,
                                                imageCGSize: cgSize,
                                                annotationSelection: annotationSelection,
                                                mode: mode)
                            }//END FOREACH
                        }//END ZSTACK
                    }
                )
                .shadow(radius: 10)
        }
        // Fallback on earlier versions
        
    }
    
//MARK: - Methods
    /// Methods for turning gestures into MLBoundingBox's and back into CGRect coordinates

    private func MLBoundingBoxForDragGesture (gesture: DragGesture.Value) -> MLBoundingBox {
        
        // MLBoundingBoxes are in COREML coordinate space (upper left to lower right)
        // CGRects (in SwiftUI) have a similar coordinate space (upper left to lower right)
        
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
        
        // MLBoundingBoxes are in COREML coordinate space (upper left coordinate origin, rect origin in center)
        // CGRects (in SwiftUI) have a similar coordinate space (upper left coordinate origin, upper left rect origin)
        
        let origin = CGPoint(x: boundingBox.coordinates.x - boundingBox.coordinates.width/2,
                             y: boundingBox.coordinates.y - boundingBox.coordinates.height/2)
        let size = CGSize(width: boundingBox.coordinates.width, height: boundingBox.coordinates.height)
        
        let normalizedRect = VNNormalizedRectForImageRect(CGRect(origin: origin, size: size), mlImage.width, mlImage.height)
        
        return VNImageRectForNormalizedRect(normalizedRect, Int(cgSize.width), Int(cgSize.height))
    }
    
}
