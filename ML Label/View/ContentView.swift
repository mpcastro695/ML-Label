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
    
    @State var addEnabled: Bool = true
    @State var removeEnabled: Bool = false
    
    
    
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
                            ImageAnnotatorView(mlImage: imageSelection!, classSelection: classSelection, addEnabled: addEnabled, removeEnabled: removeEnabled, annotationSelection: $annotationSelection)
                        }
                    }//END MAIN VIEW
                    .onDrop(of: [.fileURL], delegate: mlSetDocument)
                    .frame(minHeight: geometry.size.height * 0.75)
                    .layoutPriority(1)
                    
//MARK: - Scroll View
                    ScrollView(.horizontal) {
                        HStack(spacing: 0){
                            ForEach(mlSetDocument.images) { mlImage in
                                ImageThumbnailView(mlImage: mlImage, imageSelection: $imageSelection)
                            }
                        }
                    }// END SCROLLVIEW
                    .frame(minHeight: 60)
                }//END VSPLITVIEW
                .frame(minWidth: geometry.size.width * 0.72)
                
// MARK: - Tool Panels
                VStack{
                    ImageDetailsView(addEnabled: $addEnabled,
                                     removeEnabled: $removeEnabled,
                                     imageSelection: $imageSelection,
                                     classSelection: $classSelection,
                                     annotationSelection: $annotationSelection)
                        .frame(height: geometry.size.height * 0.4)
                    Divider()
                    LabelToolsView(classSelection: $classSelection)
//                        .frame(height: geometry.size.height * 0.6)
                }
                .frame(minWidth: 300)
                
            }//END HSPLITVIEW
            .frame(width: geometry.size.width, height: geometry.size.height)
        }//END GEOMETRY READER
        .frame(minWidth: 1000, minHeight: 600)
        
//MARK: - Top Toolbar
        .toolbar {

            Picker("", selection: $classSelection) {
                ForEach(mlSetDocument.classes, id: \.id) { label in
                    Text("\(label.label)")
                        .foregroundColor(.primary)
                        .tag(label as MLClass?)
                }
            }
            .pickerStyle(DefaultPickerStyle())
            .font(.callout)
            .frame(minWidth: 250)
            .disabled(mlSetDocument.classes.count == 0)
            .disabled(addEnabled == false)
            
            Button("\(Image(systemName: "rectangle.badge.plus"))"){
                removeEnabled = false
                addEnabled = true
            }
            .foregroundColor(addEnabled ? .primary : .secondary)
            .font(addEnabled ? .headline.weight(.black) : .subheadline)
            
            Button("\(Image(systemName: "rectangle.badge.minus"))"){
                addEnabled = false
                removeEnabled = true
            }
            .foregroundColor(removeEnabled ? .primary : .secondary)
            .font(removeEnabled ? .headline.weight(.black) : .subheadline)
            
            Button("\(Image(systemName: "doc.badge.plus")) Export JSON"){
                print("woo")
            }
        }//END TOOLBAR
        .environmentObject(mlSetDocument)
    }//END VIEW BUILDER
}

//struct ContentView2_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView2()
//    }
//}
