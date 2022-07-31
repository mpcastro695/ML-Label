//
//  ClassListRow.swift
//  ML Label
//
//  Created by Martin Castro on 10/16/21.
//

import SwiftUI

struct ClassRowView: View {
    
    @EnvironmentObject var mlSet: MLSetDocument
    @ObservedObject var mlClass: MLClass
    
    var body: some View {
        
        HStack{
            Image(systemName: "tag.square")
                .foregroundColor(Color(red: mlClass.color.red, green: mlClass.color.green, blue: mlClass.color.blue))
                .font(.system(size: 20))
                .frame(width: 25, height: 25)
                .clipShape(RoundedRectangle(cornerRadius: 5))
            
            VStack(alignment: .leading) {
                Text(mlClass.label)
                Text("\(mlClass.annotations.count) tags")
                    .font(.caption)
            }
            
            Spacer()
            
            Button {
                mlSet.removeClass(label: mlClass.label)
            } label: {
                Image(systemName: "xmark.circle")
            }.buttonStyle(.plain)

            
        }
    }
}

//struct ClassListRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ClassListRow()
//    }
//}
