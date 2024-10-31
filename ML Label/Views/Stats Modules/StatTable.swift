//
//  StatTableView.swift
//  ML Label
//
//  Created by Martin Castro on 1/29/23.
//

import SwiftUI

struct StatTable: View {
    
    var rowData: [(String, String)]
    
    var body: some View {
        VStack(spacing: 0){
            ForEach(rowData, id: \.0) { row in
                HStack{
                    Text("\(row.0)")
                    Spacer()
                    Text("\(row.1)")
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 2)
                if row.0 != rowData.last!.0 {
                    Divider()
                }
            }
        }
        .background(RoundedRectangle(cornerRadius: 10).stroke(style: StrokeStyle(lineWidth: 1)).foregroundColor(.secondary.opacity(0.2)))
    }
}
