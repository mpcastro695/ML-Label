//
//  ImageGallery.swift
//  ML Label
//
//  Created by Martin Castro on 10/8/22.
//

import SwiftUI

/// A view for displaying, sorting, and adding images from sources
@available(macOS 13.0, *)
struct Gallery: View {
    
    @EnvironmentObject var mlSet: MLSet
    @EnvironmentObject var userSelections: UserSelections
    
    var imageSources: [MLImageSource]
    
    let thumbnailSize: CGFloat = 100
    let thumbPadding: CGFloat = 15
    
    @State private var searchText = ""
    
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: thumbnailSize), spacing: thumbPadding)], spacing: thumbPadding) {
                
                if imageSources.count == 1 { //Show Images from a single source
                    ForEach(imageSources.first!.images) { mlImage in
                        NavigationLink(value: mlImage) {ImageCard(mlImage: mlImage)}
                            .buttonStyle(.plain)
                    }
                }else if userSelections.imageSource == nil { // No selection, show ALL Images
                    ForEach(mlSet.images) { mlImage in
                        NavigationLink(value: mlImage) {ImageCard(mlImage: mlImage)}
                            .buttonStyle(.plain)
                    }
                }else if userSelections.imageSource != nil{ // Show selected source's images
                    ForEach(userSelections.imageSource!.images) { mlImage in
                        NavigationLink(value: mlImage) {ImageCard(mlImage: mlImage)}
                            .buttonStyle(.plain)
                    }
                }
            }
        }
        .scrollContentBackground(.hidden)
        .scrollIndicators(.never)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.horizontal)
//MARK: - Toolbar
        .safeAreaInset(edge: .top) {
            HStack{ // Toolbar
                Picker(selection: $userSelections.imageSource) {
                    Text("All")
                        .italic()
                        .tag(nil as MLImageSource?)
                    Divider()
                    ForEach(imageSources) { source in
                        Text("\(source.folderName)")
                            .tag(source as MLImageSource?)
                    }
                } label: {
                    Text("")
                        .font(.caption)
                }
                .pickerStyle(.menu)
                .buttonStyle(LineBorderStyle())
                .frame(width: 160)
                .disabled(imageSources.isEmpty || mlSet.images.isEmpty)
                
                TextField(text: $searchText, prompt: Text("Search...")) { //Search bar
                    Text("Search")
                }
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 240)
                .disabled(imageSources.isEmpty || mlSet.images.isEmpty)
                
                Spacer()
                Button { //Filter button
                    print("filter the results!")
                } label: {
                    Text("\(Image(systemName: "line.3.horizontal.decrease"))")
                    
                }
                .buttonStyle(.plain)
                .disabled(imageSources.isEmpty || mlSet.images.isEmpty)
                
                Button { //Add Source Button
                    if let fileURLs = showImageSelectPanel() {
                        for url in fileURLs {mlSet.addImageFromURL(url: url)}
                    }
                } label: {
                    Text("\(Image(systemName: "plus.rectangle.on.rectangle"))")
                }
                .buttonStyle(.plain)
            }//END Toolbar HSTACK
            .padding(.vertical, 8)
            .padding(.horizontal)
            .background(.ultraThinMaterial)
        }//END SAFE AREA INSET
        .background(Rectangle().foregroundColor(.secondary).opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding()
        .onDrop(of: [.fileURL], delegate: mlSet)
        .overlay(alignment: .center){
            if imageSources.isEmpty || mlSet.images.isEmpty {
                MissingImages()
            }
        }
    }
    
    
    private func showImageSelectPanel() -> [URL]? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [.fileURL, .image]
        openPanel.allowsMultipleSelection = true
        openPanel.canChooseDirectories = false
        openPanel.canChooseFiles = true
        let response = openPanel.runModal()
        return response == .OK ? openPanel.urls : nil
    }
}
