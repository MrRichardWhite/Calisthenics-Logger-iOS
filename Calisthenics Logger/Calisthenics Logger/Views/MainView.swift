//
//  MainView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 25.09.23.
//

import SwiftUI

struct MainView: View {
    @StateObject var viewModel = MainViewViewModel()
    
    var body: some View {
        if viewModel.isSignedIn, !viewModel.currentUserId.isEmpty {
            accountView
        } else {
            LoginView()
        }
    }
    
    @ViewBuilder
    var accountView: some View {
        TabView {
            WorkoutsView(userId: viewModel.currentUserId)
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
    MainView()
}
