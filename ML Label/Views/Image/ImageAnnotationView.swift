//
//  ImageAnnotationView.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/22.
//

import SwiftUI
import Vision

@available(macOS 13.0, *)
struct AnnotationView: View {
    
    @EnvironmentObject var mlSetDocument: MLSetDocument
    @EnvironmentObject var userSelections: UserSelections
    
    @ObservedObject var mlImage: MLImage
    
    @State private var cgSize = CGSize()
    @State private var dragGestureActive: Bool = false
    @State private var previewRect: CGRect = CGRect()
    @State private var cursorIsInside: Bool = false
    @State private var cursorPosition: CGPoint = CGPoint()
    
    var body: some View {
        
        MagnificationView {
            Image(nsImage: NSImage(byReferencing: mlImage.fileURL))
                .resizable()
                .scaledToFit()
                .coordinateSpace(name: "cgImageSpace")
                .sizeReader(size: $cgSize)
                .cursorGuides(cursorIsInside: cursorIsInside, cursorPosition: cursorPosition)
                .cursorTracker(showGuides: true) { isInside, position in
                    cursorIsInside = isInside
                    cursorPosition = position
                }
                .vnRectGesture { normalizedRect, isEditing in
                    if isEditing {
                        dragGestureActive = true
                        previewRect = VNImageRectForNormalizedRect(normalizedRect, Int(cgSize.width), Int(cgSize.height))
                    }else{
                        //Adds annotation to current MLImage and MLClass
                        dragGestureActive = false
                        if userSelections.mlClass != nil && userSelections.mode == .rectEnabled{
                            mlImage.addAnnotation(normalizedRect: normalizedRect,
                                                  label: userSelections.mlClass!.label)
                            userSelections.mlClass!.addInstance(mlImage: mlImage,
                                                                boundingBox: mlImage.annotations.last!)
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
                                ForEach(mlImage.annotations, id: \.id) { annotation in
                                    let cgRect = CGRectForMLBoundingBox(boundingBox: annotation)
                                    BoundingBoxView(annotation: annotation,
                                                    cgRect: cgRect,
                                                    mlImage: mlImage,
                                                    imageCGSize: cgSize)
                                    .zIndex(userSelections.mlBox?.id == annotation.id ? 1 : 0)
                                }
                            }
                            ZStack{ //Bounding box tags
                                ForEach(mlImage.annotations, id: \.id) { annotation in
                                    let cgRect = CGRectForMLBoundingBox(boundingBox: annotation)
                                    BoundingBoxTagView(annotation: annotation, mlImage: mlImage)
                                        .position(x: cgRect.midX - cgRect.width/2 + 25, y: cgRect.minY + 15)
                                        .onTapGesture {
                                            if userSelections.mode == .removeEnabled {
                                                mlImage.annotations.removeAll(where: {$0.id == annotation.id})
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
        }//END MAGNIFICATIONVIEW
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItemGroup{
                Picker("", selection: $userSelections.mlClass) {
                    ForEach(mlSetDocument.classes, id: \.id) { label in
                        Text("\(label.label)")
                            .foregroundColor(.primary)
                            .tag(label as MLClass?)
                    }
                }
                .font(.callout)
                .frame(minWidth: 300)
                .disabled(mlSetDocument.classes.count == 0)
                .disabled(userSelections.mode != .rectEnabled)
                .padding(.trailing, 20)
                
                //Rect Enable Button
                Button("\(Image(systemName: "plus.rectangle"))"){
                    userSelections.mode = .rectEnabled
                }
                .foregroundColor(userSelections.mode == .rectEnabled ? .primary : .secondary)
                .font(userSelections.mode == .rectEnabled ? .headline.weight(.black) : .none)
                
                // Auto Enable Button
                Button("\(Image(systemName: "wand.and.stars"))"){
                    userSelections.mode = .autoEnabled
                }
                .foregroundColor(userSelections.mode == .autoEnabled ? .primary : .secondary)
                .font(userSelections.mode == .autoEnabled ? .headline.weight(.black) : .none)
                
                //Remove Enable Button
                Button("\(Image(systemName: "scissors"))"){
                    userSelections.mode = .removeEnabled
                }
                .foregroundColor(userSelections.mode == .removeEnabled ? .primary : .secondary)
                .font(userSelections.mode == .removeEnabled ? .headline.weight(.black) : .none)
                .padding(.trailing, 20)
                
                //Cursor Guides Enable Button
                Button("\(Image(systemName: "grid"))"){
                    userSelections.cursorGuidesEnabled.toggle()
                }
                .foregroundColor(userSelections.cursorGuidesEnabled ? .primary : .secondary)
                .font(userSelections.cursorGuidesEnabled ? .headline.weight(.semibold) : .none)
                
                //Layer overlay enable button
                Button("\(Image(systemName: "square.stack.3d.down.forward"))"){
                    userSelections.showBoundingBoxes.toggle()
                }
                .foregroundColor(userSelections.showBoundingBoxes ? .primary : .secondary)
                .font(userSelections.showBoundingBoxes ? .headline.weight(.semibold) : .none)
                .padding(.trailing, 40)
                
                Button("\(Image(systemName: "trash"))") {
                    print("delete Image!")
                }
                       
                
            }//END TOOLBARITEMGROUP
        }//END TOOLBAR
    }
    
    private func CGRectForMLBoundingBox(boundingBox: MLBoundingBox) -> CGRect {
        let origin = CGPoint(x: boundingBox.coordinates.x - boundingBox.coordinates.width/2,
                             y: boundingBox.coordinates.y - boundingBox.coordinates.height/2)
        let size = CGSize(width: boundingBox.coordinates.width, height: boundingBox.coordinates.height)
        
        let normalizedRect = VNNormalizedRectForImageRect(CGRect(origin: origin, size: size), mlImage.width, mlImage.height)
        
        return VNImageRectForNormalizedRect(normalizedRect, Int(cgSize.width), Int(cgSize.height))
    }
}


