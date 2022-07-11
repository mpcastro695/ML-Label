//
//  ImageTools.swift
//  ML Label
//
//  Created by Martin Castro on 5/13/22.
//

import SwiftUI

struct ImageDetails: View {
    
    @EnvironmentObject var mlSet: MLSet
    
    @Binding var addEnabled: Bool
    @Binding var removeEnabled: Bool
    
    @Binding var imageSelection: MLImage?
    @Binding var classSelection: MLClass?
    
    var body: some View {
        
        VStack(alignment: .leading){
            
            if let img = imageSelection {
                    VStack(alignment: .leading){
                        Text("\(img.name)")
                            .font(.headline)
                        Text("\(img.width) x \(img.height) px")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 20)
                        Text("Annotations")
                            .font(.subheadline)
                        AnnotationList(mlImage: img)
                    }
                    .padding()
            }else{
                    VStack(alignment: .leading){
                        Text("---")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("---")
                            .font(.callout)
                            .foregroundColor(.secondary)
                            .padding(.bottom, 20)
                        Text("Select an image to view annotations")
                            .font(.caption)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                
            }// END Image title and metadata (pixel size and file path)
            
//            Text("Label")
//                .padding(.top)
//                .font(.subheadline)
            
//            // MARK: - Label Picker + Buttons
//            HStack{
//                Picker("", selection: $classSelection) {
//                    ForEach(mlSet.classes, id: \.id) { label in
//                        Text("\(label.label)")
//                            .foregroundColor(.primary)
//                            .tag(label as MLClass?)
//                    }
//                }
//                .pickerStyle(MenuPickerStyle())
//                .font(.callout)
//                .disabled(mlSet.classes.count == 0)
//
//                HStack(spacing: 5) {
//                    Button(action: {
//                        addEnabled = true
//                        removeEnabled = false
//                    }) {
//                        Image(systemName: "rectangle.badge.plus")
//                    }.buttonStyle(TogglableBadgeButtonStyle(isPressed: addEnabled))
//
//                    Button(action: {
//                        removeEnabled = true
//                        addEnabled = false
//                    }) {
//                        Image(systemName: "rectangle.badge.minus")
//                    }.buttonStyle(TogglableBadgeButtonStyle(isPressed: removeEnabled))
//                }
//                .disabled(mlSet.classes.count == 0)
//
//            }
//            .padding(.bottom, 20)
            
        }//END VSTACK
    }
}

//struct ImageTools_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageTools()
//    }
//}
