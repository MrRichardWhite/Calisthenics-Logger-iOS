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
                title: "Register",
                subtitle: "Start Logging",
                angle: -15,
                background: .orange)
            
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
                    title: "Create Account",
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
            .offset(y: -50)
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage)
                )
            }
            
            Spacer()
        }
    }
}

#Preview {
    RegisterView()
}
