//
//  NewWorkoutView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import SwiftUI

struct NewWorkoutView: View {
    @StateObject var viewModel = NewWorkoutViewViewModel()
    @Binding var newWorkoutPresented: Bool
    
    let templates = ["🫥 empty", "🫸 push", "🤜 pull", "🦵 legs"]

    var body: some View {
        VStack {
            Text("New Workout")
                .font(.system(size: 32))
                .bold()
                .padding(.top)
            
            Form {
                // Time
                DatePicker("Time", selection: $viewModel.time)
                    .datePickerStyle(GraphicalDatePickerStyle())

                // Place
                TextField("Location", text: $viewModel.location)

                // Template
                Picker("Template", selection: $viewModel.template) {
                    ForEach(templates, id: \.self) {
                        Text($0)
                    }
                }
                
                // Button
                CLButton(title: "Save", background: .pink) {
                    if viewModel.canSave {
                        viewModel.save()
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
    NewWorkoutView(newWorkoutPresented: Binding(get: {
        return true
    }, set: {_ in
        
    }))
}
