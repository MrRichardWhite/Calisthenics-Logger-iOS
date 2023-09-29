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
                CLButton(title: "Save", background: .pink) {
                    viewModel.save(workoutId: workoutId)
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
            get: {
                return true
            },
            set: {_ in
        
            }
        ),
        workoutId: "EC44C268-3D9F-4D11-BEA0-FCFD2745B354"
    )
}
