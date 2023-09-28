//
//  Workout.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import Foundation

struct Workout: Codable, Identifiable {
    let id: String
    let time: TimeInterval
    let location: String
    let created: TimeInterval
}
