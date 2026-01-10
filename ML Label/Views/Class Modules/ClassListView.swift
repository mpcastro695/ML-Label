//
//  ClassList.swift
//  ML Label
//
//  Created by Martin Castro on 7/17/22.
//

import SwiftUI

@available(macOS 14.0, *)
struct ClassListView: View {
    
    @EnvironmentObject var mlSet: MLSet
    @EnvironmentObject var userSelections: UserSelections
    
    @State private var newClassSheetVisible: Bool = false
    @State private var searchText: String = ""
    
    var body: some View {
        
        // Prevents the "Publishing changes from within view updates" warning.
        let selectionBinding = Binding<MLClass?>(
            get: { userSelections.mlClass },
            set: { newValue in
                DispatchQueue.main.async {
                    userSelections.mlClass = newValue
                }
            }
        )
        
        List(selection: selectionBinding){
            ForEach(mlSet.classes) { mlClass in
                if searchText != "" {
                    if mlClass.label.lowercased().contains(searchText.lowercased()){
                        ClassListRow(mlClass: mlClass)
                            .tag(mlClass)
                    }
                }
                else{
                    ClassListRow(mlClass: mlClass)
                        .tag(mlClass)
                }
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
