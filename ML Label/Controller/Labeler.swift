//
//  Labeler.swift
//  ML Label
//
//  Created by Martin Castro on 3/10/22.
//

import SwiftUI

struct Labeler {
    
    // Annotations are created in CreateML Format: X and Y are the center of the bounding boxes, with a width and height, all measured from the top left corner.
    
    public func addBox(from gesture: DragGesture.Value, at currentSize: CGSize,
                       with label: String, on image: MLImage) {
        
        var widthRatio: CGFloat
        var heightRatio: CGFloat
        var xRatio: CGFloat
        var yRatio: CGFloat
        
        var gestureEndLocation = gesture.location
        
        // Adjusts gesture bounds if they fall out of frame
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
        
        // Finds ratio of gesture to total image dimensions
        widthRatio = abs(gestureEndLocation.x - gesture.startLocation.x) / currentSize.width
        heightRatio = abs(gestureEndLocation.y - gesture.startLocation.y) / currentSize.height
        
        
        // Calculates the bounding box X & Y ratios in the center of the drag gesture.
        xRatio = ((gestureEndLocation.x + gesture.startLocation.x) / 2) / currentSize.width
        yRatio = ((gestureEndLocation.y + gesture.startLocation.y) / 2) / currentSize.height
        
        // Multiplies our ratios by pixel dimensions to calculate bounding box
        
        let boundingBox = MLAnnotation(label: label,
                                       coordinates: MLCoordinates(x: Int(xRatio * CGFloat(image.width)),
                                                                  y: Int(yRatio * CGFloat(image.height)),
                                                                  width: Int(widthRatio * CGFloat(image.width)),
                                                                  height: Int(heightRatio * CGFloat(image.height))))

        image.annotations.append(boundingBox)
        // Also appends box to the ClassData's annotation array
//        label.annotations.append(boundingBox)
        print(boundingBox)
    }
    

    public func removeBox(_ box: MLAnnotation, from image: inout MLImage) {
        image.annotations.removeAll { mlBox in
            mlBox.id == box.id
        }
    }
    
    
//    public func moveBox(_ box: MLBoundBox, by gesture: DragGesture.Value,
//                        on image: inout ImageData, at currentSize: CGSize){
//
//        var gestureEndLocation = gesture.location
//
//        var widthRatio: CGFloat
//        var heightRatio: CGFloat
//
//
//        // Adjusts gesture bounds if they fall out of frame
//        if gestureEndLocation.x > currentSize.width {
//            gestureEndLocation = CGPoint(x: currentSize.width, y: gestureEndLocation.y)
//        }
//        if gestureEndLocation.x < 0 {
//            gestureEndLocation = CGPoint(x: 0, y: gestureEndLocation.y)
//        }
//        if gestureEndLocation.y > currentSize.height {
//            gestureEndLocation = CGPoint(x: gestureEndLocation.x, y: currentSize.height)
//        }
//        if gestureEndLocation.y < 0 {
//            gestureEndLocation = CGPoint(x: gestureEndLocation.x, y: 0)
//        }
//
//        // Find ratios of gesture to total image dimensions
//        widthRatio = (gestureEndLocation.x - gesture.startLocation.x) / currentSize.width
//        heightRatio = (gestureEndLocation.y - gesture.startLocation.y) / currentSize.height
//
//        //Transfom MLBoundBox coordinates
//        box.x += Int(widthRatio * CGFloat(image.width))
//        box.y += Int(heightRatio * CGFloat(image.height))
//
//    }
    
    
}
