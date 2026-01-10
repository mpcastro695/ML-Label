//
//  DrawingView.swift
//  ML Label
//
//  Created by Martin Castro on 10/11/22.
//

/// Embedds a SwiftUI View within a custom NSScrollView that handles drawing events. Reports relevant updates back up to AnnotatorView via callbacks.

import AppKit
import SwiftUI
import Vision

struct DrawingView<Content : View>: NSViewRepresentable {
    
    var drawEnabled: Bool
    var editEnabled: Bool
    var selectedRect: CGRect?
    var contentSize: CGSize
    var imageSize: CGSize
    var annotations: [MLBoundingBox]
    var onDraw: ((CGRect, Bool) -> Void)?
    var onEdit: ((CGPoint, NodePosition, Bool) -> Void)?
    var onTagClick: ((MLBoundingBox) -> Void)?
    
    private var content: Content
    
    init(drawEnabled: Bool = false, 
         editEnabled: Bool = false, 
         selectedRect: CGRect? = nil, 
         contentSize: CGSize = .zero,
         imageSize: CGSize = .zero,
         annotations: [MLBoundingBox] = [],
         onDraw: ((CGRect, Bool) -> Void)? = nil, 
         onEdit: ((CGPoint, NodePosition, Bool) -> Void)? = nil,
         onTagClick: ((MLBoundingBox) -> Void)? = nil,
         @ViewBuilder content: () -> Content) {
        self.drawEnabled = drawEnabled
        self.editEnabled = editEnabled
        self.selectedRect = selectedRect
        self.contentSize = contentSize
        self.imageSize = imageSize
        self.annotations = annotations
        self.onDraw = onDraw
        self.onEdit = onEdit
        self.onTagClick = onTagClick
        self.content = content()
    }
    
    func makeNSView(context: Context) -> DrawScrollView {
        
        let scrollView = DrawScrollView()
        
        let hostedView = context.coordinator.hostingController.view
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.height, .width]
        
        scrollView.documentView = hostedView
        scrollView.allowsMagnification = true
        scrollView.minMagnification = 1
        scrollView.hasVerticalScroller = true
        scrollView.hasHorizontalScroller = true
        scrollView.usesPredominantAxisScrolling = false
        
        scrollView.updateState(
            drawEnabled: drawEnabled,
            editEnabled: editEnabled,
            selectedRect: selectedRect,
            contentSize: contentSize,
            imageSize: imageSize,
            annotations: annotations,
            onDraw: onDraw,
            onEdit: onEdit,
            onTagClick: onTagClick
        )
        
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
    
    func updateNSView(_ nsView: DrawScrollView, context: Context) {
        nsView.updateState(
            drawEnabled: drawEnabled,
            editEnabled: editEnabled,
            selectedRect: selectedRect,
            contentSize: contentSize,
            imageSize: imageSize,
            annotations: annotations,
            onDraw: onDraw,
            onEdit: onEdit,
            onTagClick: onTagClick
        )
        context.coordinator.hostingController.rootView = content
    }
    
    // Custom NSScrollView subclass to handle drawing events
    class DrawScrollView: NSScrollView {
        
        var drawEnabled: Bool = false
        var editEnabled: Bool = false
        var selectedRect: CGRect?
        var drawingContentSize: CGSize = .zero
        var imageSize: CGSize = .zero
        var annotations: [MLBoundingBox] = []
        var onDraw: ((CGRect, Bool) -> Void)?
        var onEdit: ((CGPoint, NodePosition, Bool) -> Void)?
        var onTagClick: ((MLBoundingBox) -> Void)?
        
        private let overlayView = OverlayView()
        
        override var documentView: NSView? {
            didSet {
                overlayView.documentViewDidChange(documentView)
            }
        }
        
        override init(frame frameRect: NSRect) {
            super.init(frame: frameRect)
            setupOverlay()
        }
        
        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setupOverlay()
        }
        
