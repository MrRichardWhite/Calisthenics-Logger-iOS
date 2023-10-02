//
//  NewWorkoutTemplateView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import SwiftUI

struct NewWorkoutTemplateView: View {
    @StateObject var viewModel = NewWorkoutTemplateViewViewModel()
    @Binding var newWorkoutTemplatePresented: Bool
    
    let userId: String
    
    var body: some View {
        VStack {
            Text("New Workout Template")
                .font(.system(size: 32))
                .bold()
                .padding(.top)
            
            Form {
                // Name
                TextField("Name", text: $viewModel.name)
                
                // Button
                CLButton(title: "Save", background: .green) {
                    if viewModel.canSave {
                        viewModel.save(
                            userId: userId
                        )
                        newWorkoutTemplatePresented = false
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
    NewWorkoutTemplateView(
        newWorkoutTemplatePresented: Binding(
            get: { return true },
            set: { _ in }
        ),
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1"
    )
}
