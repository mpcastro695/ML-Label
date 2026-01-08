//
//  ClassDetailsView.swift
//  ML Label
//
//  Created by Martin Castro on 11/26/22.
//

import SwiftUI

@available(macOS 13.0, *)
struct ClassDashView: View {
    
    var mlClass: MLClass
    
    var body: some View {
        VStack{
            HStack{
                //Class Details
                VStack(alignment: .leading) {
                    Text("\(mlClass.label)")
                        .font(.largeTitle)
                        .padding(.bottom, 5)
                    Text("\(mlClass.description)")
                        .foregroundColor(.secondary)
                        .font(.subheadline)
                }
                Spacer()
                //Instances and Photo Count
                VStack{
                    Text("\(Image(systemName: "scope")) \(mlClass.tagCount())")
                        .padding(.bottom, 5)
                    Text("\(Image(systemName: "photo")) \(mlClass.instances.count)")
                }
                .foregroundColor(.secondary)
                .padding(5)
            }
            .padding(.bottom, 30)
            
            //Gallery Controls
            HStack{
                Text("Instances")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .underline()
                Spacer()
                Button {
                    print("Search bar activate!")
                } label: {
                    Image(systemName: "magnifyingglass")
                }.buttonStyle(.plain)
                Button {
                    print("Present popup menu for filtering options")
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }.buttonStyle(.plain)
            }
    
//            ImageGalleryView()
            Spacer()
        }
        .padding()
    }
}

//Implement rest of ClassDetailsView, then move on to SetDe
