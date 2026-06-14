//
//  ClassDetailSheet.swift
//  ML Label
//
//  Created by Martin Castro on 10/22/22.
//

import SwiftUI

@available(macOS 14.0, *)
struct ClassDetailSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var mlSet: MLSet
    @EnvironmentObject var userSelections: UserSelections
    
    @ObservedObject var mlClass: MLClass
    let externalUndoManager: UndoManager?
    
    let thumbnailSize: CGFloat = 70
    let thumbPadding: CGFloat = 10
    
    var body: some View {
        VStack(alignment: .leading){
            
            HStack(spacing: 20){
                Image(systemName: "tag.square")
                    .resizable()
                    .frame(width:60, height: 60)
                    .foregroundColor(mlClass.color.toColor())
                VStack(alignment: .leading){
                    Text("\(mlClass.label)")
                        .font(.title)
                    Text("\(mlClass.description)")
                        .font(.caption)
                }
            }
            .padding(.bottom, 5)
            
            Divider()
            
            //Gallery
            if mlClass.instances.isEmpty{
                Text("No instances yet!")
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }else{
                VStack(alignment: .leading){
                    Text("\(mlClass.tagCount()) instances over \(mlClass.instances.count) images")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ScrollView {
                        LazyVGrid(columns: [GridItem(.adaptive(minimum: thumbnailSize), spacing: thumbPadding)], spacing: thumbPadding) {
                            ForEach(mlClass.getInstanceSnapshots(), id: \.self.1) { instance in
                                Button {
                                    dismiss()
                                    
                                    // Delay the navigation push slightly to prevent "flashing"
                                    Task { @MainActor in
                                        try? await Task.sleep(for: .seconds(0.15))
                                        userSelections.navigationPath.append(instance.0)
                                    }
                                } label: {
                                    InstanceCard(mlImage: instance.0, cgImageCrop: instance.1, thumbnailSize: thumbnailSize)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            
            Spacer()
            
            //Buttons
            HStack{
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Text("Cancel")
                }
                Button(role: .destructive) {
                    let labelToDelete = mlClass.label
                    
                    // Remove the class from the MLSet and register undo/redo
                    mlSet.deleteClass(label: labelToDelete, undoManager: externalUndoManager)
                    dismiss()
                } label: {
                    Text("Delete Class")
                }

            }
            
        }
        .padding()
        .frame(width: 400, height: 480)
        
    }
}
