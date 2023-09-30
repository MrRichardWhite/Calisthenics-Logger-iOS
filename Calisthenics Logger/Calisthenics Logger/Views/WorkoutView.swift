//
//  WorkoutView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 28.09.23.
//

import FirebaseFirestoreSwift
import SwiftUI

struct WorkoutView: View {
    @StateObject var viewModel: WorkoutViewViewModel
    @FirestoreQuery var exercises: [Exercise]
    
    private let userId: String
    private let workoutId: String

    init(userId: String, workoutId: String) {
        self.userId = userId
        self.workoutId = workoutId
        self._exercises = FirestoreQuery(
            collectionPath: "users/\(userId)/workouts/\(workoutId)/exercises"
        )
        self._viewModel = StateObject(
            wrappedValue: WorkoutViewViewModel(
                userId: userId,
                workoutId: workoutId
            )
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List(exercises) { exercise in
                    NavigationLink(
                        destination: ExerciseView(
                            userId: userId,
                            workoutId: workoutId,
                            exerciseId: exercise.id
                        )
                    ) {
                        VStack(alignment: .leading) {
                            Text(exercise.name)
                        }
                    }
                    
                    .swipeActions {
                        Button {
                            // Delete
                            viewModel.delete(
                                exerciseId: exercise.id
                            )
                        } label: {
                            Image(systemName: "trash")
                                .tint(Color.red)
                        }
                    }
                }
//                .listStyle(PlainListStyle())
            }
            .navigationTitle("Workout")
            .toolbar {
                Button {
                    // Action
                    viewModel.showingNewExerciseView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showingNewExerciseView){
                NewExerciseView(
                    newExercisePresented: $viewModel.showingNewExerciseView,
                    userId: userId,
                    workoutId: workoutId
                )
            }
        }
    }
}

#Preview {
    WorkoutView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        workoutId: "EC44C268-3D9F-4D11-BEA0-FCFD2745B354"
    )
}
