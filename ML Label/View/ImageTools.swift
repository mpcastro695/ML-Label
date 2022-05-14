//
//  ImageTools.swift
//  ML Label
//
//  Created by Martin Castro on 5/13/22.
//

import SwiftUI

struct ImageTools: View {
    
    @EnvironmentObject var mlSet: MLSet
    
    @Binding var addEnabled: Bool
    @Binding var removeEnabled: Bool
    
    @Binding var imageSelection: MLImage?
    @Binding var classSelection: MLClass?
    
    var body: some View {
        
        VStack(alignment: .center){
            
            if let img = imageSelection {
                HStack{
                    VStack(alignment: .leading){
                        Text("\(img.name)")
                            .font(.headline)
                        Text("\(img.width) x \(img.height)")
                            .font(.callout)
                    }
                    .padding(.horizontal)
                    Spacer()
                }
            }else{
                HStack{
                    VStack(alignment: .leading){
                        Text("---")
                            .font(.headline)
                        Text("---")
                            .font(.callout)
                    }
                    .padding(.horizontal)
                    Spacer()
                }
            }
            
            Text("Annotation Tools")
                .padding(.top)
                .font(.callout)
            
// MARK: - Buttons
            HStack(spacing: 15) {
                Button(action: {
                    addEnabled = true
                    removeEnabled = false
                }) {
                    Image(systemName: "rectangle.badge.plus")
                }
                Button(action: {
                    removeEnabled = true
                    addEnabled = false
                }) {
                    Image(systemName: "rectangle.badge.minus")
                }
                Button(action: {print("Delete this image")}) {
                    Image(systemName: "trash")
                }
            }.padding(.bottom, 20)
            
// MARK: - Label Picker
            Picker("Label", selection: $classSelection) {
                if mlSet.classes.count == 0 {
                    Text("No Classes Added")
                        .foregroundColor(.secondary)
                }else{
                    ForEach(mlSet.classes, id: \.id) { label in
                        Text("\(label.label)")
                            .foregroundColor(.primary)
                            .tag(label as MLClass?)
                    }
                }
                
            }
            .pickerStyle(MenuPickerStyle())
            .font(.callout)
            .frame(width: 250)
            .disabled(mlSet.classes.count == 0)
            
        }
        .onDisappear {
            addEnabled = false
            removeEnabled = false
        }
    }
}

//struct ImageTools_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageTools()
//    }
//}
