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
        
        DocumentGroup(newDocument: MLSetDocument()) { file in
            DocumentView(mlSetDocument: file.$document)
        }
    }
}
