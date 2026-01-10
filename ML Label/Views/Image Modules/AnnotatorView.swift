//
//  ImageAnnotationView.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/22.
//


import SwiftUI
import Vision


@available(macOS 13.0, *)
struct AnnotatorView: View {
    
    @Environment(\.dismiss) var dismiss
    @Environment(\.undoManager) var undoManager
    @EnvironmentObject var mlSetDocument: MLSet
    @EnvironmentObject var userSelections: UserSelections
    
    @ObservedObject var mlImage: MLImage
    
    @State private var cgSize = CGSize()
    @State private var dragGestureActive: Bool = false
    @State private var previewRect: CGRect = CGRect()
    @State private var cursorIsInside: Bool = false
    @State private var cursorPosition: CGPoint = CGPoint()
    
    // Compute the selected bounding box rect for DrawingView
    var selectedBoxRect: CGRect? {
        guard let selectedBox = userSelections.mlBox,
              mlImage.annotations.contains(where: { $0.id == selectedBox.id }) else {
            return nil
        }
        return getCGRectForMLBoundingBox(boundingBox: selectedBox)
    }
    
    var body: some View {
        
        DrawingView(drawEnabled: userSelections.mode == .rectEnabled,
                          editEnabled: userSelections.mode == .editEnabled,
                          selectedRect: selectedBoxRect,
                          contentSize: cgSize,
                          imageSize: CGSize(width: mlImage.width, height: mlImage.height),
                          annotations: mlImage.annotations,
          onDraw: { normalizedRect, isEditing in
            // Handle draw events
            if isEditing {
                // Show preview box
                dragGestureActive = true
                previewRect = VNImageRectForNormalizedRect(normalizedRect, Int(cgSize.width), Int(cgSize.height))
            } else {
                // Add annotation to current MLImage and MLClass
                dragGestureActive = false
                if userSelections.mlClass != nil && userSelections.mode == .rectEnabled{
                    mlImage.addAnnotation(normalizedRect: normalizedRect,
                                          label: userSelections.mlClass!.label)
                    if let newAnnotation = mlImage.annotations.last {
                        userSelections.mlClass!.addInstance(mlImage: mlImage,
                                                            boundingBox: newAnnotation)
                        print(newAnnotation.coordinates)
                    }
                }
            }
        }, onEdit: { normalizedEndPoint, node, isEditing in
            // Handle editing
            if let selectedBox = userSelections.mlBox {
                // Update bounding box dimensions
                selectedBox.changeBoxDimensions(normalizedEndPoint: normalizedEndPoint, node: node, image: mlImage)
                mlImage.update() // Force update to refresh MagnificationView with new rect
            }
            
        }, onTagClick: { annotation in
            if userSelections.mode == .removeEnabled {

                // Delete annotation
                mlImage.annotations.removeAll(where: {$0.id == annotation.id})
                // Remove instance from MLClass
                if let mlClass = mlSetDocument.classes.first(where: {$0.label == annotation.label}){
                    mlClass.removeInstance(mlImage: mlImage, boundingBox: annotation)
                }
                mlImage.update()
                
            }else{
                userSelections.mlBox = annotation
            }
        }) {
            Image(nsImage: NSImage(byReferencing: mlImage.fileURL))
                .resizable()
                .scaledToFit()
                .sizeReader(size: $cgSize)
                .coordinateSpace(name: "cgImageSpace")
                .cursorGuides(cursorIsInside: cursorIsInside, cursorPosition: cursorPosition)
                .cursorTracker() { isInside, position in
                    cursorIsInside = isInside
                    cursorPosition = position
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
                                    let cgRect = getCGRectForMLBoundingBox(boundingBox: annotation)
                                    BoundingBox(annotation: annotation,
                                                    cgRect: cgRect,
                                                    mlImage: mlImage,
                                                    imageCGSize: cgSize)
                                    .zIndex(userSelections.mlBox?.id == annotation.id ? 1 : 0)
                                }
                            }
                            ZStack{ //Bounding box tags
                                ForEach(mlImage.annotations, id: \.id) { annotation in
                                    let cgRect = getCGRectForMLBoundingBox(boundingBox: annotation)
                                    BoundingBoxTagView(annotation: annotation, mlImage: mlImage)
                                        .position(x: cgRect.midX - cgRect.width/2 + 25, y: cgRect.minY + 15)
                                        .zIndex(2)
                                }
                            }.zIndex(2)
                        }
                    }
                )//END BOUNDING BOXES OVERLAY
        }//END DRAWINGVIEW
        .navigationTitle(mlImage.name)
        
        .toolbarRole(.editor)
        .toolbar {
            ToolbarItemGroup {
                Picker("", selection: $userSelections.mlClass) {
                    Text("")
                        .tag(nil as MLClass?)
                    Divider()
                    ForEach(mlSetDocument.classes, id: \.self) { mlClass in
                        Text("\(mlClass.label)")
                            .foregroundColor(.primary)
                            .tag(mlClass as MLClass?)
                    }
                }
                .font(.callout)
                .frame(minWidth: 300)
                .disabled(mlSetDocument.classes.count == 0)
                .disabled(userSelections.mode != .rectEnabled)
                
                //Rect Enable Button
                Button("\(Image(systemName: "plus.rectangle"))"){
                    userSelections.mode = .rectEnabled
                }
                .buttonStyle(.plain)
                .foregroundColor(userSelections.mode == .rectEnabled ? .primary : .secondary)
                .font(userSelections.mode == .rectEnabled ? .headline.weight(.black) : .none)
                .padding(.leading, 20)
                
                //Edit Enable Button
                Button("\(Image(systemName: "crop"))"){
                    userSelections.mode = .editEnabled
                }
                .buttonStyle(.plain)
                .foregroundColor(userSelections.mode == .editEnabled ? .primary : .secondary)
                .font(userSelections.mode == .editEnabled ? .headline.weight(.black) : .none)
                
                // Auto Enable Button
//                Button("\(Image(systemName: "wand.and.stars"))"){
//                    userSelections.mode = .autoEnabled
//                }
//                .buttonStyle(.plain)
//                .foregroundColor(userSelections.mode == .autoEnabled ? .primary : .secondary)
//                .font(userSelections.mode == .autoEnabled ? .headline.weight(.black) : .none)
                
                //Remove Enable Button
                Button("\(Image(systemName: "scissors"))"){
                    userSelections.mode = .removeEnabled
                }
                .buttonStyle(.plain)
                .foregroundColor(userSelections.mode == .removeEnabled ? .primary : .secondary)
                .font(userSelections.mode == .removeEnabled ? .headline.weight(.black) : .none)
                
                //Cursor Guides Enable Button
                Button("\(Image(systemName: "grid"))"){
                    userSelections.cursorGuidesEnabled.toggle()
                }
                .buttonStyle(.plain)
                .foregroundColor(userSelections.cursorGuidesEnabled ? .primary : .secondary)
                .font(userSelections.cursorGuidesEnabled ? .headline.weight(.semibold) : .none)
                
                //Layer overlay enable button
                Button("\(Image(systemName: "square.stack.3d.down.forward"))"){
                    userSelections.showBoundingBoxes.toggle()
                }
                .buttonStyle(.plain)
                .foregroundColor(userSelections.showBoundingBoxes ? .primary : .secondary)
                .font(userSelections.showBoundingBoxes ? .headline.weight(.semibold) : .none)
                .padding(.trailing, 20)
                
                Spacer()
                
                Button("\(Image(systemName: "trash"))") {
                    mlSetDocument.deleteImage(mlImage)
                    dismiss()
                }
                .buttonStyle(.plain)
                .padding()
                       
                
            }//END TOOLBARITEMGROUP
        }//END TOOLBAR
    }
    
    private func getCGRectForMLBoundingBox(boundingBox: MLBoundingBox) -> CGRect {
        let origin = CGPoint(x: boundingBox.coordinates.x - boundingBox.coordinates.width/2,
                             y: boundingBox.coordinates.y - boundingBox.coordinates.height/2)
        let size = CGSize(width: boundingBox.coordinates.width, height: boundingBox.coordinates.height)
        
        let normalizedRect = VNNormalizedRectForImageRect(CGRect(origin: origin, size: size), mlImage.width, mlImage.height)
        
        return VNImageRectForNormalizedRect(normalizedRect, Int(cgSize.width), Int(cgSize.height))
    }
}
