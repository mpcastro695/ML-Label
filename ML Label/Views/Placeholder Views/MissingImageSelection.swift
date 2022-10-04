//
//  MissingSelection.swift
//  ML Label
//
//  Created by Martin Castro on 7/8/22.
//

import SwiftUI

struct MissingImageSelection: View {
    var body: some View {
        VStack{
            Image(systemName: "cursorarrow.and.square.on.square.dashed")
                .font(.system(size: 30))
                .foregroundColor(.secondary.opacity(0.6))
                .padding(.bottom, 5)
            Text("Choose a Photo to Start Annotating")
                .font(.caption)
                .foregroundColor(.secondary.opacity(0.8))
        }
        .padding(20)
        .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 1))
                    .foregroundColor(.secondary.opacity(0.2))
                    .frame(width: 250)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
