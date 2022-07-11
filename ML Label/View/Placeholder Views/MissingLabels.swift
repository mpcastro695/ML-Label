//
//  MissingLabels.swift
//  ML Label
//
//  Created by Martin Castro on 7/8/22.
//

import Foundation

import SwiftUI

struct MissingLabels: View {
    
    var body: some View {
        VStack{
            Image(systemName: "tag")
                .font(.system(size: 20))
                .foregroundColor(.secondary.opacity(0.4))
                .padding(.bottom, 10)
            Text("Add class labels")
                .foregroundColor(.secondary.opacity(0.4))
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.secondary.opacity(0.05)))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
