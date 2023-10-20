//
//  Filter.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 08.10.23.
//

import Foundation

struct Filter: Codable, Identifiable {
    let id: String
    var metadateTemplateId: String
    var relation: String
    var bound: String
    let created: TimeInterval
    let edited: TimeInterval
}

var relations: [String] = ["=", "≠", "≤", "<", "≥", ">"]
