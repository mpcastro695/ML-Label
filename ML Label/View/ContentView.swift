//
//  ContentView.swift
//  HSplitView
//
//  Created by Martin Castro on 3/18/22.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var mlSet: MLSet
    
    @State var classSelection: MLClass?
    @State var imageSelection: MLImage?
    
    @State var addEnabled: Bool = false
    @State var removeEnabled: Bool = false
    
   var body: some View {
       
      GeometryReader{ geometry in // Use a GeometryReader to size the HSplitView.
         HSplitView{

             //MARK: - Main Pane/Annotation Pane
             
             ZStack{
                 if mlSet.images.count == 0 {
                     VStack{
                         Image(systemName: "photo")
                             .font(.system(size: 20))
                             .foregroundColor(.secondary.opacity(0.3))
                             .padding(.bottom, 10)
                         Text("Add Photos to Start")
                             .foregroundColor(.secondary.opacity(0.3))
                     }
                     .padding()
                     .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.secondary.opacity(0.05)))
                     .frame(maxWidth: .infinity, maxHeight: .infinity)

                 }else if imageSelection == nil {
                     VStack{
                         Image(systemName: "photo")
                             .font(.system(size: 20))
                             .foregroundColor(.secondary.opacity(0.3))
                             .padding(.bottom, 10)
                         Text("Choose a Photo to Start Annotating")
                             .foregroundColor(.secondary.opacity(0.3))
                     }
                     .padding()
                     .background(RoundedRectangle(cornerRadius: 10).foregroundColor(.secondary.opacity(0.05)))
                     .frame(maxWidth: .infinity, maxHeight: .infinity)
                     
                 }else{
                     // Add check to see if image: NSImage? is available
                     AnnotationView(mlImage: imageSelection!, classSelection: classSelection, addEnabled: addEnabled, removeEnabled: removeEnabled)
                 }
             }
             .onDrop(of: [.fileURL], delegate: mlSet)
             .frame(minWidth: geometry.size.width * 0.6)
             .layoutPriority(1)
             
             // MARK: - Tool Pane
             
             ToolPanelView(classSelection: $classSelection, imageSelection: $imageSelection, addEnabled: $addEnabled, removeEnabled: $removeEnabled)
                 .frame(minWidth: 300)
             
         }//END HSPLITVIEW
         .frame(width: geometry.size.width, height: geometry.size.height)
          
      }//END GEOMETRY READER
      .frame(minWidth: 1000, minHeight: 600)
   }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
