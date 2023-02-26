//
//  ImageDataItem.swift
//  ML Label
//
//  Created by Martin Castro on 10/16/21.
//

import SwiftUI
import Vision

/// A  reference to an image on disk and its annotation data
class MLImage: Identifiable, Codable, ObservableObject, Hashable {
    
    let id: UUID
    let fileURL: URL
    
    let name: String
    
    @Published var annotations: [MLBoundingBox]
    
    let width: Int
    let height: Int
    
    private var bookmarkData: Data
    
    // URL is checked before initializing MLImage Instances via DropDelegate
    init(fileURL: URL) {
        do {
            //Create bookmark data for access on new app launch
            let nsURL =  NSURL(fileURLWithPath: fileURL.path)
            bookmarkData = try nsURL.bookmarkData(options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)
        }catch{
            print("Error creating bookmark data: \(error)")
            bookmarkData = Data()
        }
        self.id = UUID()
        self.fileURL = fileURL
        self.name = fileURL.lastPathComponent
        self.width = Int(NSImage(contentsOf: fileURL)?.size.width ?? 0)
        self.height = Int(NSImage(contentsOf: fileURL)?.size.height ?? 0)
        
        annotations = []
        print("MLImage Created successfully for: \(self.name)")
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        //Use bookmark data to get a security scoped URL
        bookmarkData = try container.decode(Data.self, forKey: .bookmarkData)
        let securityScopedURL = try NSURL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: nil, bookmarkDataIsStale: nil)
        securityScopedURL.startAccessingSecurityScopedResource()
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.fileURL = securityScopedURL.filePathURL!
        self.name = try container.decode(String.self, forKey: .name)
        self.annotations = try container.decode([MLBoundingBox].self, forKey: .annotations)
        self.width = try container.decode(Int.self, forKey: .width)
        self.height = try container.decode(Int.self, forKey: .height)
    }
    
    //MARK: - Class Functions
    func addAnnotation(normalizedRect: CGRect, label: String) {
        let pixelRect = VNImageRectForNormalizedRect(normalizedRect, width, height)
        let mlCoordinates = MLCoordinates(x: Int(pixelRect.midX),
                                          y: Int(pixelRect.midY),
                                         width: Int(pixelRect.width),
                                         height: Int(pixelRect.height))
        let mlBox = MLBoundingBox(label: label,
                                  coordinates: mlCoordinates)
        annotations.append(mlBox)
        update()
    }
    
    func removeAnnotation(id: UUID) {
        annotations.removeAll(where: {$0.id == id})
    }
    
    func update(){
        objectWillChange.send()
    }
    
}

//MARK: - Codable Conformance
extension MLImage {
        
        enum CodingKeys: String, CodingKey {
            case id
            case fileURL
            case bookmarkData
            case name
            case annotations
            case width
            case height
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(id, forKey: .id)
            try container.encode(fileURL, forKey: .fileURL)
            try container.encode(bookmarkData, forKey: .bookmarkData)
            try container.encode(name, forKey: .name)
            try container.encode(annotations, forKey: .annotations)
            try container.encode(width, forKey: .width)
            try container.encode(height, forKey: .height)
        }
}

// MARK: - Hashable Conformance
extension MLImage {
    static func == (lhs: MLImage, rhs: MLImage) -> Bool {
        return lhs.id == rhs.id
    }
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}
