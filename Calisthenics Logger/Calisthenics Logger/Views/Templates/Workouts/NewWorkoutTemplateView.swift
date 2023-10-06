//
//  NewWorkoutTemplateView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import SwiftUI

struct NewWorkoutTemplateView: View {
    @StateObject var viewModel: NewWorkoutTemplateViewViewModel
    @Binding var newWorkoutTemplatePresented: Bool
    
    private let userId: String
    
    init(userId: String, newWorkoutTemplatePresented: Binding<Bool>) {
        self.userId = userId
        
        self._newWorkoutTemplatePresented = newWorkoutTemplatePresented
        
        self._viewModel = StateObject(
            wrappedValue: NewWorkoutTemplateViewViewModel(
                userId: userId
            )
        )
    }
    
    var body: some View {
        VStack {
            Text("New Workout Template")
                .font(.system(size: 32))
                .bold()
                .padding(.top)
            
            Form {
                TextField("Name", text: $viewModel.name)
                
                CLButton(title: "Add", background: viewModel.background) {
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
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        newWorkoutTemplatePresented: Binding(
            get: { return true },
            set: { _ in }
        )    )
}
