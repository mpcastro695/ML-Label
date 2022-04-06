//
//  LabelPicker.swift
//  ImageAnnotator
//
//  Created by Martin Castro on 10/9/21.
//

import SwiftUI

struct LabelPicker: View {
    
    @EnvironmentObject var classStore: ClassStore
    @Binding var selectedClassLabel: ClassData
    
    var body: some View {
        
        Picker(selection: $selectedClassLabel, label: EmptyView()) {
            
            // If no labels, defaults to "No Class Labels" ClassData instance from ImageList
            if classStore.classes.count == 0 {
                Text("\(selectedClassLabel.label)")
                    .foregroundColor(.secondary)
                    .tag(selectedClassLabel)
                
            }else{
                
                ForEach(classStore.classes, id: \.id) { label in
                    Text("\(label.label)")
                        .foregroundColor(.primary)
                        .tag(label)
                }
            }
            
        }
        .pickerStyle(MenuPickerStyle())
        .frame(width: 250)
        .disabled(classStore.classes.count == 0)
        
    }
}

//struct LabelPickerView_Previews: PreviewProvider {
//    static var previews: some View {
//        LabelPickerView()
//    }
//}
