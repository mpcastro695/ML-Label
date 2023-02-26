//
//  ZoomNScroll.swift
//  ML Label
//
//  Created by Martin Castro on 10/11/22.
//

/// Embedds a SwiftUI View within an NSScrollView
///
/// Allows for magnifcation and panning of your view

import AppKit
import SwiftUI

struct MagnificationView<Content : View>: NSViewRepresentable {
    
    private var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    func makeNSView(context: Context) -> some NSView {
        
        let scrollView = NSScrollView()
        
        let hostedView = context.coordinator.hostingController.view
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.height, .width]
        
        scrollView.documentView = hostedView
        scrollView.allowsMagnification = true
        scrollView.minMagnification = 1
        scrollView.hasVerticalScroller = true
        scrollView.hasVerticalScroller = true
        scrollView.usesPredominantAxisScrolling = false
        scrollView.documentCursor = NSCursor.crosshair
        
        return scrollView
    }
    
    class Coordinator: NSObject {
        var hostingController: NSHostingController<Content>
        
        init(hostingController: NSHostingController<Content>) {
              self.hostingController = hostingController
            }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(hostingController: NSHostingController(rootView: content))
    }
    
    func updateNSView(_ nsView: NSViewType, context: Context) {
        context.coordinator.hostingController.rootView = content
    }
}
