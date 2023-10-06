//
//  Workout.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import Foundation

struct Workout: Codable, Identifiable {
    let id: String
    let name: String
    let time: TimeInterval
    let location: String
    let created: TimeInterval
    let edited: TimeInterval
}
