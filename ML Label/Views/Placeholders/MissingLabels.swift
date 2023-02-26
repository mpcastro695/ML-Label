//
//  MissingLabels.swift
//  ML Label
//
//  Created by Martin Castro on 7/8/22.
//

import Foundation

import SwiftUI

struct MissingLabels: View {
    
    @EnvironmentObject var userSelections: UserSelections
    @State var newClassSheetVisible: Bool = false
    
    var body: some View {
        VStack{
            ZStack{
                Image(systemName: "tag")
                    .font(.system(size: 40))
                    .foregroundColor(.secondary)
                Image(systemName: "list.bullet.rectangle")
                    .font(.system(size: 20))
                    .foregroundColor(.secondary)
                    .offset(x: 30, y: 20)
            }
            .padding(.bottom, 5)

            Text("Add tags to start annotating")
                .font(.footnote)
                .foregroundColor(.secondary)
        }
        .padding(30)
        .background(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 2, dash: [5,5])).foregroundColor(.secondary).opacity(0.3))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
}
