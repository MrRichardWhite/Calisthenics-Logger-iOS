//
//  LoginViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import FirebaseAuth
import Foundation

class LoginViewViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var showAlert = false
    
    init() {}
    
    func login() {
        guard canLogIn else {
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password)
    }
    
    var canLogIn: Bool {
        guard !email.trimmingCharacters(in: .whitespaces).isEmpty,
              !password.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please fill in all fields!"
            return false
        }
        
        guard email.contains("@"), email.contains(".") else {
            errorMessage = "Please enter a valid email address!"
            return false
        }
        
        return true
    }
}
