//
//  NewWorkoutView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import SwiftUI

struct NewWorkoutView: View {
    @StateObject var viewModel: NewWorkoutViewViewModel
    @Binding var newWorkoutPresented: Bool
    
    let userId: String
    
    init(userId: String, newWorkoutPresented: Binding<Bool>) {
        self.userId = userId
        self._newWorkoutPresented = newWorkoutPresented
        self._viewModel = StateObject(
            wrappedValue: NewWorkoutViewViewModel(
                userId: userId
            )
        )
    }
    
    var body: some View {
        VStack {
            Text("New Workout")
                .font(.system(size: 32))
                .bold()
                .padding(.top)
            
            Form {
                DatePicker("Time", selection: $viewModel.time)
                    .datePickerStyle(GraphicalDatePickerStyle())
                
                TextField("Location", text: $viewModel.location)
                
                Picker("Template", selection: $viewModel.pickedWorkoutTemplateId) {
                    ForEach(viewModel.workoutTemplateIds, id: \.self) { workoutTemplateId in
                        let text = viewModel.id2name(
                            id: workoutTemplateId
                        )
                        Text(text)
                    }
                }
                
                CLButton(title: "Add", background: viewModel.background) {
                    if viewModel.canSave {
                        viewModel.save(
                            userId: userId
                        )
                        newWorkoutPresented = false
                    } else {
                        viewModel.showAlert = true
                    }
                }
                .padding()
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text("Please fill in the location field!")
                )
            }
        }
    }
}

#Preview {
    NewWorkoutView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        newWorkoutPresented: Binding(
            get: { return true },
            set: { _ in }
        )
    )
}
