//
//  JSONObject.swift
//  ML Label
//
//  Created by Martin Castro on 4/19/22.
//

import Foundation

struct JSONAnnotation: Encodable {
    
    // Final JSON object for annotation export
    let image: String
    let annotations: [MLBoundingBox]

}
