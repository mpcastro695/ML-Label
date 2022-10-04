//
//  MissingImages.swift
//  ML Label
//
//  Created by Martin Castro on 7/8/22.
//

import SwiftUI

struct MissingImages: View {
    
    @EnvironmentObject var mlSet: MLSetDocument
    
    var body: some View {
        VStack{
            ZStack{
                Image(systemName: "photo.on.rectangle.angled")
                    .font(.system(size: 60))
                    .foregroundColor(.secondary.opacity(0.5))
                Image(systemName: "plus.circle")
                    .font(.system(size: 25, weight: .bold))
                    .foregroundColor(.secondary.opacity(0.5))
                    .offset(x: 40, y: -30)
            }
            .padding(.bottom, 5)
            
            Text("Drag and drop or select images from file")
                .foregroundColor(.secondary.opacity(0.8))
                .font(.footnote)
                .padding(.bottom, 20)
            
            Button {
                if let fileURLs = showImageSelectPanel() {
                    for url in fileURLs {
                        mlSet.addImageFromURL(url: url)
                    }
                }
            } label: {
                Text("Select From File...")
            }.buttonStyle(LineBorderStyle())

        }
        .padding(50)
        .overlay(RoundedRectangle(cornerRadius: 10)
                    .stroke(style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [5, 8]))
                    .foregroundColor(.secondary.opacity(0.3))
                    .frame(width: 400)
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

//MARK: NSOpenPanel
    func showImageSelectPanel() -> [URL]? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.fileURL, .image]
            openPanel.allowsMultipleSelection = true
            openPanel.canChooseDirectories = false
            openPanel.canChooseFiles = true
            let response = openPanel.runModal()
            return response == .OK ? openPanel.urls : nil
    }
}
