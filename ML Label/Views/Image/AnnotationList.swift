//
//  AnnotationList.swift
//  ML Label
//
//  Created by Martin Castro on 7/8/22.
//


import SwiftUI

struct AnnotationList: View {
    
    @EnvironmentObject var mlSet: MLSet
    @EnvironmentObject var userSelections: UserSelections
    
    @ObservedObject var mlImage: MLImage
    
    var body: some View {
        
        if mlImage.annotations.count != 0 {
            
            HStack{
                Text("Annotations")
                    .font(.subheadline)
                Spacer()
                Text("\(mlImage.annotations.count)")
                    .font(.callout)
                    .padding(.horizontal, 5)
            }
            
            ScrollView(showsIndicators: false) {
                
                let highlight = RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(Color.primary)
                    .opacity(0.05)
                
                let clearView = RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(Color.clear)
                    .opacity(0)
                    
                
                ForEach(mlImage.annotations) { annotation in
                    VStack{
                        AnnotationListRow(mlImage: mlImage, annotation: annotation)
                            .frame(height: 15)
                            .padding(3)
                            .contentShape(Rectangle())
                            .background(userSelections.mlBox?.id == annotation.id ? highlight : clearView)
                            .onTapGesture {
                                userSelections.mlBox = annotation
                            }
                    }
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
