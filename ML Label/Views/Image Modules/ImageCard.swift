//
//  ImageThumbnail.swift
//  ML Label
//
//  Created by Martin Castro on 7/13/22.
//

import SwiftUI

@available(macOS 14.0, *)
struct ImageCard: View {
    
    @ObservedObject var mlImage: MLImage
    @EnvironmentObject var userSelections: UserSelections
    let thumbnailSize: CGFloat
    
    @State var nsThumbnail: NSImage? = nil
    
    var body: some View {
        
        //Thumbnail is cropped to a 1:1 square
        ZStack(alignment: .bottomTrailing){
            Rectangle()
                .aspectRatio(1, contentMode: .fill)
                .task {
                    if let thumbnail = await createThumbnail(from: NSImage(byReferencing: mlImage.fileURL),
                                                       minDimension: thumbnailSize) {
                        nsThumbnail = thumbnail
                    }
                }
                .overlay {
                    if nsThumbnail != nil {
                        Image(nsImage: nsThumbnail!)
                            .resizable()
                            .scaledToFill()
                    }
                }
            HStack{ //Card Details
                Text("\(mlImage.name)")
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .padding(.leading, 5)
                Spacer()
                if mlImage.annotations.count != 0 {
                    Text("\(mlImage.annotations.count)")
                        .font(.caption)
                        .padding(5)
                        .background(.gray.opacity(0.5))
                        .clipShape(Circle())
                        .padding(8)
                }
            }//END HSTACK
            .frame(height: 25)
            .background(.thickMaterial)
        }//END ZSTACK
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

@available(macOS 14.0, *)
struct InstanceCard: View {
    
    @ObservedObject var mlImage: MLImage
    let cgImageCrop: CGImage
    let thumbnailSize: CGFloat
    
    @State var nsThumbnail: NSImage? = nil
    
    var body: some View {
        
        //Thumbnail is cropped to a 1:1 square
        ZStack(alignment: .bottomTrailing) {
            Rectangle()
                .aspectRatio(1, contentMode: .fill)
                .task {
                    let nsImage = NSImage(cgImage: cgImageCrop,
                                          size: NSSize(width: cgImageCrop.width,
                                                       height: cgImageCrop.height))
                    if let thumbnail = await createThumbnail(from: nsImage,
                                                       minDimension: thumbnailSize) {
                        nsThumbnail = thumbnail
                    }
                }
                .overlay {
                    if nsThumbnail != nil {
                        Image(nsImage: nsThumbnail!)
                            .resizable()
                            .scaledToFill()
                    }
                }
            HStack(alignment: .center) { //Card Details
                Text("\(mlImage.name)")
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .padding(.leading, 5)
                Spacer()
            }//END HSTACK
            .frame(height: 25)
            .background(.thickMaterial)
        }//END ZSTACK
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

@available(macOS 14.0, *)
public func createThumbnail(from image: NSImage, minDimension: CGFloat) async -> NSImage? {
    // Access CGImage on the calling thread to ensure safety
    guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
    
    return await Task.detached(priority: .userInitiated) {
        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        
        // Avoid division by zero
        guard width > 0, height > 0 else { return nil }
        
        let aspectRatio = width / height
        
        var newWidth: CGFloat
        var newHeight: CGFloat
        
        // Determine dimensions based on smallest side
        if width < height {
            newWidth = minDimension
            newHeight = minDimension / aspectRatio
        } else {
            newHeight = minDimension
            newWidth = minDimension * aspectRatio
        }
        
        let colorSpace = CGColorSpace(name: CGColorSpace.sRGB) ?? cgImage.colorSpace ?? CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue
        
        guard let context = CGContext(data: nil,
                                      width: Int(newWidth),
                                      height: Int(newHeight),
                                      bitsPerComponent: 8,
                                      bytesPerRow: 0,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo) else {
            return nil
        }
        
        context.interpolationQuality = .high
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        
        if let newCGImage = context.makeImage() {
            return NSImage(cgImage: newCGImage, size: NSSize(width: newWidth, height: newHeight))
        }
        return nil
    }.value
}
