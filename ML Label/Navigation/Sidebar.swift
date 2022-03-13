//
//  Sidebar.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import SwiftUI

struct Sidebar: View {
    
    @EnvironmentObject var imageStore: ImageStore
    @EnvironmentObject var classStore: ClassStore
    
    @Binding var imagesSelected: Bool
    @Binding var classesSelected: Bool
    @Binding var outputSelected: Bool
    
    var body: some View {
        
        List{
            
            Text("Input")
                .font(.callout)
                .bold()
                .foregroundColor(.secondary).opacity(0.5)
            
            // MARK:  Images
            NavigationLink(
                destination: ImageList(),
                isActive: $imagesSelected,
                label: {
                    HStack{
                        Label(
                            title: { Text("Images") },
                            icon: { Image(systemName: "photo.on.rectangle") }
                        )
                        Spacer()
                        // If images have been added, an image count
                        if imageStore.images.count > 0 {
                            Text("\(imageStore.images.count)")
                                .font(.caption)
                                .bold()
                                .padding(.horizontal, 10)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.3))
                                .clipShape(Capsule())
                        }
                    }
                }
            )
            
            // MARK:  Classes
            NavigationLink(
                destination: ClassList(),
                isActive: $classesSelected,
                label: {
                    HStack{
                        Label(
                            title: { Text("Classes") },
                            icon: { Image(systemName: "tag") }
                        )
                        
                        Spacer()
                        // If classes have been added, add a class count
                        if classStore.classes.count > 0 {
                            Text("\(classStore.classes.count)")
                                .font(.caption)
                                .bold()
                                .padding(.horizontal, 10)
                                .padding(.vertical, 2)
                                .background(Color.secondary.opacity(0.3))
                                .clipShape(Capsule())
                        }
                    }
                })
            
            
            Divider()
            
            Text("Output")
                .font(.callout)
                .bold()
                .foregroundColor(.secondary).opacity(0.5)
            
            // MARK: Export
            NavigationLink(
                destination: Text("Export settings pane will be here upon final release.")
                    .font(.footnote).foregroundColor(.secondary),
                isActive: $outputSelected,
                label: {
                    Label(
                        title: { Text("Export") },
                        icon: { Image(systemName: "square.and.arrow.up") })
                }
            )
            
            
            
        }
        
// MARK: - Modifiers
        
        .padding(.top)
        .listStyle(SidebarListStyle())
        
        .toolbar{
            Button(action: {toggleSideBar()},
                   label: {
                Image(systemName: "sidebar.left")
            })
        }
        
        
        
        
    }
    // End of body
    
    private func toggleSideBar(){
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSSplitViewController.toggleSidebar(_:)), with: nil)
    }
}

//struct SidebarView_Previews: PreviewProvider {
//    static var previews: some View {
//        Sidebar()
//    }
//}
