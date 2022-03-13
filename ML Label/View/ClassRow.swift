//
//  ClassListRow.swift
//  ML Label
//
//  Created by Martin Castro on 10/16/21.
//

import SwiftUI

struct ClassRow: View {
    
    var classLabel: LabelData
    
    var body: some View {
        
        HStack{
            Image(systemName: "tag.fill")
                .foregroundColor(classLabel.color)
                .font(.system(size: 18))
                .frame(width: 30, height: 30)
                .background(Color.secondary.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 5))
            
            VStack(alignment: .leading) {
                Text(classLabel.label)
                Text("\(classLabel.annotations.count) tags")
                    .font(.caption)
            }
            
            // If annotations are have been made, an annotation count
            if classLabel.annotations.count > 0 {
                Spacer()
                Text("\(classLabel.annotations.count)")
                    .font(.caption)
                    .bold()
                    .padding(.horizontal, 10)
                    .padding(.vertical, 2)
                    .background(Color.secondary.opacity(0.3))
                    .clipShape(Capsule())
            }
            
        }
    }
}

//struct ClassListRow_Previews: PreviewProvider {
//    static var previews: some View {
//        ClassListRow()
//    }
//}
