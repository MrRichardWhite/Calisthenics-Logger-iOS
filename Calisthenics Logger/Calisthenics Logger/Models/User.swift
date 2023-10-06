//
//  User.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import Foundation

struct User: Codable {
    let id: String
    let name: String
    let athleteName: String
    let email: String
    let joined: TimeInterval
}
