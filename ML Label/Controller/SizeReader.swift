//
//  SizeReader.swift
//  ML Label
//
//  Created by Martin Castro on 10/15/21.
//

import SwiftUI

// Wraps View in ViewSizeReader
struct SizeReader<Content: View>: View {
    
    @Binding var size: CGSize

    let content: () -> Content
    
    // Attaches a Geometry Reader to our View's background.
    var body: some View {
      content().background(
        GeometryReader { proxy in
          Color.clear.preference(
            key: SizePreferenceKey.self,
            value: proxy.size
          )
        }
      )
      .onPreferenceChange(SizePreferenceKey.self) { preferences in
        self.size = preferences
      }
    }
}

// Size Preference Key which holds current value
struct SizePreferenceKey: PreferenceKey {
  typealias Value = CGSize
  static var defaultValue: Value = .zero

  static func reduce(value _: inout Value, nextValue: () -> Value) {
    _ = nextValue()
  }
}

// Convenience View Modifier
extension View {
  func size(size: Binding<CGSize>) -> some View {
    SizeReader(size: size) {
      self
    }
  }
}
