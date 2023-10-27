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
            AccountView(userId: viewModel.currentUserId)
        } else {
            LoginRegisterView()
        }
    }
}

#Preview {
    MainView()
}
