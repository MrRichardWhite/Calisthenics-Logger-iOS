//
//  NewExerciseTemplateView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import SwiftUI

struct NewExerciseTemplateView: View {
    @StateObject var viewModel: NewExerciseTemplateViewViewModel
    @Binding var newExerciseTemplatePresented: Bool
    
    private let userId: String
    
    init(userId: String, newExerciseTemplatePresented: Binding<Bool>) {
        self.userId = userId
        
        self._newExerciseTemplatePresented = newExerciseTemplatePresented
        
        self._viewModel = StateObject(
            wrappedValue: NewExerciseTemplateViewViewModel(
                userId: userId
            )
        )
    }
    
    var body: some View {
        VStack {
            Text("New Exercise Template")
                .font(.system(size: 32))
                .bold()
                .padding(.top)
            
            Form {
                TextField("Name", text: $viewModel.name)
                
                CLButton(title: "Add", background: viewModel.background) {
                    if viewModel.canSave {
                        viewModel.save()
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
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        newExerciseTemplatePresented: Binding(
            get: { return true },
            set: { _ in }
        )
    )
}
