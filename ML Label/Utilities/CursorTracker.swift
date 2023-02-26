//
//  CursorTracking.swift
//  ML Label
//
//  Created by Martin Castro on 9/30/22.
//

/// An overlay that generates cursor location update events.
///

import AppKit
import SwiftUI

/// An overlay that generates cursor position update events.
///
/// Use the `cursorIsInside` closure to get a `CGPoint` containing the current cursor position within the overlay, and a `Bool` representing whether the cursor is within frame.
///

struct CursorTracker: ViewModifier {
    
    /// Returns updates on the cursor position within a View
    ///
    /// NSPoint (lower left origin) are converted to SwiftUI coordinates (upper left origin)
    let cursorIsInside: (Bool, CGPoint) -> Void
    
    func body(content: Content) -> some View{
        
        content.overlay(
            GeometryReader { geometry in
                // Uses an Empty NSView overlay to track and convert mouse coordinates
                // NSPoint coordinates (lower left origin) are converted to SwiftUI coordinates (upper left origin)
                NSCursorTrackerView(cursorIsInside: cursorIsInside, geometry.frame(in: .global))
            })
    }
    
//MARK: - NSViewRepresentable
    
    private struct NSCursorTrackerView: NSViewRepresentable {
        
        let cursorIsInside: (Bool, CGPoint) -> Void
        let trackingView: NSView
        
        init(cursorIsInside: @escaping (Bool, CGPoint) -> Void, _ frame: NSRect) {
            self.cursorIsInside = cursorIsInside
            self.trackingView = NSView(frame: frame)
        }
        
        //Protocol Requirement
        func makeNSView(context: Context) -> NSView {
            
            let trackingOptions: NSTrackingArea.Options = [
                .mouseEnteredAndExited,
                .mouseMoved,
                .inVisibleRect,
                .activeInKeyWindow]
            let trackingArea = NSTrackingArea(rect: trackingView.frame,
                                              options: trackingOptions,
                                              owner: context.coordinator,
                                              userInfo: nil)
            trackingView.addTrackingArea(trackingArea)
            return trackingView
        }
        
        // NSResponder that handles the NSEvents from the NSTrackingArea
        class Coordinator: NSResponder {
    
            var cursorIsInside: ((Bool, CGPoint) -> Void)?
            var inside: Bool = false
            var trackingView: NSView?
            
            //Coordinates converted from lower left origin to upper left origin
            override func mouseEntered(with event: NSEvent) {
                inside = true
                cursorIsInside?(true, NSPointToCGPoint(nsPoint: trackingView!.convert(event.locationInWindow, from: nil)))
            }
            override func mouseExited(with event: NSEvent) {
                inside = false
                cursorIsInside?(false, NSPointToCGPoint(nsPoint: trackingView!.convert(event.locationInWindow, from: nil)))
            }
            override func mouseMoved(with event: NSEvent) {
                cursorIsInside?(inside, NSPointToCGPoint(nsPoint: trackingView!.convert(event.locationInWindow, from: nil)))
            }
//MARK: - Helper Functions
            private func NSPointToCGPoint (nsPoint: NSPoint) -> CGPoint {
                return CGPoint(x: nsPoint.x, y: trackingView!.frame.height - nsPoint.y)
            }
        }
        
        // Protocol Requirement
        func makeCoordinator() -> Coordinator {
            let coordinator = Coordinator()
            coordinator.cursorIsInside = cursorIsInside
            coordinator.trackingView = trackingView
            return coordinator
        }
        
        //Protocol Requirement
        func updateNSView(_ nsView: NSView, context: Context) {}
        
        static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
            nsView.trackingAreas.forEach { nsView.removeTrackingArea($0) }
        }
    }
    
}

// MARK: -  Convenience View Modifier
extension View {
    func cursorTracker(_ cursorIsInside: @escaping (Bool, CGPoint) -> Void) -> some View {
        modifier(CursorTracker(cursorIsInside: cursorIsInside))
    }
}

