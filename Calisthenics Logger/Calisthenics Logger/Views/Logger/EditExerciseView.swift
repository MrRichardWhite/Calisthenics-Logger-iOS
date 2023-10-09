//
//  EditExerciseView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 09.10.23.
//

import SwiftUI

struct EditExerciseView: View {
    @StateObject var viewModel: EditExerciseViewViewModel
    @Binding var editExercisePresented: Bool
    
    private let userId: String
    private let workoutId: String
    private let exerciseId: String

    init(userId: String, workoutId: String, exerciseId: String, editExercisePresented: Binding<Bool>) {
        self.userId = userId
        self.workoutId = workoutId
        self.exerciseId = exerciseId
        self._editExercisePresented = editExercisePresented
        
        self._viewModel = StateObject(
            wrappedValue: EditExerciseViewViewModel(
                userId: userId,
                workoutId: workoutId,
                exerciseId: exerciseId
            )
        )
    }
    var body: some View {
        Form {
            TextField("Name", text: $viewModel.name)
            
            TextField("Category", text: $viewModel.category)
            
            CLButton(title: "Save", background: viewModel.background) {
                if viewModel.canSave && !viewModel.dataIsInit {
                    viewModel.save(
                        userId: userId
                    )
                    editExercisePresented = false
                } else {
                    if !viewModel.canSave {
                        viewModel.alertTitle = "Error"
                        viewModel.alertMessage = "Please fill in the name field!"
                    }
                    if viewModel.dataIsInit {
                        viewModel.alertTitle = "Warning"
                        viewModel.alertMessage = "Data was not changed!"
                    }
                    viewModel.showAlert = true
                }
            }
            .padding()
        }
        .alert(isPresented: $viewModel.showAlert) {
            Alert(
                title: Text(viewModel.alertTitle),
                message: Text(viewModel.alertMessage)
            )
        }
    }
}

#Preview {
    EditExerciseView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        workoutId: "07FCE443-3617-422E-B396-E34F05421D3E",
        exerciseId: "0FE3F549-61A2-41CF-9C25-80AB0E20C78B",
        editExercisePresented: Binding(
            get: { return true },
            set: { _ in }
        )
    )
}
