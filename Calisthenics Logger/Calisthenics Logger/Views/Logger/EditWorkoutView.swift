//
//  EditWorkoutView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 09.10.23.
//

import SwiftUI

struct EditWorkoutView: View {
    @StateObject var viewModel: EditWorkoutViewViewModel
    @Binding var editWorkoutPresented: Bool
    
    private let userId: String
    private let workoutId: String

    init(userId: String, workoutId: String, editWorkoutPresented: Binding<Bool>) {
        self.userId = userId
        self.workoutId = workoutId
        self._editWorkoutPresented = editWorkoutPresented
        
        self._viewModel = StateObject(
            wrappedValue: EditWorkoutViewViewModel(
                userId: userId,
                workoutId: workoutId
            )
        )
    }

    var body: some View {
        Form {
            TextField("Name", text: $viewModel.name)
            
            DatePicker("Time", selection: $viewModel.time)
                .datePickerStyle(GraphicalDatePickerStyle())
            
            TextField("Location", text: $viewModel.location)
            
            CLButton(title: "Save", background: viewModel.background) {
                if viewModel.canSave && !viewModel.dataIsInit {
                    viewModel.save(
                        userId: userId
                    )
                    editWorkoutPresented = false
                } else {
                    if !viewModel.canSave {
                        viewModel.alertTitle = "Error"
                        viewModel.alertMessage = "Please fill in all fields!"
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
    EditWorkoutView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        workoutId: "07FCE443-3617-422E-B396-E34F05421D3E",
        editWorkoutPresented: Binding(
            get: { return true },
            set: { _ in }
        )
    )
}
