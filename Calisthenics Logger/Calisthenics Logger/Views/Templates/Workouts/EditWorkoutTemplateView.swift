//
//  WorkoutTemplateComponentsView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestoreSwift
import SwiftUI

struct EditWorkoutTemplateView: View {
    @StateObject var viewModel: EditWorkoutTemplateViewViewModel
    @FirestoreQuery var exerciseTemplates: [ExerciseTemplate]
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    private let userId: String
    private let workoutTemplateId: String
    
    init(userId: String, workoutTemplateId: String) {
        self.userId = userId
        self.workoutTemplateId = workoutTemplateId
        self._exerciseTemplates = FirestoreQuery(
            collectionPath: "users/\(userId)/exerciseTemplates"
        )
        self._viewModel = StateObject(
            wrappedValue: EditWorkoutTemplateViewViewModel(
                userId: userId,
                workoutTemplateId: workoutTemplateId
            )
        )
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("name", text: $viewModel.name)
                
                NavigationLink(
                    destination: editWorkoutTemplateContentView
                ) {
                    Text("Exercises")
                }
                
                CLButton(title: "Save", background: .blue) {
                    if viewModel.canSave {
                        viewModel.save(
                            userId: userId
                        )
                    } else {
                        viewModel.showAlert = true
                    }
                    self.presentationMode.wrappedValue.dismiss()
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
    
    @ViewBuilder
    var editWorkoutTemplateContentView: some View {
        NavigationStack {
            List {
                ForEach(viewModel.exerciseTemplateIdsLocal, id: \.self) { exerciseTemplateId in
                    let text = viewModel.id2name(
                        exerciseTemplates: exerciseTemplates,
                        id: exerciseTemplateId
                    )
                    Text(text)
                }
                .onDelete { i in
                    viewModel.exerciseTemplateIdsLocal.remove(atOffsets: i)
                }
            }
            
            if viewModel.newExerciseTemplateIds(exerciseTemplates: exerciseTemplates).count > 0 {
                addWorkoutTemplateContentView
            }
        }
    }
    
    @ViewBuilder
    var addWorkoutTemplateContentView: some View {
        Form {
            Picker("New Exercise", selection: $viewModel.newExerciseTemplateId) {
                ForEach(viewModel.newExerciseTemplateIds(exerciseTemplates: exerciseTemplates), id: \.self) { exerciseTemplateId in
                    let text = viewModel.id2name(
                        exerciseTemplates: exerciseTemplates,
                        id: exerciseTemplateId
                    )
                    Text(text)
                }
            }
            
            CLButton(title: "Add", background: .green) {
                let newExerciseTemplateIds = viewModel.newExerciseTemplateIds(
                    exerciseTemplates: exerciseTemplates
                )
                guard newExerciseTemplateIds.count > 0 else {
                    return
                }
                if viewModel.newExerciseTemplateId == "" {
                    viewModel.newExerciseTemplateId = newExerciseTemplateIds[0]
                }
                viewModel.exerciseTemplateIdsLocal.append(
                    viewModel.newExerciseTemplateId
                )
            }
            .padding()
        }
    }
}


#Preview {
    EditWorkoutTemplateView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        workoutTemplateId: "KkKTJbKlzHqJLSKeSn2V"
    )
}
