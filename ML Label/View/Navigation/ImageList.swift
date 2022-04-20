//
//  ImageList.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import SwiftUI

struct ImageList: View {
    
    @EnvironmentObject var mlSet: MLSet
    
    @State var selectedClassLabel = MLClass(label: "No Class Labels", color: MLColor(red: 50/255, green: 50/255, blue: 50/255))
    
    var body: some View {
        
        ZStack{
            // If images have not been added, prompts user to add images
            if mlSet.images.count == 0 {
                VStack{
                    Image(systemName: "plus.app")
                        .font(.system(size: 20))
                        .padding(.bottom, 5)
                    Text("Drag or add images.")
                }
                .padding()
                
            // If images have been added, displays list.
            }else{
                List{
                    ForEach(mlSet.images) { image in
                        NavigationLink(
                            destination: ImageDetail(image: image, selectedClassLabel: $selectedClassLabel),
                            label: {
                                ImageRow(image: image)
                            })
                    }
                }
            }
        }
        .onDrop(of: [.fileURL], delegate: mlSet)
        
// MARK: - Toolbar Items
        .toolbar{
        
            Button(action: {print("Sort")}, label: {
                Image(systemName: "arrow.up.arrow.down").font(.body.weight(.heavy))
            }).disabled(mlSet.images.count == 0)
            
        }
        
//MARK: Set Class Label
        
        // When the list appears, the first class label from classStore is set as selectedClassLabel
        .onAppear(perform: {
            if mlSet.classes.count != 0 {
                selectedClassLabel = mlSet.classes[0]
            }
        })
        
        
        
    }
}

struct ImageList_Previews: PreviewProvider {
    static var previews: some View {
        ImageList()
    }
}
