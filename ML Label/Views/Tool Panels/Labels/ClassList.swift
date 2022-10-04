//
//  ClassList.swift
//  ML Label
//
//  Created by Martin Castro on 7/17/22.
//

import SwiftUI

struct ClassList: View {
    
    @EnvironmentObject var mlSet: MLSetDocument
    @Binding var classSelection: MLClass?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            
            let highlight = RoundedRectangle(cornerRadius: 5)
                .foregroundColor(Color.primary)
                .opacity(0.05)
            
            let clearView = RoundedRectangle(cornerRadius: 5)
                .foregroundColor(Color.clear)
                .opacity(0)
            
            VStack{
                ForEach(mlSet.classes) { mlClass in
                    ClassListRow(mlClass: mlClass)
                        .frame(height: 25)
                        .padding(3)
                        .contentShape(Rectangle())
                        .background(classSelection == mlClass ? highlight : clearView)
                        .onTapGesture {
                            classSelection = mlClass
                        }
                }
            }
        }
        
    }
}
