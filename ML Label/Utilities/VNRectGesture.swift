//
//  AnnotatableImage.swift
//  ML Label
//
//  Created by Martin Castro on 10/11/22.
//

import Vision
import AppKit
import SwiftUI


/// An overlay that generates bounding box update events for drag gestures.
///
/// Use the `normalizedRect` closure to get a `CGRect`, drawn between the gesture’s current and start location in a `Vision` normalized coordinate space, and a `Bool` representing the status of the gesture.
///

struct VNRectGesture: ViewModifier {
    
    var isEnabled: Bool = true
    
    ///- Parameter rect: Returns a CGRect, drawn between the gesture’s current and start location in a Vision normalized coordinate space
    ///- Parameter isEditing: A bool that returns true while the drag gesture is active and false when completed
    ///
    let normalizedRect: (_ rect: CGRect, _ isEditing: Bool) -> Void
    
    func body(content: Content) -> some View {
        content.overlay {
            VNRectGestureView(isEnabled: isEnabled, normalizedRect: normalizedRect)
        }
    }
    
//MARK: - NSViewRepresentable
    private struct VNRectGestureView: NSViewRepresentable {
        
        var isEnabled: Bool
        let normalizedRect: (CGRect, Bool) -> Void
        
        func makeNSView(context: Context) -> DraggableView {
            let view = DraggableView()
            view.wantsLayer = true // Critical for correct hit-testing when zoomed
            view.autoresizingMask = [.width, .height]
            view.isEnabled = isEnabled
            view.normalizedRect = normalizedRect
            return view
        }
        
        func updateNSView(_ nsView: DraggableView, context: Context) {
            nsView.isEnabled = isEnabled
            nsView.normalizedRect = normalizedRect
        }
        
        // Custom NSView to handle mouse events directly
        class DraggableView: NSView {
            
            var isEnabled: Bool = true
            var normalizedRect: ((CGRect, Bool) -> Void)?
            
            private var startLocation = CGPoint()
            private var endLocation = CGPoint()
            private var isDragging = false
            
            override var acceptsFirstResponder: Bool { true }
            
            override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
                return true
            }
            
            override func mouseDown(with event: NSEvent) {
                if !isEnabled {
                    super.mouseDown(with: event)
                    return
                }
                
                // Convert coordinates from window
                startLocation = flip(convert(event.locationInWindow, from: nil))
                isDragging = false
            }
            
            override func mouseDragged(with event: NSEvent) {
                if !isEnabled {
                    super.mouseDragged(with: event)
                    return
                }
                
                isDragging = true
                endLocation = flip(convert(event.locationInWindow, from: nil))
                
                let rect = calculateRect()
                normalizedRect?(rect, true)
            }
            
            override func mouseUp(with event: NSEvent) {
                if !isEnabled {
                    super.mouseUp(with: event)
                    return
                }
                
                if isDragging {
                    endLocation = flip(convert(event.locationInWindow, from: nil))
                    let rect = calculateRect()
                    normalizedRect?(rect, false)
                }
                isDragging = false
            }
            
            // Helper to flip Y coordinate from Bottom-Left (NSView) to Top-Left (SwiftUI/Vision-style)
            private func flip(_ point: NSPoint) -> CGPoint {
                return CGPoint(x: point.x, y: bounds.height - point.y)
            }
            
            private func calculateRect() -> CGRect {
                let origin = startLocation
                // Clips values to within frame bounds
                let width = max(0, min(endLocation.x, bounds.width)) - startLocation.x
                let height = max(0, min(endLocation.y, bounds.height)) - startLocation.y
                
                let cgRect = CGRect(origin: origin, size: CGSize(width: width, height: height)).standardized
                
                return VNNormalizedRectForImageRect(cgRect, Int(bounds.width), Int(bounds.height))
            }
        }
        
    }//END NSVIEWREPRESENTABLE
}

//MARK: - Convenience View Modifier
extension View {
    func vnRectGesture(isEnabled: Bool = true, normalizedRect: @escaping (_ normalizedrect: CGRect, _ isEditing: Bool) -> Void) -> some View {
        modifier(VNRectGesture(isEnabled: isEnabled, normalizedRect: normalizedRect))
    }
}
