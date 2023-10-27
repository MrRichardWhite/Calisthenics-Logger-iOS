//
//  LoginView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel = LoginViewViewModel()
    
    var body: some View {
        NavigationView {
            VStack {
                HeaderView(
                    title: "Calisthenics Logger",
                    subtitle: "Document & Analyze your Workouts!",
                    background: .yellow
                )
                
                loginFormView
                    .offset(y: -10)
            }
            .offset(y: -60)
            .ignoresSafeArea(.keyboard)
        }
    }
    
    @ViewBuilder
    var loginFormView: some View {
        Form {
            TextField("Email Address", text: $viewModel.email)
                .autocorrectionDisabled()
                .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
            SecureField("Password", text: $viewModel.password)
            
            CLButton(
                title: "Login",
                background: .yellow
            ) {
                if viewModel.canLogIn {
                    viewModel.login()
                } else {
                    viewModel.showAlert = true
                }
            }
            .padding()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text("Error"),
                message: Text(viewModel.errorMessage)
            )
        }
    }
}

#Preview {
    LoginView()
}
