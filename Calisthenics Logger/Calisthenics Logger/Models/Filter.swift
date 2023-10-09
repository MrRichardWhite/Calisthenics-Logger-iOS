//
//  Filter.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 08.10.23.
//

import Foundation

struct Filter: Codable, Identifiable {
    let id: String
    let metadateTemplateId: String
    let relation: String
    let bound: String
    let created: TimeInterval
    let edited: TimeInterval
}
