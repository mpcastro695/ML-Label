//
//  ImageGallery.swift
//  ML Label
//
//  Created by Martin Castro on 10/8/22.
//

import SwiftUI

/// A view for displaying, sorting, and adding images from sources
@available(macOS 14.0, *)
struct GalleryView: View {
    
    @EnvironmentObject var mlSet: MLSet
    @EnvironmentObject var userSelections: UserSelections
    
    var imageSources: [MLImageSource]
    
    let thumbnailSize: CGFloat = 100
    let thumbPadding: CGFloat = 15
    
    @State private var searchText = ""
    @State private var hideAnnotated: Bool = false
    
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: thumbnailSize), spacing: thumbPadding)], spacing: thumbPadding) {
                
                if imageSources.count == 1 { //Show Images from a single source
                    ForEach(imageSources.first!.images) { mlImage in
                        if searchText != "" {
                            if mlImage.name.lowercased().contains(searchText.lowercased()) {
                                if hideAnnotated {
                                    if mlImage.annotations.isEmpty {
                                        NavigationLink(value: mlImage) {ImageCard(mlImage: mlImage, thumbnailSize: thumbnailSize)}
                                            .buttonStyle(.plain)
                                    }
                                }
                                else if hideAnnotated == false {
                                    NavigationLink(value: mlImage) {ImageCard(mlImage: mlImage, thumbnailSize: thumbnailSize)}
                                        .buttonStyle(.plain)
                                }
                            }
                        }
                        else{
                            if hideAnnotated {
                                if mlImage.annotations.isEmpty {
                                    NavigationLink(value: mlImage) {ImageCard(mlImage: mlImage, thumbnailSize: thumbnailSize)}
                                        .buttonStyle(.plain)
                                }
                            }
                            else if hideAnnotated == false {
                                NavigationLink(value: mlImage) {ImageCard(mlImage: mlImage, thumbnailSize: thumbnailSize)}
                                    .buttonStyle(.plain)
                            }
                        }
                    }
                }else if userSelections.imageSource == nil { // No selection, show ALL Images
                    ForEach(mlSet.allImages()) { mlImage in
                        if searchText != "" {
                            if mlImage.name.lowercased().contains(searchText.lowercased()) {
                                if hideAnnotated {
                                    if mlImage.annotations.isEmpty {
                                        NavigationLink(value: mlImage) {ImageCard(mlImage: mlImage, thumbnailSize: thumbnailSize)}
                                            .buttonStyle(.plain)
                                    }
                                }
                                else if hideAnnotated == false {
                                    NavigationLink(value: mlImage) {ImageCard(mlImage: mlImage, thumbnailSize: thumbnailSize)}
                                        .buttonStyle(.plain)
                                }
                            }
                        }
                        else{
                            if hideAnnotated {
                                if mlImage.annotations.isEmpty {
                                    NavigationLink(value: mlImage) {ImageCard(mlImage: mlImage, thumbnailSize: thumbnailSize)}
                                        .buttonStyle(.plain)
                                }
                            }
                            else if hideAnnotated == false {
                                NavigationLink(value: mlImage) {ImageCard(mlImage: mlImage, thumbnailSize: thumbnailSize)}
                                    .buttonStyle(.plain)
                            }
                        }
                    }
                }else if userSelections.imageSource != nil{ // Show selected source's images
                    ForEach(userSelections.imageSource!.images) { mlImage in
                        if searchText != "" {
                            if mlImage.name.lowercased().contains(searchText.lowercased()) {
                                if hideAnnotated {
                                    if mlImage.annotations.isEmpty {
                                        NavigationLink(value: mlImage) {ImageCard(mlImage: mlImage, thumbnailSize: thumbnailSize)}
                                            .buttonStyle(.plain)
                                    }
                                }
                                else if hideAnnotated == false {
                                    NavigationLink(value: mlImage) {ImageCard(mlImage: mlImage, thumbnailSize: thumbnailSize)}
                                        .buttonStyle(.plain)
                                }
                            }
                        }
                        else{
                            if hideAnnotated {
                                if mlImage.annotations.isEmpty {
                                    NavigationLink(value: mlImage) {ImageCard(mlImage: mlImage, thumbnailSize: thumbnailSize)}
                                        .buttonStyle(.plain)
                                }
                            }
                            else if hideAnnotated == false {
                                NavigationLink(value: mlImage) {ImageCard(mlImage: mlImage, thumbnailSize: thumbnailSize)}
                                    .buttonStyle(.plain)
                            }
                        }
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
                .disabled(imageSources.isEmpty || mlSet.allImages().isEmpty)
                
                Spacer()
                
                TextField(text: $searchText, prompt: Text("Search...")) { //Search bar
                    Text("Search")
                }
                .textFieldStyle(.roundedBorder)
                .frame(maxWidth: 240)
                .disabled(imageSources.isEmpty || mlSet.allImages().isEmpty)
                
                Spacer()
                Button { // Filter out annotated images
                    hideAnnotated.toggle()
                } label: {
                    Text("\(Image(systemName: "circle.dashed"))")
                    
                }
                .buttonStyle(.plain)
                .disabled(imageSources.isEmpty || mlSet.allImages().isEmpty)
                .font(hideAnnotated ? .headline.weight(.black) : .none)
                
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
            if imageSources.isEmpty || mlSet.allImages().isEmpty {
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
