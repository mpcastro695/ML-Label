//
//  DocumentView4.swift
//  ML Label
//
//  Created by Martin Castro on 11/26/22.
//

import SwiftUI

@available(macOS 13.0, *)
struct ContentView: View {
    
    @Binding var mlSetDocument: MLSet
    @StateObject var userSelections = UserSelections()
    
    var fileName: String
    
    @State private var path = NavigationPath()
    @State private var sidebarSelection: UUID? = nil
    
    var body: some View {
        NavigationSplitView(sidebar: {
            Sidebar(fileName: fileName, selection: $sidebarSelection)
                .navigationSplitViewColumnWidth(min: 200, ideal: 300, max: 300)
        }, detail: {
            NavigationStack(path: $path) {
                SetDash(fileName: fileName)
                    .navigationDestination(for: MLImage.self) { mlImage in
                        Annotator(mlImage: mlImage)
                    }
                    .navigationDestination(for: MLImageSource.self) { imageSource in
                        SourceDash(imageSource: imageSource)
                    }
//                    .navigationDestination(for: MLClass.self) { mlClass in
//                        ClassDash(mlClass: mlClass)
//                    }
            }
        })
            .environmentObject(mlSetDocument)
            .environmentObject(userSelections)
            .frame(minWidth: 1000, minHeight: 600)
            .onAppear{
                sidebarSelection = mlSetDocument.id
            }
    }
}
