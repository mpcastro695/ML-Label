# ML Label

A prototype bounding box annotation tool written in SwiftUI. Annotate a set of images and export a JSON list ready for [Create ML](https://developer.apple.com/documentation/createml/building-an-object-detector-data-source) model training.

###### ⚠️ Note: this project is no longer maintained.

### ✅ What it Has
- Drag and drop image import
- Editable bounding boxes
- Export annotations as a JSON list in Create ML compatible format
- Save and resume projects with .mlset files

### ❌ What it’s Missing 
- Ability to delete images & classes
- Undo functionality
- Search/sort functionality
- Ability to export annotations in different formats
- Grouping instances of class labels

### 📝 Known Issues (the fix list)
- Thumbnails need to be downsized to reduce memory footprint
- Zooming in on an image (via AppKit’s `NSScrollView`) breaks SwiftUI buttons/gestures inside the view
- JSON `annotation` objects have an extraneous id parameter

## Installation

Download the Xcode project and build it.

![Alt text](<ML Label/Assets.xcassets/SetDash.imageset/SetDash.png>)
![Alt text](<ML Label/Assets.xcassets/Annotator.imageset/Annotator.png>)

