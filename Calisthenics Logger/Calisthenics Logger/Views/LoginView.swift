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
                // Header
                HeaderView(
                    title: "Calisthenics Logger",
                    subtitle: "Document & Analyze your Workouts!",
                    angle: 15,
                    background: .pink
                )
                
                // Login Form
                Form {
                    TextField("Email Address", text: $viewModel.email)
                        .autocorrectionDisabled()
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                    SecureField("Password", text: $viewModel.password)

                    CLButton(
                        title: "Log In",
                        background: .blue
                    ) {
                        // Attempt log in
                        if viewModel.canLogIn {
                            viewModel.login()
                        } else {
                            viewModel.showAlert = true
                        }
                    }
                    .padding()
                }
                .offset(y: -50)
                .alert(isPresented: $viewModel.showAlert) {
                    Alert(
                        title: Text("Error"),
                        message: Text(viewModel.errorMessage)
                    )
                }
                
                // Create Account
                VStack {
                    Text("New around here?")
                    NavigationLink("Create an Account",
                                   destination: RegisterView())
                }
                .padding(.bottom, 50)
                
                Spacer()
            }
        }
    }
}

#Preview {
    LoginView()
}
