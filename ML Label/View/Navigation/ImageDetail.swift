//
//  ImageDetail.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import SwiftUI

struct ImageDetail: View {
    
    
    @ObservedObject var image: ImageData
    @EnvironmentObject var classStore: ClassStore
    
    // Used for calculating bounding box from drag gesture
    @Binding var selectedClassLabel: ClassData
    @State private var cgSize = CGSize()
    
    // Used for drawing a preview bound box during gesture
    @State var showBoxPreview = false
    @State var boxPreview = CGRect()
    
    @State var scale: CGFloat = 0.96
    
    // Labeler class contains functions for annotations
    var labeler = Labeler()
    
    var body: some View {
        
            image.image
                .resizable()
                .scaledToFit()
                
                // Reports current size via SizeReader class
                .sizeReader(size: $cgSize)
                
                // MARK: - Drag Gesture
                
                // Drag gesture used to to create bounding box. Disabled if class selection is still default option.
                .gesture(DragGesture(minimumDistance: 5, coordinateSpace: .local)
                            
                            // Sets the preview box during drag gesture
                            .onChanged({ gesture in
                                boxPreview = CGRect(
                                    x: gesture.startLocation.x,
                                    y: gesture.startLocation.y,
                                    width: gesture.location.x - gesture.startLocation.x,
                                    height: gesture.location.y - gesture.startLocation.y)
                                
                                showBoxPreview = true
                            })
                            
                            // Creates annotation and disables the preview box on gesture end
                            .onEnded({ gesture in
                                showBoxPreview = false
                                labeler.addAnnotation(from: gesture,
                                                      at: cgSize,
                                                      with: selectedClassLabel,
                                                      on: image)
//                                image.createAnnotation(from: gesture, in: cgSize, with: selectedClassLabel)
                            })
                ).disabled(selectedClassLabel.label == "No Class Labels")
                
                // MARK: - Overlay
                
                // Adds overlay displaying bounding boxes
                .overlay(
                    GeometryReader{ imgGeometry in
                        
                        // Shows box preview during drag gesture
                        if showBoxPreview {
                            RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                                .path(in: boxPreview)
                                .stroke(selectedClassLabel.color, style: StrokeStyle(lineWidth: 3,
                                                                                     lineCap: .round, dash: [5,10]))
                        }
                        // Overlay for each bounding box
                        ForEach(image.annotations, id: \.id) { boundBox in
                            
                            // Caclculate Bounding box placement using ratios.
                            // CGRect Paths are drawn from TOP LEFT corner
                            let x = (imgGeometry.size.width/CGFloat(image.width)) * CGFloat(boundBox.x - boundBox.width/2)
                            let y = (imgGeometry.size.height/CGFloat(image.height)) * CGFloat(boundBox.y-boundBox.height/2)
                            let width = (imgGeometry.size.width/CGFloat(image.width)) * CGFloat(boundBox.width)
                            let height = (imgGeometry.size.height/CGFloat(image.height)) * CGFloat(boundBox.height)
                            
                            // Displays an opacity overlay with a dashed stroke
                            ZStack{
                                RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                                    .path(in: CGRect(x: x, y: y, width: width, height: height))
                                    .fill(boundBox.label.color.opacity(0.3))
                                RoundedRectangle(cornerSize: CGSize(width: 3, height: 3))
                                    .path(in: CGRect(x: x, y: y, width: width, height: height))
                                    .stroke(boundBox.label.color, style: StrokeStyle(lineWidth: 3,
                                                                                     lineCap: .round, dash: [5,10]))
                            }
                            
                            // Adds a label to the box overlay showing label name, height, width, etc.
                            BoxLabel(annotation: boundBox)
                                .position(x: x, y: y)
                            
                        }
                    }
                )
                .scaleEffect(scale)
                .shadow(radius: 10)

            
//MARK: - Toolbar Items
            
            .toolbar{
                
                LabelPicker(selectedClassLabel: $selectedClassLabel)
                    .padding(.horizontal, 10)
                
                
                Button(action: {image.annotations.removeLast()}, label: {
                    Image(systemName: "arrow.uturn.backward").font(.body.weight(.heavy))
                }).disabled(image.annotations.count == 0)
                
                Button(action: {print("Manually add bounding box via window")}, label: {
                    Image(systemName: "plus.rectangle").font(.body.weight(.heavy))
                }).disabled(selectedClassLabel.label == "No Class Labels")
                
                Spacer()
                
                Button(action: {print("Delete")}, label: {
                    Image(systemName: "trash").font(.body.weight(.heavy))
                })
                
                
            }
        
        
    }
}

//struct ImageDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageDetail()
//    }
//}
