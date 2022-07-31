//
//  LabelTools.swift
//  ML Label
//
//  Created by Martin Castro on 7/9/22.
//

import SwiftUI

struct LabelToolsView: View {
    
    @EnvironmentObject var mlSet: MLSetDocument
    
    @State var textFieldEntry: String = ""
    @State var selectedColor = MLColor(red: 50/255, green: 50/255, blue: 50/255)
    @Binding var classSelection: MLClass?
    
    @State var popoverVisible: Bool = false
    
    
    
    var body: some View {
        
        VStack(alignment: .center){
            
            HStack{
                Text("\(Image(systemName: "tag")) Tags")
                    .font(.headline)
                    .foregroundColor(.secondary)
                Spacer()
                // New Class Button
                Button {
                    popoverVisible.toggle()
                } label: {
                    Image(systemName: "plus.rectangle")
                        .font(.headline)
                }.buttonStyle(.plain)

            }//END HSTACK
            .padding(.bottom)
            
            .popover(isPresented: $popoverVisible) {
                if #available(macOS 12.0, *) {
                    NewClassPopover(classSelection: $classSelection)
                        .padding()
                } else {
                    // Fallback on earlier versions
                }
            }
            
            ClassListView(classSelection: $classSelection)
            
        }//END VSTACK
        .padding()
    }
}

