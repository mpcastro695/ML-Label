//
//  SizeReader.swift
//  ML Label
//
//  Created by Martin Castro on 4/5/22.
//

import SwiftUI

/// An overlay that reports the view's current CGSize
///
/// Use the `size` binding to recieve updates on the current size of the attached view.
///

struct SizeReader: ViewModifier {
    
    @Binding var size: CGSize
    
    func body(content: Content) -> some View{
        content.overlay(
            GeometryReader{ geometry in
                Color.clear.preference(key: SizePreferenceKey.self, value: geometry.size)
            }
        )
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
