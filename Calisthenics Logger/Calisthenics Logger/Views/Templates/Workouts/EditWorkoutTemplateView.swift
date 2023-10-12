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
    @FirestoreQuery var exerciseTemplatesQuery: [ExerciseTemplate]
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    private let userId: String
    private let workoutTemplateId: String
    
    init(userId: String, workoutTemplateId: String) {
        self.userId = userId
        self.workoutTemplateId = workoutTemplateId
        self._exerciseTemplatesQuery = FirestoreQuery(
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
                TextField("Name", text: $viewModel.name)
                
                NavigationLink(
                    destination: editWorkoutTemplateContentView
                ) {
                    Text("Exercises")
                }
                
                CLButton(title: "Save", background: viewModel.background) {
                    if viewModel.canSave && !viewModel.dataIsInit {
                        viewModel.save(
                            userId: userId
                        )
                        self.presentationMode.wrappedValue.dismiss()
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
            Picker("Exercise", selection: $viewModel.newExerciseTemplateId) {
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
    
    var exerciseTemplates: [ExerciseTemplate] {
        var exerciseTemplatesSorted: [ExerciseTemplate] = exerciseTemplatesQuery
        exerciseTemplatesSorted.sort { $0.name.withoutEmoji() < $1.name.withoutEmoji() }
        return exerciseTemplatesSorted
    }
}


#Preview {
    EditWorkoutTemplateView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        workoutTemplateId: "F5D8494D-8C96-484B-99D9-2A4AE6569B2A"
    )
}
