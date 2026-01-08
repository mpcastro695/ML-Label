//
//  SidebarView.swift
//  ML Label
//
//  Created by Martin Castro on 11/27/22.
//

import SwiftUI

@available(macOS 13.0, *)
struct SideBarView: View {
    
    @EnvironmentObject var mlSet: MLSet
    @EnvironmentObject var userSelections: UserSelections
    
    var fileName: String
    @Binding var selection: UUID?
    
    var body: some View {
        List(selection: $selection){
            //MARK: - Document
            Section {
                HStack(spacing: 5){
                    Image(systemName: "doc.fill")
                        .foregroundColor(.secondary)
                    Text("\(fileName.components(separatedBy: ".").first!)")
                }
                .padding(.leading, 5)
                .tag(mlSet.id)
            } header: {
                Text("Project")
            } footer: {
                EmptyView()
            }
            .collapsible(false)
            
            //MARK: - Image Sources
            Section(content: {
                if !mlSet.imageSources.isEmpty{
                    ForEach(mlSet.imageSources) { imageSource in
//                        NavigationLink {
//                            SourceDash(imageSource: imageSource)
//                        } label: {
//                            HStack(spacing: 5){
//                                Image(systemName: "folder")
//                                    .foregroundColor(.secondary)
//                                Text("\(imageSource.folderName)")
//                            }
//                            .padding(.leading, 5)
//                        }
//                        .buttonStyle(.plain)
                        HStack(spacing: 5){
                            Image(systemName: "folder")
                                .foregroundColor(.secondary)
                            Text("\(imageSource.folderName)")
                        }
                        .padding(.leading, 5)
                    }
                }else{
                    Text("No Image Sources")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .opacity(0.8)
                        .padding(.horizontal, 30)
                }
            }, header: {
                Text("Image Sources (\(mlSet.imageSources.count))")
            }, footer: {
                Text("\(mlSet.imageSources.count) sources")
                
            })//END IMAGE SOURCE SECTION
            .collapsible(true)
            
            //MARK: - Classes
            Section {
                if !mlSet.classes.isEmpty {
                    ForEach(mlSet.classes) { mlClass in
                        NavigationLink {
                            ClassDashView(mlClass: mlClass)
                        } label: {
                            HStack(spacing: 5){
                                Image(systemName: "circlebadge.fill")
                                    .foregroundColor(mlClass.color.toColor())
                                Text("\(mlClass.label)")
                            }
                            .padding(.leading, 5)
                        }
                        .buttonStyle(.plain)
                    }
                }else{
                    Text("No Class Labels")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .opacity(0.8)
                        .padding(.horizontal, 30)
                }
            } header: {
                HStack{
                    Text("Classes (\(mlSet.classes.count))")
                }
                .padding(.horizontal)
            } footer: {
                Text("\(mlSet.classes.count) labels")
            }//END CLASS SECTION
            .collapsible(true)
            
        }//END LIST
        .listStyle(.sidebar)
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


