//
//  ImageData.swift
//  ML Label
//
//  Created by Martin Castro on 10/16/21.
//

import SwiftUI

//MARK: ImageInfo Data Structure

class ImageData: Identifiable, ObservableObject {
    
    var id = UUID()
    var name: String
    var width: Int
    var height: Int
    
    var image: Image
    
    @Published var annotations: [MLBoundBox]
    
    init(name: String, width: Int, height: Int, image: Image) {
        self.name =  name
        self.width = width
        self.height = height
        self.image = image
        
        self.annotations = []
    }
    
    // MARK:  Annotation Functions
    
    // Annotations are created in CreateML Format: X and Y are the center of the bounding boxes, with a width and height, all measured from the top left corner.
    
    public func createAnnotation(from gesture: DragGesture.Value, in cgSize: CGSize, with label: LabelData) {
        
        var widthRatio: CGFloat
        var heightRatio: CGFloat
        var xRatio: CGFloat
        var yRatio: CGFloat
        
        // Calculate the width and height of our gesture as a ratio of the image dimesnsions.
        var gestureEndLocation = gesture.location
        
        if gestureEndLocation.x > cgSize.width {
            gestureEndLocation = CGPoint(x: cgSize.width, y: gestureEndLocation.y)
        }
        if gestureEndLocation.x < 0 {
            gestureEndLocation = CGPoint(x: 0, y: gestureEndLocation.y)
        }
        if gestureEndLocation.y > cgSize.height {
            gestureEndLocation = CGPoint(x: gestureEndLocation.x, y: cgSize.height)
        }
        if gestureEndLocation.y < 0 {
            gestureEndLocation = CGPoint(x: gestureEndLocation.x, y: 0)
        }
        
        widthRatio = abs(gestureEndLocation.x - gesture.startLocation.x) / cgSize.width
        heightRatio = abs(gestureEndLocation.y - gesture.startLocation.y) / cgSize.height
        
        
        // Calculates the bounding box X & Y ratios in the center of the drag gesture.
        xRatio = ((gestureEndLocation.x + gesture.startLocation.x) / 2) / cgSize.width
        yRatio = ((gestureEndLocation.y + gesture.startLocation.y) / 2) / cgSize.height
        
        // Multiplies our ratios by pixel dimensions for our bounding box
        let boundingBox = MLBoundBox(imageName: self.name,
                                     label: label,
                                     x: Int(xRatio * CGFloat(self.width)),
                                     y: Int(yRatio * CGFloat(self.height)),
                                     width: Int(widthRatio * CGFloat(self.width)),
                                     height: Int(heightRatio * CGFloat(self.height)))
        
        annotations.append(boundingBox)
        // Also appends box to the ClassData's annotation array
        label.annotations.append(boundingBox)
        print(boundingBox)
    }
    
//
//    // 1. Calculates bounding box coordinates as a ratio of the image dimensions
//    private func findBoundingBoxRatios(gesture: DragGesture.Value, cgImageSize: CGSize) -> CGRect {
//
//        var widthRatio: CGFloat
//        var heightRatio: CGFloat
//        var xRatio: CGFloat
//        var yRatio: CGFloat
//
//        // Calculate the bounding box width and height from our gesture as a percentage of image dimesnsions.
//        widthRatio = abs(gesture.location.x - gesture.startLocation.x) / cgImageSize.width
//        heightRatio = abs(gesture.location.y - gesture.startLocation.y) / cgImageSize.height
//
//        // Calculates the bounding box X & Y ratios in the center. CENTER, NOT UPPER LEFT CORNER.
//        xRatio = ((gesture.location.x + gesture.startLocation.x) / 2) / cgImageSize.width
//        yRatio = ((gesture.location.y + gesture.startLocation.y) / 2) / cgImageSize.height
//
//        // Returns a bounding box to be multiplied by pixel dimensions for the TRUE bounding box
//        let boundingBoxRatio = CGRect(x: xRatio, y: yRatio, width: widthRatio, height: heightRatio)
//        return boundingBoxRatio
//    }
//
//
//    // 2. Converts our bounding box ratios to pixels for our annotation.
//    private func convertRatios2PixelBox(ratioBox: CGRect) -> CGRect {
//        let pixelBox = CGRect(x: ratioBox.origin.x * CGFloat(self.width),
//                              y: ratioBox.origin.y * CGFloat(self.height),
//                              width: ratioBox.width * CGFloat(self.width),
//                              height: ratioBox.height * CGFloat(self.height))
//        return pixelBox
//    }
}
