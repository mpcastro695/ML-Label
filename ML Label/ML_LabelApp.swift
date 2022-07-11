//
//  ML_LabelApp.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import SwiftUI

@main

struct ML_LabelApp: App {
    
    @StateObject var mlSet = MLSet()
    
    @State var projectName: String = "Demo Image Set"
    
    // Navigation sidebar starts with "Images" selected
    @State var imagesSelected = true
    @State var classesSelected = false
    @State var outputSelected = false
    
    var body: some Scene {
        
        WindowGroup {
            
            ContentView()
                .environmentObject(mlSet)
            
        }
        .windowStyle(.automatic)
        .windowToolbarStyle(.unified)
    }
}
