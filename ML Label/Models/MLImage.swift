//
//  ImageDataItem.swift
//  ML Label
//
//  Created by Martin Castro on 10/16/21.
//

import SwiftUI
import Vision

class MLImage: Identifiable, Codable, ObservableObject, Hashable {
    
    var id = UUID()
    let fileURL: URL
    
    let name: String
    
    @Published var annotations: [MLBoundingBox]
    
    let width: Int
    let height: Int
    
    private var bookmarkData: Data
    
    // URL is checked before initializing MLImage Instances via DropDelegate
    init(imageURL: URL) {
        do {
            //Use NSURL to create bookmark data for access on new app launch
            let nsURL =  NSURL(fileURLWithPath: imageURL.path)
            bookmarkData = try nsURL.bookmarkData(options: [.withSecurityScope], includingResourceValuesForKeys: [URLResourceKey.pathKey], relativeTo: imageURL.absoluteURL)
        }catch{
            print("Error creating bookmark data: \(error)")
            bookmarkData = Data()
        }
        fileURL = imageURL
        name = imageURL.lastPathComponent
        width = Int(NSImage(contentsOf: imageURL)?.size.width ?? 0)
        height = Int(NSImage(contentsOf: imageURL)?.size.height ?? 0)
        
        annotations = []
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        //Use bookmark data to get a security scoped URL
        bookmarkData = try container.decode(Data.self, forKey: .bookmarkData)
        let diskURL = try container.decode(URL.self, forKey: .fileURL)
        let securityScopedURL = try NSURL(resolvingBookmarkData: bookmarkData, options: .withSecurityScope, relativeTo: diskURL, bookmarkDataIsStale: nil)
        securityScopedURL.startAccessingSecurityScopedResource()
        
        fileURL = securityScopedURL.filePathURL!
        name = try container.decode(String.self, forKey: .name)
        annotations = try container.decode([MLBoundingBox].self, forKey: .annotations)
        width = try container.decode(Int.self, forKey: .width)
        height = try container.decode(Int.self, forKey: .height)
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
            case fileURL
            case bookmarkData
            case name
            case annotations
            case width
            case height
        }
        
        func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
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
