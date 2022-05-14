//
//  ToolPanelView.swift
//  ML Label
//
//  Created by Martin Castro on 5/7/22.
//

import SwiftUI

struct ToolPanelView: View {
    
    @EnvironmentObject var mlSet: MLSet
    
    @State private var selectedToolSet: ToolSet = .Image
    
    @Binding var classSelection: MLClass?
    @Binding var imageSelection: MLImage?
    
    @Binding var addEnabled: Bool
    @Binding var removeEnabled: Bool
    
    var body: some View {
        
        GeometryReader{ geometry in
            VSplitView{
                
                VStack{
                    // Switch between toolset panels
                    Picker("", selection: $selectedToolSet) {
                        ForEach(ToolSet.allCases) { toolSet in
                            Text(toolSet.rawValue.capitalized)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
// MARK: - Active Tool Panel
                    
                    ZStack{
                        if selectedToolSet == .Image {
                            ImageTools(addEnabled: $addEnabled, removeEnabled: $removeEnabled, imageSelection: $imageSelection, classSelection: $classSelection)
                        }
                        if selectedToolSet == .Labels {
                            ClassTools(classSelection: $classSelection)
                        }
                        if selectedToolSet == .Export {
                            VStack{
                                Text("Expert options")
                                    .padding(.bottom)
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                    }
                    
                    Spacer()
                    
                } //END VSTACK, TOP-HALF CONTROL PANEL
                .font(.headline)
                .padding(.vertical)
                .frame(minHeight: geometry.size.height * 0.35)
                
                
// MARK: - Image List
                ZStack{
                    if mlSet.images.count == 0 {
                        Text("No Images :(")
                            .foregroundColor(.secondary)
                            .font(.callout)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }else{
                        List() {
                            ForEach(mlSet.images) { mlImage in
                                Button {
                                    imageSelection = mlImage
                                } label: {
                                    ImageRow(image: mlImage)
                                }
                                .buttonStyle(.plain)

                            }
                        }
                    }
                    
                }//END ZSTACK BOTTOM HALF
                .frame(minHeight: geometry.size.height * 0.4)
            
            }// END VSPLITVIEW
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    // MARK: - Toolset Enum
    enum ToolSet: String, CaseIterable, Identifiable {
        case Image, Labels, Export
        var id: Self { self }
    }
}


//struct ToolPanelView_Previews: PreviewProvider {
//    static var previews: some View {
//        ToolPanelView()
//    }
//}
