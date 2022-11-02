//
//  ClassListRow.swift
//  ML Label
//
//  Created by Martin Castro on 10/16/21.
//

import SwiftUI

struct ClassListRowView: View {
    
    @EnvironmentObject var mlSet: MLSetDocument
    @ObservedObject var mlClass: MLClass
    
    @State private var classDetailSheetVisible: Bool = false
    
    var body: some View {
        
        HStack{
            Image(systemName: "tag.square")
                .foregroundColor(Color(red: mlClass.color.red, green: mlClass.color.green, blue: mlClass.color.blue))
                .font(.system(size: 20))
                .frame(width: 25, height: 25)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            
            VStack(alignment: .leading) {
                Text(mlClass.label)
                Text("\(mlClass.tagCount()) instances")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button {
                classDetailSheetVisible.toggle()
            } label: {
                Image(systemName: "info.circle")
                    .foregroundColor(.secondary)
            }.buttonStyle(.plain)

        }//END HSTACK
        .sheet(isPresented: $classDetailSheetVisible, content: {
            ClassDetailSheet(mlClass: mlClass)
        })
        .padding(.horizontal, 5)
    }
}

//struct ClassListRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ClassListRow()
//    }
//}
