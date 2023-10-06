//
//  Metadate.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 28.09.23.
//

import Foundation

struct Metadate: Codable, Identifiable {
    let id: String
    let name: String
    let unit: String
    let created: TimeInterval
    let edited: TimeInterval
}
