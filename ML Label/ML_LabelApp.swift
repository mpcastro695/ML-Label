//
//  ML_LabelApp.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import SwiftUI

@main

struct ML_LabelApp: App {
    
    @StateObject var imageData = ImageStore()
    @StateObject var classData = ClassStore()
    
    @State var projectName: String = "Demo Image Set"
    
    @State var imagesSelected = true
    @State var classesSelected = false
    @State var outputSelected = false
    
    
    var body: some Scene {
        
        WindowGroup {
            
            NavigationView{
                
                Sidebar(
                    imagesSelected: $imagesSelected,
                    classesSelected: $classesSelected,
                    outputSelected: $outputSelected)
                
                // Our second view, will not be seen.
                EmptyView()
                
                DetailPlaceholder(
                    imagesSelected: $imagesSelected,
                    classesSelected: $classesSelected,
                    outputSelected: $outputSelected)
            }
            .navigationTitle("ML Label - \(projectName)")
            .environmentObject(imageData)
            .environmentObject(classData)
            
        }
        .windowStyle(DefaultWindowStyle())
        .windowToolbarStyle(ExpandedWindowToolbarStyle())
    }
}
