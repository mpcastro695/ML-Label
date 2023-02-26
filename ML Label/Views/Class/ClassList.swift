//
//  ClassList.swift
//  ML Label
//
//  Created by Martin Castro on 7/17/22.
//

import SwiftUI

@available(macOS 13.0, *)
struct ClassList: View {
    
    @EnvironmentObject var mlSet: MLSet
    @EnvironmentObject var userSelections: UserSelections
    
    @State private var newClassSheetVisible: Bool = false
    @State private var searchText: String = ""
    
    var body: some View {
        
        List(selection: $userSelections.mlClass){
            ForEach(mlSet.classes) { mlClass in
                NavigationLink(value: mlClass) {
                    ClassListRow(mlClass: mlClass)
                }
                .buttonStyle(.plain)
            }
        }//END LIST
        .scrollContentBackground(.hidden)
        .safeAreaInset(edge: .top) {
            HStack{ // Toolbar
                TextField(text: $searchText, prompt: Text("Search...")) { //Search bar
                    Text("Search")
                }
                .textFieldStyle(.roundedBorder)
                .disabled(mlSet.classes.isEmpty)
                
                Spacer()
                Button { //Add Class Button
                    newClassSheetVisible.toggle()
                } label: {
                    Image(systemName: "plus.rectangle")
                }
                .buttonStyle(.plain)
            }//END HSTACK
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(.ultraThinMaterial)
        }//END SAFEAREA INSET
        .sheet(isPresented: $newClassSheetVisible, content: {NewClassSheet(classSelection: $userSelections.mlClass)})
        .background(Rectangle().foregroundColor(.secondary).opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
        .overlay(alignment: .center) {
            if mlSet.classes.isEmpty {
                MissingLabels()
            }
        }
    }
}
