//
//  Calisthenics_LoggerApp.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 25.09.23.
//

import FirebaseCore
import SwiftUI

@main
struct Calisthenics_LoggerApp: App {
    init(){
        FirebaseApp.configure()
    }
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
}
