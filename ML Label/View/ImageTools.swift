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
        
        VStack(alignment: .leading){
            
            if let img = imageSelection {
                HStack{
                    VStack(alignment: .leading){
                        Text("\(img.name)")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("\(img.width) x \(img.height) px")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }else{
                HStack{
                    VStack(alignment: .leading){
                        Text("---")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("---")
                            .font(.callout)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
            }// Image title and metadata (pixel size and file path)
            
            Text("Label")
                .padding(.top)
                .font(.subheadline)
            
            // MARK: - Picker + Buttons
            HStack{
                Picker("", selection: $classSelection) {
                    ForEach(mlSet.classes, id: \.id) { label in
                        Text("\(label.label)")
                            .foregroundColor(.primary)
                            .tag(label as MLClass?)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .font(.callout)
                .disabled(mlSet.classes.count == 0)
                
                HStack(spacing: 5) {
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
                }
                
            }
            .padding(.bottom, 20)
            
            Text("Annotations")
                .font(.subheadline)
            
            if imageSelection != nil {
                AnnotationListView(mlImage: imageSelection!)
            }else{
                Text("No Image Selected")
                    .font(.caption)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .foregroundColor(.secondary)
            }
            
        }//END VSTACK
        .padding(.horizontal, 15)
        .onDisappear {
            addEnabled = false
            removeEnabled = false
        }
    }
}

struct AnnotationListView: View {
    
    @ObservedObject var mlImage: MLImage
    
    var body: some View {
        
        if mlImage.annotations.count != 0 {
            List(mlImage.annotations) { annotation in
                HStack{
                    Text("\(annotation.label)")
                    Spacer()
                    Image(systemName: "eye")
                    Image(systemName: "trash")
                }
            }
        }else{
            Text("No Annotations")
                .font(.caption)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .foregroundColor(.secondary)
        }
        
    }
}

//struct ImageTools_Previews: PreviewProvider {
//    static var previews: some View {
//        ImageTools()
//    }
//}
