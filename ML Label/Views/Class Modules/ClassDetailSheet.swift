//
//  ClassDetailSheet.swift
//  ML Label
//
//  Created by Martin Castro on 10/22/22.
//

import SwiftUI

struct ClassDetailSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    
    @ObservedObject var mlClass: MLClass
    
    var body: some View {
        VStack(alignment: .leading){
            
            HStack(spacing: 20){
                Image(systemName: "tag.square")
                    .resizable()
                    .frame(width:60, height: 60)
                    .foregroundColor(mlClass.color.toColor())
                VStack(alignment: .leading){
                    Text("\(mlClass.label)")
                        .font(.title)
                    Text("\(mlClass.description)")
                        .font(.caption)
                }
            }
            .padding(.bottom, 5)
            
            Divider()
            
            //Gallery
            if mlClass.instances.isEmpty{
                Text("No annotations yet!")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }else{
                VStack(alignment: .leading){
                    Text("\(mlClass.tagCount()) instances over \(mlClass.instances.count) images")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    if #available(macOS 13.0, *) {
//                        ImageGalleryView()
                    } else {
                        // Fallback on earlier versions
                    }
                }
            }
            
            Spacer()
            
            //Buttons
            HStack{
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                Button(role: .destructive) {
                    print("class deleted")
                } label: {
                    Text("Delete Class")
                }

            }
            
        }
        .padding()
        
        .frame(width: 400, height: 480)
        
    }
    
    private func instanceImage(mlImage: MLImage, boundingBox: MLBoundingBox) {
        
    }
}
