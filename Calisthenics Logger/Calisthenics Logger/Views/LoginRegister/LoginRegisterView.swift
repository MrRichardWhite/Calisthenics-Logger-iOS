//
//  LoginRegisterView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.10.23.
//

import SwiftUI

struct LoginRegisterView: View {
    var body: some View {
        TabView {
            LoginView()
                .tabItem {
                    Label("Login", systemImage: "pencil")
                }
            
            RegisterView()
                .tabItem {
                    Label("Register", systemImage: "plus")
                }
        }
    }
}

#Preview {
    LoginRegisterView()
}
