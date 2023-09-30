//
//  AccountView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import SwiftUI

struct AccountView: View {
    @StateObject var viewModel: AccountViewViewModel
    
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        self._viewModel = StateObject(
            wrappedValue: AccountViewViewModel(userId: userId)
        )
    }
    
    var body: some View {
        TabView {
            LoggerView(userId: userId)
                .tabItem {
                    Label("Logger", systemImage: "pencil")
                }
            TemplatesView()
                .tabItem {
                    Label("Templates", systemImage: "newspaper")
                }
            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.xyaxis.line")
                }
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.circle")
                }
        }
    }
}

#Preview {
    AccountView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1"
    )
}
