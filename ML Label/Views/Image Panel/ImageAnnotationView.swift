//
//  ImageAnnotationView.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/22.
//

import SwiftUI
import Vision

struct ImageAnnotationView: View {
    
    @EnvironmentObject var mlSetDocument: MLSetDocument
    @EnvironmentObject var userSelections: UserSelections
    
    @State private var cgSize = CGSize()
    @State private var dragGestureActive: Bool = false
    @State private var previewRect: CGRect = CGRect()
    @State private var cursorIsInside: Bool = false
    @State private var cursorPosition: CGPoint = CGPoint()
    
    var body: some View {
        
        if mlSetDocument.images.isEmpty {
            MissingImagesView()
        }else if userSelections.mlImage == nil {
            MissingImageSelectionView()
        }else{
            MagnificationView {
                Image(nsImage: NSImage(byReferencing: userSelections.mlImage!.fileURL))
                    .resizable()
                    .scaledToFit()
                    .coordinateSpace(name: "cgImageSpace")
                    .sizeReader(size: $cgSize)
                    .cursorGuides(cursorIsInside: cursorIsInside, cursorPosition: cursorPosition)
                    .cursorTracker(showGuides: true) { isInside, position in
                        cursorIsInside = isInside
                        cursorPosition = position
                    }
                    .vnRectGesture { isEditing, normalizedRect in
                        if isEditing {
                            dragGestureActive = true
                            previewRect = VNImageRectForNormalizedRect(normalizedRect, Int(cgSize.width), Int(cgSize.height))
                        }else{
                            //Adds annotation to current MLImage and MLClass
                            dragGestureActive = false
                            if userSelections.mlClass != nil && userSelections.mode == .rectEnabled{
                                userSelections.mlImage!.addAnnotation(normalizedRect: normalizedRect,
                                                                      label: userSelections.mlClass!.label)
                                userSelections.mlClass!.addInstance(mlImage: userSelections.mlImage!,
                                                                              boundingBox: userSelections.mlImage!.annotations.last!)
                            }
                        }
                    }
                    .overlay(
                        GeometryReader{ _ in
                            if dragGestureActive { //Bounding box preview
                                RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                                    .path(in: previewRect)
                                    .stroke(userSelections.mlClass?.color.toColor() ?? Color.gray,
                                            style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5,5]))
                            }
                            
                            if userSelections.showBoundingBoxes{
                                ZStack{ // Bounding boxes
                                    ForEach(userSelections.mlImage!.annotations, id: \.id) { annotation in
                                        let cgRect = CGRectForMLBoundingBox(boundingBox: annotation)
                                        BoundingBoxView(annotation: annotation,
                                                        cgRect: cgRect,
                                                        mlImage: userSelections.mlImage!,
                                                        imageCGSize: cgSize)
                                        .zIndex(userSelections.mlBox?.id == annotation.id ? 1 : 0)
                                    }
                                }
                                ZStack{ //Bounding box tags
                                    ForEach(userSelections.mlImage!.annotations, id: \.id) { annotation in
                                        let cgRect = CGRectForMLBoundingBox(boundingBox: annotation)
                                        BoundingBoxTagView(annotation: annotation)
                                            .position(x: cgRect.midX - cgRect.width/2 + 35, y: cgRect.minY + 20)
                                            .onTapGesture {
                                                if userSelections.mode == .removeEnabled {
                                                    userSelections.mlImage!.annotations.removeAll(where: {$0.id == annotation.id})
                                                }else{
                                                    userSelections.mlBox? = annotation
                                                }
                                            }
                                            .zIndex(2)
                                    }
                                }.zIndex(2)
                            }
                        }
                    )//END BOUNDING BOXES OVERLAY
                
            }//END ZOOMABLESCROLLVIEW
        }
    }
    
    private func CGRectForMLBoundingBox(boundingBox: MLBoundingBox) -> CGRect {
        let origin = CGPoint(x: boundingBox.coordinates.x - boundingBox.coordinates.width/2,
                             y: boundingBox.coordinates.y - boundingBox.coordinates.height/2)
        let size = CGSize(width: boundingBox.coordinates.width, height: boundingBox.coordinates.height)
        
        let normalizedRect = VNNormalizedRectForImageRect(CGRect(origin: origin, size: size), userSelections.mlImage!.width, userSelections.mlImage!.height)
        
        return VNImageRectForNormalizedRect(normalizedRect, Int(cgSize.width), Int(cgSize.height))
    }
}


