//
//  MetadateTemplate.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import Foundation

struct MetadateTemplate: Codable, Identifiable {
    let id: String
    let name: String
    let unit: String
    let elementsCount: Int
    let created: TimeInterval
    let edited: TimeInterval
}
