//
//  RegisterView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import SwiftUI

struct RegisterView: View {
    @StateObject var viewModel = RegisterViewViewModel()
    
    var body: some View {
        VStack {
            HeaderView(
                title: "Calisthenics Logger",
                subtitle: "Document & Analyze your Workouts!",
                background: .green
            )
            
            registerFormView
                .offset(y: -10)
        }
        .offset(y: -60)
        .ignoresSafeArea(.keyboard)
    }
    
    @ViewBuilder
    var registerFormView: some View {
        Form {
            TextField("Full Name", text: $viewModel.name)
                .autocorrectionDisabled()
            TextField("Athlete Name", text: $viewModel.athleteName)
                .autocorrectionDisabled()
            TextField("Email Address", text: $viewModel.email)
                .autocorrectionDisabled()
                .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
            SecureField("Password", text: $viewModel.password)

            CLButton(
                title: "Register",
                background: .green
            ) {
                if viewModel.canRegister {
                    viewModel.register()
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
    RegisterView()
}
