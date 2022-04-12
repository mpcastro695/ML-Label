//
//  PlaceholderDetail.swift
//  ML Label
//
//  Created by Martin Castro on 10/16/21.
//

import SwiftUI

struct DetailPlaceholder: View {
    
    @Binding var imagesSelected: Bool
    @Binding var classesSelected: Bool
    @Binding var outputSelected: Bool
    
    @State var demoLabel = MLClass(label: "", color: MLColor(red: 50/255, green: 50/255, blue: 50/255))
    
    
    var body: some View {
        
// MARK: - Images Placeholder
        
        if imagesSelected {
            VStack{
                Image(systemName: "photo")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary.opacity(0.3))
                    .padding(.bottom, 10)
                Text("Select an image.")
                    .foregroundColor(.secondary.opacity(0.3))
            }
            .frame(width:140, height: 100)
            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.secondary.opacity(0.05)))
            .toolbar{
                
                LabelPicker(selectedClassLabel: $demoLabel)
                    .padding(.horizontal, 10)
                    .disabled(true)
                
                Button(action: {print("placeholder")}, label: {
                    Image(systemName: "arrow.uturn.backward").font(.body.weight(.bold))
                }).disabled(true)
                
                Button(action: {print("placeholder")}, label: {
                    Image(systemName: "plus.rectangle").font(.body.weight(.bold))
                }).disabled(true)
                
                Spacer()
                
                Button(action: {print("Delete")}, label: {
                    Image(systemName: "trash").font(.body.weight(.bold))
                }).disabled(true)
                
                
            }
            
            
        }
// MARK: - Classes Placeholder
        
        else if classesSelected {
            VStack{
                Image(systemName: "tag")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary.opacity(0.3))
                    .padding(.bottom, 10)
                Text("Select a label.")
                    .foregroundColor(.secondary.opacity(0.3))
            }
            .frame(width:140, height: 100)
            .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.secondary.opacity(0.05)))
            .toolbar{
                
                Button(action: {print("Edit class data.")}, label: {
                    Image(systemName: "rectangle.and.pencil.and.ellipsis")
                }).disabled(true)
                
            }
            
            
        }
        
// MARK: - Output Placeholder
        
        else if outputSelected {
            Text("Output Selected! Replace me!")
        }
        
        
    }
}

//struct PlaceholderDetail_Previews: PreviewProvider {
//    static var previews: some View {
//        PlaceholderDetail()
//    }
//}
