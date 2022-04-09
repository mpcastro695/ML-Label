//
//  SizeReader.swift
//  ML Label
//
//  Created by Martin Castro on 4/5/22.
//

import SwiftUI

struct SizeReader: ViewModifier {
    
    @Binding var size: CGSize
    
    private var sizeReaderOverlay: some View {
        GeometryReader{ geometry in
            Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
        }
    }
    
    func body(content: Content) -> some View{
        content.overlay(sizeReaderOverlay)
            .onPreferenceChange(SizePreferenceKey.self) { sizeValue in
                self.size = sizeValue
            }
    }
}

// Convenience view modifier
extension View {
  func sizeReader(size: Binding<CGSize>) -> some View {
      modifier(SizeReader(size: size))
  }
}

// PreferenceKey
// Allows us to report information back up the view hierarchy
struct SizePreferenceKey: PreferenceKey {
  
  static var defaultValue: CGSize = .zero

  static func reduce(value _: inout CGSize, nextValue: () -> CGSize) {
    _ = nextValue()
  }
}
