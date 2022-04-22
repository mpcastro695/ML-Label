//
//  AnnotationView.swift
//  ML Label
//
//  Created by Martin Castro on 4/19/22.
//

import SwiftUI

struct AnnotationView: View {
    
    var mlImage: MLImage
    
    @State private var cgSize = CGSize()
    @Binding var selectedClassLabel: MLClass
    
    @State private var showBoxPreview: Bool = false
    @State private var previewRect: CGRect = CGRect()
    
    let labeler = Labeler()
    
    
    var body: some View {
        Image(nsImage: mlImage.image!)
            .resizable()
            .scaledToFit()
            
            // Reports current size via SizeReader class
            .sizeReader(size: $cgSize)
            
            // MARK: - Drag Gesture
            
            // Drag gesture used to to create bounding box. Disabled if class selection is still default option.
            .gesture(DragGesture(minimumDistance: 5, coordinateSpace: .local)
                        
                        // Sets the preview box during drag gesture
                        .onChanged({ gesture in
                            previewRect = CGRect(
                                x: gesture.startLocation.x,
                                y: gesture.startLocation.y,
                                width: gesture.location.x - gesture.startLocation.x,
                                height: gesture.location.y - gesture.startLocation.y)
                            
                            showBoxPreview = true
                        })
                        
                        // Creates annotation and disables the preview box on gesture end
                        .onEnded({ gesture in
                            showBoxPreview = false
                            labeler.addBox(from: gesture,
                                                  at: cgSize,
                                           with: selectedClassLabel.label,
                                                  on: mlImage)
//                                image.createAnnotation(from: gesture, in: cgSize, with: selectedClassLabel)
                        })
            ).disabled(selectedClassLabel.label == "No Class Labels")
            
            // MARK: - Overlay

            // Adds overlay displaying bounding boxes
            .overlay(
                BoxPreviews(image: mlImage, selectedClassLabel: $selectedClassLabel, showDrawingPreview: $showBoxPreview, boxPreview: $previewRect, labeler: labeler)
            )
            .scaleEffect(0.97)
            .shadow(radius: 10)
        
    }
}

//struct AnnotationView_Previews: PreviewProvider {
//    static var previews: some View {
//        AnnotationView()
//    }
//}
