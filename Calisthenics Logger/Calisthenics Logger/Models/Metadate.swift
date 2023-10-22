//
//  Metadate.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 28.09.23.
//

import Foundation

struct Metadate: Codable, Identifiable {
    let id: String
    var name: String
    var unit: String
    let created: TimeInterval
    var edited: TimeInterval
    
    init(
        id: String = UUID().uuidString,
        name: String = "", unit: String = "",
        created: TimeInterval = Date().timeIntervalSince1970, edited: TimeInterval = Date().timeIntervalSince1970
    ) {
        self.id = id
        self.name = name
        self.unit = unit
        self.created = created
        self.edited = edited
    }
}
