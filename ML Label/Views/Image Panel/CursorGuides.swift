//
//  CursorGuides.swift
//  ML Label
//
//  Created by Martin Castro on 10/2/22.
//

import SwiftUI

struct CursorGuides: ViewModifier {
    
    let cursorIsInside: Bool
    let cursorPosition: CGPoint
    
    func body(content: Content) -> some View {
        content.overlay {
            Canvas{ context, size in
                
                if cursorIsInside{
                    let horizontalGuide = Path{ path in
                        path.move(to: CGPoint(x: .zero, y: cursorPosition.y))
                        path.addLine(to: CGPoint(x: size.width, y: cursorPosition.y))
                    }
                    let verticalGuide = Path{ path in
                        path.move(to: CGPoint(x: cursorPosition.x, y: .zero))
                        path.addLine(to: CGPoint(x: cursorPosition.x, y: size.height))
                    }
                    
                    context.stroke(horizontalGuide, with: .color(.white), lineWidth: 1)
                    context.stroke(verticalGuide, with: .color(.white), lineWidth: 1)
                }
                
            }
        }
    }
}

extension View {
    func cursorGuides(cursorIsInside: Bool, cursorPosition: CGPoint) -> some View {
        modifier(CursorGuides(cursorIsInside: cursorIsInside, cursorPosition: cursorPosition))
    }
}
