//
//  WorkoutTemplate.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import Foundation

struct WorkoutTemplate: Codable, Identifiable {
    let id: String
    let name: String
    let exerciseTemplateIds: [String]
    let created: TimeInterval
}
