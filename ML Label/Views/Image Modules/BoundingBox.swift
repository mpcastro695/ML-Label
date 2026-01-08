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
    case topLeft
    case topRight
    case bottomLeft
    case bottomRight
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
            
            if userSelections.mlBox?.id == annotation.id && userSelections.mode == .editEnabled {
                //Highlight Stroke
                RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                    .path(in: cgRect)
                    .stroke(.white,
                            style: StrokeStyle(lineWidth: 1, lineCap: .round))
                    .allowsHitTesting(false)
                
                // Note: Editing handles are now drawn and managed by MagnificationView (AppKit)
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
        .opacity(opacity)
        
    }
}
