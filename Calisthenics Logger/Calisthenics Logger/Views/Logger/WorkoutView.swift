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
            exerciseListView
            .navigationTitle("Workout")
            .toolbar {
                HStack {
                    Button {
                        viewModel.loadExercises()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    
                    Button {
                        viewModel.showingEditWorkoutView = true
                    } label: {
                        Image(systemName: "pencil")
                    }
                    
                    Button {
                        viewModel.showingNewExerciseView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingNewExerciseView){
                NewExerciseView(
                    userId: userId,
                    workoutId: workoutId,
                    newExercisePresented: $viewModel.showingNewExerciseView
                )
            }
            .sheet(isPresented: $viewModel.showingEditWorkoutView){
                EditWorkoutView(
                    userId: userId,
                    workoutId: workoutId,
                    editWorkoutPresented: $viewModel.showingEditWorkoutView
                )
            }
        }
        .onChange(of: viewModel.showingNewExerciseView) {
            viewModel.loadExercises()
        }
    }
    
    @ViewBuilder
    var exerciseListView: some View {
        VStack {
            let dk = viewModel.group(exercises: exercises)
            let dict = dk.dict
            let keys = dk.keys
            
            Form {
                ForEach(keys, id: \.self) { category in
                    
                    let exercises = dict[category] ?? []
                    
                    Section(
                        header: Text(category)
                            .font(.title2)
                            .padding()
                    ) {
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
                                        .padding(.bottom, 5)
                                    
                                    ForEach(viewModel.metadata[exercise.id] ?? []) { metadate in
                                        HStack {
                                            Text(metadate.name)
                                                .font(.footnote)
                                                .foregroundColor(Color(.secondaryLabel))
                                            
                                            Spacer()
                                            
                                            let contents = viewModel.elements[exercise.id]?[metadate.id, default: []].map { $0.content }
                                            let text = String(
                                                (contents?.joined(separator: ", "))!
                                            )
                                            if !(
                                                text.contains(",") &&
                                                text.contains(" ") &&
                                                Set(text).count == 2
                                            ) {
                                                Text(text)
                                                    .font(.footnote)
                                                    .foregroundColor(Color(.secondaryLabel))
                                            }
                                        }
                                    }
                                }
                            }
                            .swipeActions {
                                Button {
                                    viewModel.delete(
                                        exerciseId: exercise.id
                                    )
                                    viewModel.loadExercises()
                                } label: {
                                    Image(systemName: "trash")
                                        .tint(Color.red)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    WorkoutView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        workoutId: "07FCE443-3617-422E-B396-E34F05421D3E"
    )
}