        private func setupOverlay() {
            // Enable layer-backing for z-ordering to work correctly with SwiftUI
            self.wantsLayer = true
            overlayView.wantsLayer = true
            
            overlayView.translatesAutoresizingMaskIntoConstraints = false
            
            // Set reference BEFORE adding to superview so viewDidMoveToSuperview can use it
            overlayView.scrollView = self
            
            // Add overlay positioned above other subviews to ensure it receives events and cursor priority
            self.addSubview(overlayView, positioned: .above, relativeTo: nil)
            
            NSLayoutConstraint.activate([
                overlayView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
                overlayView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
                overlayView.topAnchor.constraint(equalTo: self.topAnchor),
                overlayView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        }
        
        func updateState(drawEnabled: Bool, 
                         editEnabled: Bool, 
                         selectedRect: CGRect?, 
                         contentSize: CGSize,
                         imageSize: CGSize,
                         annotations: [MLBoundingBox],
                         onDraw: ((CGRect, Bool) -> Void)?, 
                         onEdit: ((CGPoint, NodePosition, Bool) -> Void)?,
                         onTagClick: ((MLBoundingBox) -> Void)?) {
            self.drawEnabled = drawEnabled
            self.editEnabled = editEnabled
            self.selectedRect = selectedRect
            self.drawingContentSize = contentSize
            self.imageSize = imageSize
            self.annotations = annotations
            self.onDraw = onDraw
            self.onEdit = onEdit
            self.onTagClick = onTagClick
            
            overlayView.needsDisplay = true
            
            // Invalidate cursor rects for the overlay view specifically
            self.window?.invalidateCursorRects(for: overlayView)
        }
        
        class OverlayView: NSView {
            weak var scrollView: DrawScrollView?
            
            private var startPoint: NSPoint = .zero
            private var isDragging: Bool = false
            private var draggingNode: NodePosition?
            private let handleSize: CGFloat = 8.0
            
            // Keep track of observed objects to remove observers correctly
            private weak var observedDocumentView: NSView?
            
            func documentViewDidChange(_ newDocView: NSView?) {
                if let oldView = observedDocumentView {
                    NotificationCenter.default.removeObserver(self, name: NSView.frameDidChangeNotification, object: oldView)
                    NotificationCenter.default.removeObserver(self, name: NSView.boundsDidChangeNotification, object: oldView)
                }
                
                observedDocumentView = newDocView
                
                if let newView = newDocView {
                    NotificationCenter.default.addObserver(self, selector: #selector(refreshDisplay), name: NSView.frameDidChangeNotification, object: newView)
                    NotificationCenter.default.addObserver(self, selector: #selector(refreshDisplay), name: NSView.boundsDidChangeNotification, object: newView)
                }
                refreshDisplay()
            }
            
            override func viewDidMoveToSuperview() {
                super.viewDidMoveToSuperview()
                
                if self.superview != nil, let sv = scrollView {
                    // Added to superview
                    NotificationCenter.default.addObserver(self, selector: #selector(refreshDisplay), name: NSView.boundsDidChangeNotification, object: sv.contentView)
                    
                    sv.addObserver(self, forKeyPath: "magnification", options: .new, context: nil)
                    
                    NotificationCenter.default.addObserver(self, selector: #selector(refreshDisplay), name: NSScrollView.willStartLiveMagnifyNotification, object: sv)
                    NotificationCenter.default.addObserver(self, selector: #selector(refreshDisplay), name: NSScrollView.didEndLiveMagnifyNotification, object: sv)
                    
                    // Initial setup if doc view exists
                    if let docView = sv.documentView {
                        documentViewDidChange(docView)
                    }
                } else {
                    // Removed from superview or scrollView is nil
                    NotificationCenter.default.removeObserver(self, name: NSView.boundsDidChangeNotification, object: nil)
                    NotificationCenter.default.removeObserver(self, name: NSScrollView.willStartLiveMagnifyNotification, object: nil)
                    NotificationCenter.default.removeObserver(self, name: NSScrollView.didEndLiveMagnifyNotification, object: nil)
                    
                    if let sv = scrollView {
                        sv.removeObserver(self, forKeyPath: "magnification")
                    }
                }
            }
            
            override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
                if keyPath == "magnification" {
                    refreshDisplay()
                } else {
                    super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
                }
            }
            
            @objc func refreshDisplay() {
                self.needsDisplay = true
            }
            
            // Computes the padding offset of the content within the document view
            private func contentOffset(docSize: CGSize, contentSize: CGSize) -> CGPoint {
                let targetW = (contentSize.width > 0) ? contentSize.width : docSize.width
                let targetH = (contentSize.height > 0) ? contentSize.height : docSize.height
                let paddingX = (docSize.width - targetW) / 2
                let paddingY = (docSize.height - targetH) / 2
                return CGPoint(x: paddingX, y: paddingY)
            }
            
            override func draw(_ dirtyRect: NSRect) {
                guard let sv = scrollView, sv.editEnabled, let rect = sv.selectedRect, let docView = sv.documentView else { return }
                
                // rect is in Image Coordinates. Need to shift it by the padding in Document View.
                let offset = contentOffset(docSize: docView.bounds.size, contentSize: sv.drawingContentSize)
                var offsetRect = rect
                offsetRect.origin.x += offset.x
                offsetRect.origin.y += offset.y
                
                let viewRect = self.convert(offsetRect, from: docView)
                
                if viewRect.isEmpty { return }
                
                NSColor.white.setFill()
                NSColor.black.setStroke()
                
                let corners: [NodePosition] = [.topLeft, .topRight, .bottomLeft, .bottomRight]
                for corner in corners {
                    let p = pointForHandle(rect: viewRect, node: corner)
                    let handleRect = NSRect(x: p.x - handleSize/2, y: p.y - handleSize/2, width: handleSize, height: handleSize)
                    let path = NSBezierPath(ovalIn: handleRect)
                    path.fill()
                    path.stroke()
                }
            }
            
            private func pointForHandle(rect: CGRect, node: NodePosition) -> CGPoint {
                switch node {
                case .topLeft:
                    return self.isFlipped ? CGPoint(x: rect.minX, y: rect.minY) : CGPoint(x: rect.minX, y: rect.maxY)
                case .topRight:
                    return self.isFlipped ? CGPoint(x: rect.maxX, y: rect.minY) : CGPoint(x: rect.maxX, y: rect.maxY)
                case .bottomLeft:
                    return self.isFlipped ? CGPoint(x: rect.minX, y: rect.maxY) : CGPoint(x: rect.minX, y: rect.minY)
                case .bottomRight:
                    return self.isFlipped ? CGPoint(x: rect.maxX, y: rect.maxY) : CGPoint(x: rect.maxX, y: rect.minY)
                default:
                    return .zero
                }
            }
            
            private func hitTestTags(point: NSPoint, docView: NSView) -> MLBoundingBox? {
                 guard let sv = scrollView, sv.imageSize != .zero else { return nil }
                 
                 // Convert the click point from Overlay (viewport) space into DocumentView (content) space
                 let pointInDoc = self.convert(point, to: docView)
                 
                 // Calculate offset (centering padding) within the docView
                 let offset = contentOffset(docSize: docView.bounds.size, contentSize: sv.drawingContentSize)
                 
                 // Iterate to find if click is within a tag
                 for annotation in sv.annotations {
                     // Calculate Box Rect in Unscaled Image Coordinates
                     let origin = CGPoint(x: annotation.coordinates.x - annotation.coordinates.width/2,
                                          y: annotation.coordinates.y - annotation.coordinates.height/2)
                     let size = CGSize(width: annotation.coordinates.width, height: annotation.coordinates.height)
                     
                     let normalizedRect = VNNormalizedRectForImageRect(CGRect(origin: origin, size: size), Int(sv.imageSize.width), Int(sv.imageSize.height))
                     
                     // Scale to Drawing Size (e.g. the size of the Image view in SwiftUI)
                     let imageRect = VNImageRectForNormalizedRect(normalizedRect, Int(sv.drawingContentSize.width), Int(sv.drawingContentSize.height))
                     
                     // Shift by centering offset
                     var finalRect = imageRect
                     finalRect.origin.x += offset.x
                     finalRect.origin.y += offset.y
                     
                     // Calculate Tag Rect Position (Based on Annotator.swift layout)
                     let centerX = finalRect.minX + 25
                     let centerY = finalRect.minY + 15
                     
                     // Estimate Tag Size
                     let attributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 11)]
                     let stringSize = (annotation.label as NSString).size(withAttributes: attributes)
                     
                     // Padding(3) + minWidth(40) + Text + Extra padding for close button if needed
                     let contentWidth = max(40, stringSize.width + 20)
                     let contentHeight = max(20, stringSize.height + 6)
                     
                     let tagRect = CGRect(x: centerX - contentWidth/2,
                                          y: centerY - contentHeight/2,
                                          width: contentWidth,
                                          height: contentHeight)
                     
                     if tagRect.contains(pointInDoc) {
                         return annotation
                     }
                 }
                 return nil
             }
            
            override func hitTest(_ point: NSPoint) -> NSView? {
                // Correctly convert point from superview coordinates
                let viewPoint = self.convert(point, from: self.superview)
                guard let sv = scrollView else { return nil }
                
                // Hit test edit handles
                if sv.editEnabled, let rect = sv.selectedRect, let docView = sv.documentView {
                    let offset = contentOffset(docSize: docView.bounds.size, contentSize: sv.drawingContentSize)
                    var offsetRect = rect
                    offsetRect.origin.x += offset.x
                    offsetRect.origin.y += offset.y
                    
                    let viewRect = self.convert(offsetRect, from: docView)
                    
                    let corners: [NodePosition] = [.topLeft, .topRight, .bottomLeft, .bottomRight]
                    for corner in corners {
                        let p = pointForHandle(rect: viewRect, node: corner)
                        let hitZone = NSRect(x: p.x - handleSize, y: p.y - handleSize, width: handleSize*2, height: handleSize*2)
                        if hitZone.contains(viewPoint) {
                            return self
                        }
                    }
                }
                
                // Hit test Tags
                if let _ = sv.onTagClick, let docView = sv.documentView {
                    if hitTestTags(point: viewPoint, docView: docView) != nil {
                        return self
                    }
                }
                
                // Hit test Background for Drawing
                if sv.drawEnabled {
                    return self
                }
                
                return nil
            }
            
            override func mouseDown(with event: NSEvent) {
                guard let sv = scrollView else { return }
                let locationInView = self.convert(event.locationInWindow, from: nil)
                
                // Check Tags
                if let onTagClick = sv.onTagClick, let docView = sv.documentView {
                    if let hitAnnotation = hitTestTags(point: locationInView, docView: docView) {
                        onTagClick(hitAnnotation)
                        return // Consume event
                    }
                }
                
                // Check Handles
                if sv.editEnabled, let rect = sv.selectedRect, let docView = sv.documentView {
                    let offset = contentOffset(docSize: docView.bounds.size, contentSize: sv.drawingContentSize)
                    var offsetRect = rect
                    offsetRect.origin.x += offset.x
                    offsetRect.origin.y += offset.y
                    
                    let viewRect = self.convert(offsetRect, from: docView)
                    
                    let corners: [NodePosition] = [.topLeft, .topRight, .bottomLeft, .bottomRight]
                    for corner in corners {
                        let p = pointForHandle(rect: viewRect, node: corner)
                        let hitZone = NSRect(x: p.x - handleSize, y: p.y - handleSize, width: handleSize*2, height: handleSize*2)
                        if hitZone.contains(locationInView) {
                            draggingNode = corner
                            isDragging = true
                            return
                        }
                    }
                }
                
                // Check Drawing
                if sv.drawEnabled {
                    if let documentView = sv.documentView {
                        startPoint = documentView.convert(event.locationInWindow, from: nil)
                        isDragging = false
                    }
                }
            }
            
            override func mouseDragged(with event: NSEvent) {
                guard let sv = scrollView else { return }
                
                if sv.editEnabled && isDragging, let node = draggingNode {
                    reportEdit(event: event, node: node, isEditing: true)
                    self.needsDisplay = true
                } else if sv.drawEnabled {
                    isDragging = true
                    reportRect(event: event, isEditing: true)
                }
            }
            
            override func mouseUp(with event: NSEvent) {
                guard let sv = scrollView else { return }
                
                if sv.editEnabled && isDragging, let node = draggingNode {
                    reportEdit(event: event, node: node, isEditing: false)
                    draggingNode = nil
                    isDragging = false
                    self.needsDisplay = true
                } else if sv.drawEnabled {
                    if isDragging {
                        reportRect(event: event, isEditing: false)
                    }
                    isDragging = false
                }
            }
            
            private func reportEdit(event: NSEvent, node: NodePosition, isEditing: Bool) {
                guard let sv = scrollView, let documentView = sv.documentView, let onEdit = sv.onEdit else { return }
                
                let endPoint = documentView.convert(event.locationInWindow, from: nil)
                let offset = contentOffset(docSize: documentView.bounds.size, contentSize: sv.drawingContentSize)
                
                var point = endPoint
                point.x -= offset.x
                point.y -= offset.y
                
                let targetW = (sv.drawingContentSize.width > 0) ? sv.drawingContentSize.width : documentView.bounds.width
                let targetH = (sv.drawingContentSize.height > 0) ? sv.drawingContentSize.height : documentView.bounds.height
                
                // Clamp point to valid image area to prevent out-of-bounds coordinates
                point.x = max(0, min(point.x, targetW))
                point.y = max(0, min(point.y, targetH))
            
                let normalizedPoint = CGPoint(x: point.x / targetW, y: point.y / targetH)
                
                onEdit(normalizedPoint, node, isEditing)
            }
            
            private func reportRect(event: NSEvent, isEditing: Bool) {
                guard let sv = scrollView, let documentView = sv.documentView, let onDraw = sv.onDraw else { return }
                
                let endPoint = documentView.convert(event.locationInWindow, from: nil)
                
                let originX = min(startPoint.x, endPoint.x)
                let originY = min(startPoint.y, endPoint.y)
                let width = abs(endPoint.x - startPoint.x)
                let height = abs(endPoint.y - startPoint.y)
                
                var rect = CGRect(x: originX, y: originY, width: width, height: height)
                
                let offset = contentOffset(docSize: documentView.bounds.size, contentSize: sv.drawingContentSize)
                rect.origin.x -= offset.x
                rect.origin.y -= offset.y
                
                let targetW = (sv.drawingContentSize.width > 0) ? sv.drawingContentSize.width : documentView.bounds.width
                let targetH = (sv.drawingContentSize.height > 0) ? sv.drawingContentSize.height : documentView.bounds.height
                
                let normalizedRect = VNNormalizedRectForImageRect(rect, Int(targetW), Int(targetH))
                
                onDraw(normalizedRect, isEditing)
            }
        }
    }
}
