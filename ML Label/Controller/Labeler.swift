//
//  Labeler.swift
//  ML Label
//
//  Created by Martin Castro on 3/10/22.
//

import SwiftUI

/// Class responsible for adding annotations to an image from a draggesture.
struct Labeler {
    
    // MARK:  Annotation Functions
    
    // Annotations are created in CreateML Format: X and Y are the center of the bounding boxes, with a width and height, all measured from the top left corner.
    
    // Add removeAnnotation() func
    
    public func addAnnotation(from gesture: DragGesture.Value,
                              at currentSize: CGSize,
                              with label: ClassData,
                              on image: ImageData) {
        
        var widthRatio: CGFloat
        var heightRatio: CGFloat
        var xRatio: CGFloat
        var yRatio: CGFloat
        
        // Calculate the width and height of our gesture as a ratio of the image dimesnsions.
        var gestureEndLocation = gesture.location
        
        
        // Adjusts gesture bounds if needed
        if gestureEndLocation.x > currentSize.width {
            gestureEndLocation = CGPoint(x: currentSize.width, y: gestureEndLocation.y)
        }
        if gestureEndLocation.x < 0 {
            gestureEndLocation = CGPoint(x: 0, y: gestureEndLocation.y)
        }
        if gestureEndLocation.y > currentSize.height {
            gestureEndLocation = CGPoint(x: gestureEndLocation.x, y: currentSize.height)
        }
        if gestureEndLocation.y < 0 {
            gestureEndLocation = CGPoint(x: gestureEndLocation.x, y: 0)
        }
        
        // Finds ratio of bounding box
        widthRatio = abs(gestureEndLocation.x - gesture.startLocation.x) / currentSize.width
        heightRatio = abs(gestureEndLocation.y - gesture.startLocation.y) / currentSize.height
        
        
        // Calculates the bounding box X & Y ratios in the center of the drag gesture.
        xRatio = ((gestureEndLocation.x + gesture.startLocation.x) / 2) / currentSize.width
        yRatio = ((gestureEndLocation.y + gesture.startLocation.y) / 2) / currentSize.height
        
        // Multiplies our ratios by pixel dimensions for our bounding box
        let boundingBox = MLBoundBox(imageName: image.name,
                                     label: label,
                                     x: Int(xRatio * CGFloat(image.width)),
                                     y: Int(yRatio * CGFloat(image.height)),
                                     width: Int(widthRatio * CGFloat(image.width)),
                                     height: Int(heightRatio * CGFloat(image.height)))
        
        image.annotations.append(boundingBox)
        // Also appends box to the ClassData's annotation array
        label.annotations.append(boundingBox)
        print(boundingBox)
    }
    
}
