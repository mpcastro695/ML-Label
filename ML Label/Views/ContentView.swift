//
//  DocumentView4.swift
//  ML Label
//
//  Created by Martin Castro on 11/26/22.
//

import SwiftUI

@available(macOS 13.0, *)
struct ContentView: View {
    
    @ObservedObject var mlSetDocument: MLSet
    @StateObject var userSelections = UserSelections()
    
    var fileName: String
    
    @State private var path = NavigationPath()
    @State private var sidebarSelection: UUID? = nil
    
    var body: some View {
        NavigationSplitView(sidebar: {
            SideBarView(fileName: fileName, selection: $sidebarSelection)
                .navigationSplitViewColumnWidth(min: 100, ideal: 200, max: 200)
        }, detail: {
            NavigationStack(path: $path) {
                SetDashView(fileName: fileName)
                    .navigationDestination(for: MLImage.self) { mlImage in
                        AnnotatorView(mlImage: mlImage)
                    }
                    .navigationDestination(for: MLImageSource.self) { imageSource in
                        SourceDashView(imageSource: imageSource)
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
