//
//  Element.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 29.09.23.
//

import Foundation

struct Element: Codable, Identifiable {
    let id: String
    let content: String
    let created: TimeInterval
}
