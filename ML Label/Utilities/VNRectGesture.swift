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
    
    ///- Parameter rect: Returns a CGRect, drawn between the gesture’s current and start location in a Vision normalized coordinate space
    ///- Parameter isEditing: A bool that returns true while the drag gesture is active and false when completed
    ///
    let normalizedRect: (_ rect: CGRect, _ isEditing: Bool) -> Void
    
    func body(content: Content) -> some View {
        content.overlay {
            GeometryReader{ geometry in
                NSGestureView(normalizedRect: normalizedRect, geometry.frame(in: .global))
            }
        }
    }
    
//MARK: - NSViewRepresentable
    private struct NSGestureView: NSViewRepresentable {
        
        let normalizedRect: (CGRect, Bool) -> Void
        let trackingView: NSView
        
        init(normalizedRect: @escaping (CGRect, Bool) -> Void, _ frame: NSRect) {
            self.normalizedRect = normalizedRect
            self.trackingView = NSView(frame: frame)
        }
        
        //Attach gesture recognizer to empty NSView
        func makeNSView(context: Context) -> some NSView {
            let gesture = NormalizedRectForDragGesture(in: trackingView, normalizedRect: normalizedRect)
            trackingView.addGestureRecognizer(gesture)
            return trackingView
        }
        func updateNSView(_ nsView: NSViewType, context: Context) {}
 
        //Nested gesture recognizer
        class NormalizedRectForDragGesture: NSGestureRecognizer {
            
            let trackingView: NSView
            let normalizedRect: (CGRect, Bool) -> Void
            
            private var dragDetected = false
            private var startLocation = CGPoint()
            private var endLocation = CGPoint()
            
            init(in view: NSView, normalizedRect: @escaping (CGRect, Bool) -> Void) {
                self.trackingView = view
                self.normalizedRect = normalizedRect
                super.init(target: nil, action: nil)
            }
            required init?(coder: NSCoder) {
                fatalError("init(coder:) has not been implemented")
            }
            
            // Sets startLocation
            override func mouseDown(with event: NSEvent) {
                startLocation = NSPointToCGPoint(nsPoint: trackingView.convert(event.locationInWindow, from: nil))
            }
            // Detects if dragged, returns normalized rect with isEditing = true
            override func mouseDragged(with event: NSEvent) {
                dragDetected = true
                endLocation = NSPointToCGPoint(nsPoint: trackingView.convert(event.locationInWindow, from: nil))
                normalizedRect(NormalizedRectForDragGesture(), true)
            }
            // Returns normalized rect with isEditing = false
            override func mouseUp(with event: NSEvent) {
                if dragDetected{
                    endLocation = NSPointToCGPoint(nsPoint: trackingView.convert(event.locationInWindow, from: nil))
                    normalizedRect(NormalizedRectForDragGesture(), false)
                }
                reset()
            }
            override func reset() {
                dragDetected = false
                startLocation = CGPoint()
                endLocation = CGPoint()
            }
            static func dismantleNSView(_ nsView: NSView, coordinator: Coordinator) {
                nsView.gestureRecognizers.removeAll()
            }

            //MARK: - Helper Functions
            
            //Convert NSPoint to CGPoint
            private func NSPointToCGPoint (nsPoint: NSPoint) -> CGPoint {
                //Appkit uses a lower left origin, SwiftUI uses an upper left origin
                return CGPoint(x: nsPoint.x, y: trackingView.frame.height - nsPoint.y)
            }
            
            // Computes the normalized rect
            private func NormalizedRectForDragGesture () -> CGRect {
                let origin = startLocation
                //Clips gesture values to within frame bounds
                let width = max(0, min(endLocation.x, trackingView.frame.width)) - startLocation.x
                let height = max(0, min(endLocation.y, trackingView.frame.height)) - startLocation.y
                
                let cgRect = CGRect(origin: origin, size: CGSize(width: width, height: height)).standardized
                
                let normalizedRect = VNNormalizedRectForImageRect(cgRect, Int(trackingView.frame.width), Int(trackingView.frame.height))
                return normalizedRect
            }
        }//END NSGESTURERECOGNIZER
        
    }//END NSVIEWREPRESENTABLE
}

//MARK: - Convenience View Modifier
extension View {
    func vnRectGesture(normalizedRect: @escaping (_ normalizedrect: CGRect, _ isEditing: Bool) -> Void) -> some View {
        modifier(VNRectGesture(normalizedRect: normalizedRect))
    }
}

