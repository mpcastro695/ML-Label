//
//  MissingImages.swift
//  ML Label
//
//  Created by Martin Castro on 7/8/22.
//

import SwiftUI

struct MissingImages: View {
    
    var body: some View {
        VStack{
            Image(systemName: "photo")
                .font(.system(size: 20))
                .foregroundColor(.secondary.opacity(0.4))
                .padding(.bottom, 10)
            Text("Add Photos to Start Annotating")
                .foregroundColor(.secondary.opacity(0.4))
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.secondary.opacity(0.1)))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
