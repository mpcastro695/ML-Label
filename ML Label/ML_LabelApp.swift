//
//  ML_LabelApp.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import SwiftUI


@main

struct ML_LabelApp: App {
    
    var body: some Scene {
        
        DocumentGroup(newDocument: MLSet()) { file in
            if #available(macOS 14.0, *) {
                ContentView(mlSetDocument: file.document, fileName: file.fileURL?.lastPathComponent ?? "Untitled")
            } else {
                // Fallback on earlier versions
            }
        }
    }
}
