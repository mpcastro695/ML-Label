//
//  ClassTools.swift
//  ML Label
//
//  Created by Martin Castro on 7/9/22.
//

import SwiftUI

struct ClassTools: View {
    
    @EnvironmentObject var mlSet: MLSetDocument
    @Binding var classSelection: MLClass?
    
    @State private var newClassSheetVisible: Bool = false
    @State private var textFieldEntry: String = ""
    @State private var selectedColor = MLColor(red: 50/255, green: 50/255, blue: 50/255)
    
    
    var body: some View {
        
        VStack(alignment: .center){
            
            if mlSet.classes.isEmpty {
                MissingLabels(classSelection: $classSelection)
            }else{
                HStack{
                    Text("\(Image(systemName: "tag")) Tags")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                    // New Class Button
                    Button {
                        newClassSheetVisible.toggle()
                    } label: {
                        Image(systemName: "plus.rectangle")
                            .font(.headline)
                    }.buttonStyle(.plain)

                }//END HSTACK
                .padding(.bottom)
                .sheet(isPresented: $newClassSheetVisible, content: {
                    AddClassSheet(classSelection: $classSelection)
                })
        
                ClassList(classSelection: $classSelection)
            }
            
            
        }//END VSTACK
        .padding()
    }
}

