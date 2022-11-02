//
//  AnnotatableImage.swift
//  ML Label
//
//  Created by Martin Castro on 10/11/22.
//

import Vision
import AppKit
import SwiftUI


struct VNRectGesture: ViewModifier {
    
    //Closure that returns isEditing and a normalizedRect as parameters
    let normalizedRect: (Bool, CGRect) -> Void
    
    func body(content: Content) -> some View {
        content.overlay {
            GeometryReader{ geometry in
                NSGestureView(normalizedRect: normalizedRect, geometry.frame(in: .global))
            }
        }
    }
    
//MARK: - NSViewRepresentable
    private struct NSGestureView: NSViewRepresentable {
        
        let normalizedRect: (Bool, CGRect) -> Void
        let trackingView: NSView
        
        init(normalizedRect: @escaping (Bool, CGRect) -> Void, _ frame: NSRect) {
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
            let normalizedRect: (Bool, CGRect) -> Void
            
            private var dragDetected = false
            private var startLocation = CGPoint()
            private var endLocation = CGPoint()
            
            init(in view: NSView, normalizedRect: @escaping (Bool, CGRect) -> Void) {
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
                normalizedRect(true, NormalizedRectForDragGesture())
            }
            // Returns normalized rect with isEditing = false
            override func mouseUp(with event: NSEvent) {
                if dragDetected{
                    endLocation = NSPointToCGPoint(nsPoint: trackingView.convert(event.locationInWindow, from: nil))
                    normalizedRect(false, NormalizedRectForDragGesture())
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
    func vnRectGesture(normalizedRect: @escaping (_ isEditing: Bool, _ rect: CGRect) -> Void) -> some View {
        modifier(VNRectGesture(normalizedRect: normalizedRect))
    }
}

