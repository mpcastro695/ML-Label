//
//  JSONObject.swift
//  ML Label
//
//  Created by Martin Castro on 4/19/22.
//

import Foundation

struct JSONObject: Encodable {
    
    // Final JSON object for annotation export
    let imagefilename: String
    let annotation: [MLBoundingBox]

}
