//
//  LineBorder.swift
//  ML Label
//
//  Created by Martin Castro on 9/4/22.
//

import SwiftUI

struct LineBorderStyle: ButtonStyle {
    
    @State var hovering = false
    
    func makeBody(configuration: Configuration) -> some View {
           configuration.label
               .padding(5)
               .foregroundColor(.primary)
               .background(RoundedRectangle(cornerRadius: 4)
                            .stroke(style: StrokeStyle(lineWidth: 1))
               )
               .onHover { over in
                   hovering = over
               }
               .opacity(configuration.isPressed ? 1.0 : 0.8)
               
               .contentShape(Rectangle())
               
       }
}
