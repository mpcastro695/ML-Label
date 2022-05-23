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
            Button {
                newClassDialogShowing = true
            } label: {
                Text("Add New Class")
            }
            if mlSet.classes.count == 0 {
                VStack{
                    Image(systemName: "plus.app")
                        .font(.system(size: 20))
                        .padding(.bottom, 5)
                    Text("Create class labels")
                }
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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
