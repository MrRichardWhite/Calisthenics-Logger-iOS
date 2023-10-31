//
//  NewExerciseView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 29.09.23.
//

import SwiftUI

struct NewExerciseView: View {
    @StateObject var viewModel: NewExerciseViewViewModel
    @Binding var newExercisePresented: Bool
    @Binding var reloadInWorkout: Bool
    
    let userId: String
    let workoutId: String
    
    init(
        userId: String, workoutId: String,
        newExercisePresented: Binding<Bool>,
        reloadInWorkout: Binding<Bool>
    ) {
        self.userId = userId
        self.workoutId = workoutId
        
        self._newExercisePresented = newExercisePresented
        self._reloadInWorkout = reloadInWorkout
        
        self._viewModel = StateObject(
            wrappedValue: NewExerciseViewViewModel(
                userId: userId,
                workoutId: workoutId
            )
        )
    }

    var body: some View {
        VStack {
            Text("New Exercise")
                .font(.system(size: 32))
                .bold()
                .padding(.top)
            
            Form {
                Picker("Template", selection: $viewModel.pickedExerciseTemplateId) {
                    ForEach(viewModel.exerciseTemplateIds, id: \.self) { exerciseTemplateId in
                        let text = viewModel.id2name(
                            id: exerciseTemplateId
                        )
                        Text(text)
                    }
                }
                
                CLButton(title: "Add", background: .green) {
                    viewModel.save(
                        userId: userId,
                        workoutId: workoutId
                    )
                    reloadInWorkout = true
                    newExercisePresented = false
                }
                .padding()
            }
        }
    }
}

#Preview {
    NewExerciseView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        workoutId: "EC44C268-3D9F-4D11-BEA0-FCFD2745B354",
        newExercisePresented: Binding(
            get: { return true },
            set: { _ in }
        ),
        reloadInWorkout: Binding(
            get: { return true },
            set: { _ in }
        )
    )
}
