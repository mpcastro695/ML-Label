//
//  MissingLabels.swift
//  ML Label
//
//  Created by Martin Castro on 7/8/22.
//

import Foundation

import SwiftUI

struct MissingLabelsView: View {
    
    @Binding var classSelection: MLClass?
    @State var newClassSheetVisible: Bool = false
    
    var body: some View {
        VStack{
            ZStack{
                Image(systemName: "tag.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary.opacity(0.6))
                Image(systemName: "list.bullet.rectangle")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary.opacity(0.6))
                    .offset(x: 25, y: 20)
            }
            .padding(.bottom, 5)

            Text("Add tags to start annotating")
                .foregroundColor(.secondary.opacity(0.8))
                .font(.footnote)
                .padding(.bottom, 20)
            
            Button {
                newClassSheetVisible = true
            } label: {
                Text("New Tag...")
            }.buttonStyle(LineBorderStyle())

        }
        .padding(40)
        .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1))
                        .foregroundColor(.secondary.opacity(0.3))
                        .frame(height: 250)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .sheet(isPresented: $newClassSheetVisible, content: {
            AddClassSheet(classSelection: $classSelection)
        })
        
    }
}
