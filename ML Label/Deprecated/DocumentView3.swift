////
////  DocumentView3.swift
////  ML Label
////
////  Created by Martin Castro on 11/11/22.
////
//
//import SwiftUI
//
//struct DocumentView3: View {
//    
//    @Binding var mlSetDocument: MLSetDocument
//    @StateObject var userSelections = UserSelections()
//    
//    var body: some View {
//        if #available(macOS 13.0, *) {
//            NavigationSplitView {
//                VStack(alignment: .leading){
//                    Text("Images")
//                        .font(.headline)
//                        .foregroundColor(.secondary)
//                        .padding()
//                    List(mlSetDocument.images, selection: $userSelections.mlImage) { image in
//                        ImageRow(image: image)
//                    }
//                    Divider()
//                    ClassToolsView()
//                }
//                .navigationSplitViewColumnWidth(min: 200,
//                                                ideal: 300)
//            } detail: {
//                ImageAnnotationView()
//                    .onDrop(of: [.fileURL], delegate: mlSetDocument)
//                    .layoutPriority(1)
//            }
//            .toolbar {
//                ToolbarItemGroup(placement: .principal){
//                    
//                    Picker("", selection: $userSelections.mlClass) {
//                        ForEach(mlSetDocument.classes, id: \.id) { label in
//                            Text("\(label.label)")
//                                .foregroundColor(.primary)
//                                .tag(label as MLClass?)
//                        }
//                    }
//                    .font(.callout)
//                    .frame(minWidth: 300)
//                    .disabled(mlSetDocument.classes.count == 0)
//                    .disabled(userSelections.mode != .rectEnabled)
//                    .padding(.trailing, 20)
//                    
//                    //Rect Enable Button
//                    Button("\(Image(systemName: "plus.rectangle"))"){
//                        userSelections.mode = .rectEnabled
//                    }
//                    .foregroundColor(userSelections.mode == .rectEnabled ? .primary : .secondary)
//                    .font(userSelections.mode == .rectEnabled ? .headline.weight(.black) : .none)
//                    
//                    // Auto Enable Button
//                    Button("\(Image(systemName: "wand.and.stars"))"){
//                        userSelections.mode = .autoEnabled
//                    }
//                    .foregroundColor(userSelections.mode == .autoEnabled ? .primary : .secondary)
//                    .font(userSelections.mode == .autoEnabled ? .headline.weight(.black) : .none)
//                    
//                    //Remove Enable Button
//                    Button("\(Image(systemName: "scissors"))"){
//                        userSelections.mode = .removeEnabled
//                    }
//                    .foregroundColor(userSelections.mode == .removeEnabled ? .primary : .secondary)
//                    .font(userSelections.mode == .removeEnabled ? .headline.weight(.black) : .none)
//                    .padding(.trailing, 20)
//                    
//                    //Cursor Guides Enable Button
//                    Button("\(Image(systemName: "grid"))"){
//                        userSelections.cursorGuidesEnabled.toggle()
//                    }
//                    .foregroundColor(userSelections.cursorGuidesEnabled ? .primary : .secondary)
//                    .font(userSelections.cursorGuidesEnabled ? .headline.weight(.semibold) : .none)
//                    
//                    //Layer overlay enable button
//                    Button("\(Image(systemName: "square.stack.3d.down.forward"))"){
//                        userSelections.showBoundingBoxes.toggle()
//                    }
//                    .foregroundColor(userSelections.showBoundingBoxes ? .primary : .secondary)
//                    .font(userSelections.showBoundingBoxes ? .headline.weight(.semibold) : .none)
//                    
//                }//END TOOLBARITEMGROUP
//            }//END TOOLBAR
//            .environmentObject(mlSetDocument)
//            .environmentObject(userSelections)
//            
//        } else {
//            // Fallback on earlier versions
//        }
//
//    }
//}
