//
//  NewExerciseTemplateView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import SwiftUI

struct NewExerciseTemplateView: View {
    @StateObject var viewModel = NewExerciseTemplateViewViewModel()
    @Binding var newExerciseTemplatePresented: Bool
    
    let userId: String
    
    var body: some View {
        VStack {
            Text("New Exercise Template")
                .font(.system(size: 32))
                .bold()
                .padding(.top)
            
            Form {
                // Name
                TextField("Name", text: $viewModel.name)
                
                // Button
                CLButton(title: "Save", background: .pink) {
                    if viewModel.canSave {
                        viewModel.save(
                            userId: userId
                        )
                        newExerciseTemplatePresented = false
                    } else {
                        viewModel.showAlert = true
                    }
                }
                .padding()
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text("Please fill in the name field!")
                )
            }
        }
    }
}

#Preview {
    NewExerciseTemplateView(
        newExerciseTemplatePresented: Binding(
            get: { return true },
            set: { _ in }
        ),
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1"
    )
}
