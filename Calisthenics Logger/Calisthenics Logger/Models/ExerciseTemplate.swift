//
//  ExerciseTemplate.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import Foundation

struct ExerciseTemplate: Codable, Identifiable {
    let id: String
    let name: String
    let category: String
    let metadateTemplateIds: [String]
    let created: TimeInterval
    let edited: TimeInterval
}
