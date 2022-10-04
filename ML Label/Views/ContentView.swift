//
//  ContentView.swift
//  ML Label
//
//  Created by Martin Castro on 7/9/22.
//

import SwiftUI

struct ContentView: View {
    
    @ObservedObject var mlSetDocument: MLSetDocument
    
    @State var classSelection: MLClass?
    @State var imageSelection: MLImage?
    @State var annotationSelection: MLBoundingBox?
    
    @State var mode: Mode = .rectEnabled
    
    var body: some View {
        GeometryReader{ geometry in
            HSplitView{
                VSplitView{
//MARK: - Main Pane/Annotation Pane
                    ZStack{
                        if mlSetDocument.images.count == 0 {
                            MissingImages()

                        }else if imageSelection == nil {
                            MissingImageSelection()
                            
                        }else{
                            // Add check to see if image: NSImage? is available
                            ImageAnnotator(mlImage: imageSelection!, classSelection: classSelection, annotationSelection: $annotationSelection, mode: mode)
                        }
                    }//END MAIN VIEW
                    .onDrop(of: [.fileURL], delegate: mlSetDocument)
                    .frame(minHeight: geometry.size.height * 0.7)
                    .layoutPriority(1)
                    
//MARK: - Scroll View
                    ScrollView(.horizontal) {
                        HStack(spacing: 0){
                            ForEach(mlSetDocument.images) { mlImage in
                                ImageThumbnail(mlImage: mlImage, imageSelection: $imageSelection)
                            }
                        }
                    }// END SCROLLVIEW
                    .frame(minHeight: 60, maxHeight: .infinity)
                    
                }//END VSPLITVIEW 1, LEFT
                .frame(minWidth: geometry.size.width * 0.7)
                
// MARK: - Tool Panels
                VSplitView{
                    ImageInformation(imageSelection: $imageSelection,
                                     classSelection: $classSelection,
                                     annotationSelection: $annotationSelection)
                        .frame(minHeight: 200)
                    
                    ClassTools(classSelection: $classSelection)
                        .frame(minHeight: geometry.size.height * 0.5)
                }//END VSPLITVIEW 2
                .frame(minWidth: 300)
                
            }//END HSPLITVIEW
            .frame(width: geometry.size.width, height: geometry.size.height)
        }//END GEOMETRY READER
        .frame(minWidth: 1000, minHeight: 600)
        
//MARK: - Top Toolbar
        .toolbar {

            ToolbarItemGroup(placement: .principal){
                
                Picker("", selection: $classSelection) {
                    ForEach(mlSetDocument.classes, id: \.id) { label in
                        Text("\(label.label)")
                            .foregroundColor(.primary)
                            .tag(label as MLClass?)
                    }
                }
                .pickerStyle(DefaultPickerStyle())
                .font(.callout)
                .frame(minWidth: 300)
                .disabled(mlSetDocument.classes.count == 0)
                .disabled(mode != .rectEnabled)
                
                //Rect Enable Button
                Button("\(Image(systemName: "plus.square.dashed"))"){
                    mode = .rectEnabled
                }
                .foregroundColor(mode == .rectEnabled ? .primary : .secondary)
                .font(mode == .rectEnabled ? .headline.weight(.black) : .none)
                
                // Polygon Enable Button
                Button("\(Image(systemName: "skew"))"){
                    mode = .polyEnabled
                }
                .foregroundColor(mode == .polyEnabled ? .primary : .secondary)
                .font(mode == .polyEnabled ? .headline.weight(.black) : .none)
                
                //Remove Enable Button
                Button("\(Image(systemName: "scissors"))"){
                    mode = .removeEnabled
                }
                .foregroundColor(mode == .removeEnabled ? .primary : .secondary)
                .font(mode == .removeEnabled ? .headline.weight(.black) : .none)
                
                
            }
            
//            ToolbarItem(placement: .status) {
//                Button("\(Image(systemName: "square.and.arrow.up"))"){
//                    print("export annotations")
//                }
//            }
            
        }//END TOOLBAR
        .environmentObject(mlSetDocument)
    }//END VIEW BUILDER
}

enum Mode {
    case rectEnabled
    case polyEnabled
    case removeEnabled
}
