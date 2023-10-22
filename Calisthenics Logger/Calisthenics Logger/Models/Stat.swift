//
//  Stat.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 08.10.23.
//

import Foundation

struct Stat: Codable, Identifiable {
    let id: String
    var exerciseTemplateId: String
    var metadateTemplateId: String
    var aggregation: String
    var unit: String
    let created: TimeInterval
    var edited: TimeInterval
    
    init(id: String = UUID().uuidString,
         exerciseTemplateId: String = "", metadateTemplateId: String = "",
         aggregation: String = "",
         unit: String = "",
         created: TimeInterval = Date().timeIntervalSince1970, edited: TimeInterval = Date().timeIntervalSince1970) {
        self.id = id
        self.exerciseTemplateId = exerciseTemplateId
        self.metadateTemplateId = metadateTemplateId
        self.aggregation = aggregation
        self.unit = unit
        self.created = created
        self.edited = edited
    }
}

var aggregations: [String] = ["max", "min", "sum", "mean"]
