//
//  ContentView.swift
//  ML Label
//
//  Created by Martin Castro on 7/9/22.
//

import SwiftUI

struct DocumentView: View {
    
    @Binding var mlSetDocument: MLSetDocument
    @StateObject var userSelections = UserSelections()
    
    var body: some View {
        GeometryReader{ geometry in
            HSplitView{
                VSplitView{
//MARK: - Main Pane/Annotation Pane
                    ImageAnnotationView()
                    .onDrop(of: [.fileURL], delegate: mlSetDocument)
                    .frame(minHeight: geometry.size.height * 0.7)
                    .layoutPriority(1)
                    
//MARK: - Gallery View
                    ImageGalleryView()
                    .frame(minHeight: 60, maxHeight: .infinity)
                    
                }//END LEFT VSPLITVIEW
                .frame(minWidth: geometry.size.width * 0.7)
                
// MARK: - Tool Panels
                VSplitView{
                    ImageDetailView()
                        .frame(minHeight: 200)
                    
                    ClassToolsView(classSelection: $userSelections.mlClass)
                        .frame(minHeight: geometry.size.height * 0.5)
                    
                }//END RIGHT VSPLITVIEW
                .frame(minWidth: 300)
                
            }//END HSPLITVIEW
            .frame(width: geometry.size.width, height: geometry.size.height)
        }//END GEOMETRY READER
        .frame(minWidth: 1000, minHeight: 600)
        
//MARK: - Top Toolbar
        .toolbar {

            ToolbarItemGroup(placement: .principal){
                
                Picker("", selection: $userSelections.mlClass) {
                    ForEach(mlSetDocument.classes, id: \.id) { label in
                        Text("\(label.label)")
                            .foregroundColor(.primary)
                            .tag(label as MLClass?)
                    }
                }
                .font(.callout)
                .frame(minWidth: 300)
                .disabled(mlSetDocument.classes.count == 0)
                .disabled(userSelections.mode != .rectEnabled)
                .padding(.trailing, 20)
                
                //Rect Enable Button
                Button("\(Image(systemName: "plus.rectangle"))"){
                    userSelections.mode = .rectEnabled
                }
                .foregroundColor(userSelections.mode == .rectEnabled ? .primary : .secondary)
                .font(userSelections.mode == .rectEnabled ? .headline.weight(.black) : .none)
                
                // Auto Enable Button
                Button("\(Image(systemName: "wand.and.stars"))"){
                    userSelections.mode = .autoEnabled
                }
                .foregroundColor(userSelections.mode == .autoEnabled ? .primary : .secondary)
                .font(userSelections.mode == .autoEnabled ? .headline.weight(.black) : .none)
                
                //Remove Enable Button
                Button("\(Image(systemName: "scissors"))"){
                    userSelections.mode = .removeEnabled
                }
                .foregroundColor(userSelections.mode == .removeEnabled ? .primary : .secondary)
                .font(userSelections.mode == .removeEnabled ? .headline.weight(.black) : .none)
                .padding(.trailing, 20)
                
                //Cursor Guides Enable Button
                Button("\(Image(systemName: "grid"))"){
                    userSelections.cursorGuidesEnabled.toggle()
                }
                .foregroundColor(userSelections.cursorGuidesEnabled ? .primary : .secondary)
                .font(userSelections.cursorGuidesEnabled ? .headline.weight(.semibold) : .none)
                
                //Layer overlay enable button
                Button("\(Image(systemName: "square.stack.3d.down.forward"))"){
                    userSelections.showBoundingBoxes.toggle()
                }
                .foregroundColor(userSelections.showBoundingBoxes ? .primary : .secondary)
                .font(userSelections.showBoundingBoxes ? .headline.weight(.semibold) : .none)
                
            }//END TOOLBARITEMGROUP
            
        }//END TOOLBAR
        .environmentObject(mlSetDocument)
        .environmentObject(userSelections)
    }//END VIEW BUILDER

}
