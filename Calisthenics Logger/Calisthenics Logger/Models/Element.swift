//
//  Element.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 29.09.23.
//

import Foundation

struct Element: Codable, Identifiable {
    let id: String
    var content: String
    let created: TimeInterval
    var edited: TimeInterval
    
    init(
        id: String = UUID().uuidString,
        content: String = "",
        created: TimeInterval = Date().timeIntervalSince1970, edited: TimeInterval = Date().timeIntervalSince1970
    ) {
        self.id = id
        self.content = content
        self.created = created
        self.edited = edited
    }
}
