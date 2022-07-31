//
//  AnnotationView.swift
//  ML Label
//
//  Created by Martin Castro on 4/19/22.
//

import Vision
import SwiftUI

struct ImageAnnotatorView: View {
    
    @EnvironmentObject var mlSet: MLSetDocument
    @ObservedObject var mlImage: MLImage
    
    var classSelection: MLClass?
    var addEnabled: Bool = true
    var removeEnabled: Bool = false
    
    @Binding var annotationSelection: MLBoundingBox?
    
    @State private var cgSize = CGSize()
    @State private var dragGestureActive: Bool = false
    @State private var previewRect: CGRect = CGRect()
    
    var body: some View {
        
        if #available(macOS 12.0, *) {
            AsyncImage(url: mlImage.fileURL) { phase in
                if let image = phase.image {
                    // Display the image
                    image
                        .resizable()
                        .scaledToFit()
                        .sizeReader(size: $cgSize)
                        .coordinateSpace(name: "cgImageSpace")
                        .gesture(
                            DragGesture(minimumDistance: 5, coordinateSpace: .named("cgImageSpace"))
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
                        ).disabled(classSelection == nil || !addEnabled)
                        // Bounding Boxes Overlay
                        .overlay(
                            GeometryReader{ geo in
                                // Drag gesture bounding box preview
                                if dragGestureActive {
                                    RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                                        .path(in: previewRect)
                                        .stroke(classSelection!.color.toColor(),
                                                style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5,10]))
                                }
                                // Bounding box for each annotation
                                ForEach(mlImage.annotations, id: \.id) { boundingBox in

                                    BoundingBoxView(boundingBox: boundingBox,
                                                    cgRect: CGRectForBoundingBox(boundingBox: boundingBox),
                                                    mlImage: mlImage,
                                                    imageCGSize: cgSize,
                                                    removeEnabled: removeEnabled,
                                                    annotationSelection: $annotationSelection)
                                }
                            }//END GEOMETRY READER
                        )// END OVERLAY
                        .shadow(radius: 10)
                    
                }else if phase.error != nil {
                    // Indicates an error.
                    Image(systemName: "questionmark.square.dashed")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(0.95) // Indicates an error.
                } else {
                    ProgressView() // Acts as a placeholder.
                }
            }
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
                ).disabled(classSelection == nil || !addEnabled)
                
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
                            ForEach(mlImage.annotations, id: \.id) { boundingBox in
                                
                                let cgRect = CGRectForBoundingBox(boundingBox: boundingBox)

                                BoundingBoxView(boundingBox: boundingBox,
                                                cgRect: cgRect,
                                                mlImage: mlImage,
                                                imageCGSize: cgSize,
                                                removeEnabled: removeEnabled,
                                                annotationSelection: $annotationSelection)
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
    
    private func changeBoxDimensions(box: inout MLBoundingBox, gesture: DragGesture.Value, node: NodePosition) {
        
        // Gesture values
        let endCGPoint = gesture.location
        let endNormalizedPoint = VNNormalizedPointForImagePoint(endCGPoint, Int(cgSize.width), Int(cgSize.height))
        let endPixelPoint = VNImagePointForNormalizedPoint(endNormalizedPoint, mlImage.width, mlImage.height)
        
        
        if node == .top {
            let initialPixelValue = box.coordinates.y - box.coordinates.height/2
            let pixelChange = initialPixelValue - Int(endPixelPoint.y)
            let newCoordinates = MLCoordinates(x: box.coordinates.x,
                                               y: box.coordinates.y - pixelChange/2,
                                               width: box.coordinates.width,
                                               height: box.coordinates.height + pixelChange)
            
            box.coordinates = newCoordinates
        }
        else if node == .bottom {
            let initialPixelValue = box.coordinates.y + box.coordinates.height/2
            let pixelChange = Int(endPixelPoint.y) - initialPixelValue
            let newCoordinates = MLCoordinates(x: box.coordinates.x,
                                               y: box.coordinates.y + pixelChange/2,
                                               width: box.coordinates.width,
                                               height: box.coordinates.height + pixelChange)
            box.coordinates = newCoordinates
        }
        else if node == .left {
            let initialPixelValue = box.coordinates.x - box.coordinates.width/2
            let pixelChange = initialPixelValue - Int(endPixelPoint.x)
            let newCoordinates = MLCoordinates(x: box.coordinates.x - pixelChange/2,
                                               y: box.coordinates.y,
                                               width: box.coordinates.width + pixelChange,
                                               height: box.coordinates.height)
            box.coordinates = newCoordinates
        }
        else if node == .right {
            let initialPixelValue = box.coordinates.x + box.coordinates.width/2
            let pixelChange = Int(endPixelPoint.x) - initialPixelValue
            let newCoordinates = MLCoordinates(x: box.coordinates.x + pixelChange/2,
                                               y: box.coordinates.y,
                                               width: box.coordinates.width + pixelChange,
                                               height: box.coordinates.height)
            box.coordinates = newCoordinates
        }
    }
    
}
