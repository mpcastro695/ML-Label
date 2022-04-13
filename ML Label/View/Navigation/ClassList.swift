//
//  ClassList.swift
//  ML Label
//
//  Created by Martin Castro on 10/16/21.
//

import SwiftUI

struct ClassList: View {
    
    @EnvironmentObject var classStore: MLClassSet
    @State var showAddNewClass = false
    
    var body: some View {
        
        ZStack{
            if classStore.classes.count == 0 {
                
                VStack{
                    Image(systemName: "plus.app")
                        .font(.system(size: 20))
                        .padding(.bottom, 5)
                    Text("Create class labels")
                }
                .padding()
                
            }else{
                List{
                    ForEach(classStore.classes) { classLabel in
                        NavigationLink(
                            destination: ClassDetail(classLabel: classLabel),
                            label: {
                                ClassRow(classLabel: classLabel)
                            })
                    }
                }
            }
        }
        
// MARK: - Toolbar Items
        
        .toolbar{
            Button(action: {print("Delete class")}, label: {
                Image(systemName: "trash").font(.body.weight(.heavy))
            }).disabled(classStore.classes.count == 0)
            
            Button(action: {showAddNewClass = true}, label: {
                Image(systemName: "plus.rectangle").font(.body.weight(.heavy))
                    .foregroundColor(.primary)
            })
        }
        
        .sheet(isPresented: $showAddNewClass, content: {
            NewClassDialog()
        })
        
        
    }
}

struct ClassList_Previews: PreviewProvider {
    static var previews: some View {
        ClassList()
    }
}
