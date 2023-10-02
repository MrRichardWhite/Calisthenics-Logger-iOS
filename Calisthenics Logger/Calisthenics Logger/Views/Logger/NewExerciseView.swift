//
//  NewExerciseView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 29.09.23.
//

import SwiftUI

struct NewExerciseView: View {
    @StateObject var viewModel = NewExerciseViewViewModel()
    @Binding var newExercisePresented: Bool
    
    let userId: String
    let workoutId: String
    
    let templates = ["", "Pull-ups", "Push-ups", "Dips"]

    var body: some View {
        VStack {
            Text("New Exercise")
                .font(.system(size: 32))
                .bold()
                .padding(.top)
            
            Form {
                // Template
                Picker("Template", selection: $viewModel.template) {
                    ForEach(templates, id: \.self) {
                        Text($0)
                    }
                }
                
                // Button
                CLButton(title: "Save", background: .green) {
                    viewModel.save(
                        userId: userId,
                        workoutId: workoutId
                    )
                    newExercisePresented = false
                }
                .padding()
            }
        }
    }
}

#Preview {
    NewExerciseView(
        newExercisePresented: Binding(
            get: { return true },
            set: { _ in }
        ),
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        workoutId: "EC44C268-3D9F-4D11-BEA0-FCFD2745B354"
    )
}
