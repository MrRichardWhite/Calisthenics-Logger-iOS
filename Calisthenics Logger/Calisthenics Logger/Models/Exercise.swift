//
//  Exercise.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import Foundation

struct Exercise: Codable, Identifiable {
    let id: String
    let name: String
    let created: TimeInterval
    let edited: TimeInterval
}
