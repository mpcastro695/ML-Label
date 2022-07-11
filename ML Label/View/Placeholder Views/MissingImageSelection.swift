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
                .font(.system(size: 20))
                .foregroundColor(.secondary.opacity(0.4))
                .padding(.bottom, 10)
            Text("Choose a Photo to Start Annotating")
                .foregroundColor(.secondary.opacity(0.4))
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.secondary.opacity(0.05)))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
