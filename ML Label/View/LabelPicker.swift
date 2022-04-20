//
//  LabelPicker.swift
//  ImageAnnotator
//
//  Created by Martin Castro on 10/9/21.
//

import SwiftUI

struct LabelPicker: View {
    
    @EnvironmentObject var mlSet: MLSet
    @Binding var selectedClassLabel: MLClass
    
    var body: some View {
        
        Picker(selection: $selectedClassLabel, label: EmptyView()) {
            
            // If no labels, defaults to "No Class Labels" ClassData instance from ImageList
            if mlSet.classes.count == 0 {
                Text("\(selectedClassLabel.label)")
                    .foregroundColor(.secondary)
                    .tag(selectedClassLabel)
                
            }else{
                
                ForEach(mlSet.classes, id: \.id) { label in
                    Text("\(label.label)")
                        .foregroundColor(.primary)
                        .tag(label)
                }
            }
            
        }
        .pickerStyle(MenuPickerStyle())
        .frame(width: 250)
        .disabled(mlSet.classes.count == 0)
        
    }
}

//struct LabelPickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        LabelPickerView()
//    }
//}
