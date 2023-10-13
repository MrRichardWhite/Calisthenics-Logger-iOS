//
//  Sample.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 12.10.23.
//

import Foundation

struct Sample: Codable, Identifiable {
    var id: String
    var date: TimeInterval
    var content: Double
}
