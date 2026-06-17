//
//  DocumentView4.swift
//  ML Label
//
//  Created by Martin Castro on 11/26/22.
//

import SwiftUI

@available(macOS 14.0, *)
struct ContentView: View {
    
    @ObservedObject var mlSetDocument: MLSet
    @StateObject var userSelections = UserSelections()
    
    var fileName: String
    
    var body: some View {
        NavigationStack(path: $userSelections.navigationPath) {
            SetDashView(fileName: fileName)
                .navigationDestination(for: MLImage.self) { mlImage in
                    AnnotatorView(mlImage: mlImage)
                }
        }
        .environmentObject(mlSetDocument)
        .environmentObject(userSelections)
        .frame(minWidth: 1000, minHeight: 600)

    }
}
