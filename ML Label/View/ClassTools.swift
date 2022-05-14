//
//  ClassTools.swift
//  ML Label
//
//  Created by Martin Castro on 5/13/22.
//

import SwiftUI

struct ClassTools: View {
    
    @EnvironmentObject var mlSet: MLSet
    @Binding var classSelection: MLClass?
    
    @State var newClassDialogShowing: Bool = false
    

    var body: some View {
        
        VStack{
            if mlSet.classes.count == 0 {
                VStack{
                    Image(systemName: "plus.app")
                        .font(.system(size: 20))
                        .padding(.bottom, 5)
                    Text("Create class labels")
                }
                .padding()
            }else{
                List{
                    ForEach(mlSet.classes) { classLabel in
                        Button {
                            classSelection = classLabel
                        } label: {
                            ClassRow(classLabel: classLabel)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
            
            Button {
                newClassDialogShowing = true
            } label: {
                Text("Add New Class")
            }
        }
        .sheet(isPresented: $newClassDialogShowing, content: {
            NewClassDialog()
        })
       
        
    }
}

//struct ClassTools_Previews: PreviewProvider {
//    static var previews: some View {
//        ClassTools()
//    }
//}