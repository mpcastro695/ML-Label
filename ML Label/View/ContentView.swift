//
//  ContentView.swift
//  ML Label
//
//  Created by Martin Castro on 7/9/22.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var mlSet: MLSet
    
    @State var classSelection: MLClass?
    @State var imageSelection: MLImage?
    
    @State var addEnabled: Bool = true
    @State var removeEnabled: Bool = false
    
    var body: some View {
        GeometryReader{ geometry in
            HSplitView{
                VSplitView{
//MARK: - Main Pane/Annotation Pane
                    ZStack{
                        if mlSet.images.count == 0 {
                            MissingImages()
                            
                        }else if imageSelection == nil {
                            MissingImageSelection()
                            
                        }else{
                            // Add check to see if image: NSImage? is available
                            AnnotationView(mlImage: imageSelection!, classSelection: classSelection, addEnabled: addEnabled, removeEnabled: removeEnabled)
                        }
                    }
                    .onDrop(of: [.fileURL], delegate: mlSet)
                    .frame(minHeight: geometry.size.height * 0.7)
                    .layoutPriority(1)
//MARK: - Scroll View
                    ScrollView(.horizontal) {
                        HStack{
                            ForEach(mlSet.images) { mlImage in
                                if let image = mlImage.image {
                                    Image(nsImage: image)
                                        .resizable()
                                        .scaledToFit()
                                        .scaleEffect(0.95)
                                        .onTapGesture {
                                            imageSelection = mlImage
                                        }
                                }
                            }
                        }
                    }
                    .frame(minHeight: geometry.size.height * 0.12, maxHeight: .infinity)
                }//END VSPLITVIEW
                .frame(minWidth: geometry.size.width * 0.72)
                
// MARK: - Tool Panel
                
                VStack{
                    ImageDetails(addEnabled: $addEnabled, removeEnabled: $removeEnabled, imageSelection: $imageSelection, classSelection: $classSelection)
                    Divider()
                    Text("\(Image(systemName: "tag")) Tags")
                        .font(.headline)
                        .padding()
                    LabelTools(classSelection: $classSelection)
                }
                .frame(minWidth: 300)
                
            }//END HSPLITVIEW
            .frame(width: geometry.size.width, height: geometry.size.height)
            
        }//END GEOMETRY READER
        .frame(minWidth: 1000, minHeight: 600)
        
//MARK: - Toolbar
        .toolbar {

            Picker("", selection: $classSelection) {
                ForEach(mlSet.classes, id: \.id) { label in
                    Text("\(label.label)")
                        .foregroundColor(.primary)
                        .tag(label as MLClass?)
                }
            }
            .pickerStyle(DefaultPickerStyle())
            .font(.callout)
            .frame(minWidth: 250)
            .disabled(mlSet.classes.count == 0)
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
        }
    }
}

//struct ContentView2_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView2()
//    }
//}
