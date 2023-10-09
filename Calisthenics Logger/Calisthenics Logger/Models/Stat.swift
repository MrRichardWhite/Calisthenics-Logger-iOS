//
//  Stat.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 08.10.23.
//

import Foundation

struct Stat: Codable, Identifiable {
    let id: String
    let exerciseTemplateId: String
    let metadateTemplateId: String
    let created: TimeInterval
    let edited: TimeInterval
}
