//
//  SizeReader.swift
//  ML Label
//
//  Created by Martin Castro on 4/5/22.
//

import SwiftUI

struct SizeReader: ViewModifier {
    
    @Binding var size: CGSize
    
    private var geometryOverlay: some View {
        GeometryReader{ geometry in
            Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
            /// Set PreferenceKey value
        }
    }
    
    func body(content: Content) -> some View{
        content.overlay(geometryOverlay)
            .onPreferenceChange(SizePreferenceKey.self) { sizeValue in
                self.size = sizeValue
                /// Update size Binding
            }
    }
}

struct SizePreferenceKey: PreferenceKey {
    /// Report information back up the view hierarchy

  static var defaultValue: CGSize = .zero

  static func reduce(value _: inout CGSize, nextValue: () -> CGSize) {
    _ = nextValue()
  }
}

// Convenience view modifier
extension View {
  func sizeReader(size: Binding<CGSize>) -> some View {
      modifier(SizeReader(size: size))
  }
}
