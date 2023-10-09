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
                exerciseListView
                editWorkoutView
            }
            .navigationTitle("Workout")
            .toolbar {
                HStack {
                    Button {
                        viewModel.load_exercises()
                    } label: {
                        Image(systemName: "arrow.clockwise")
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
        }
        .onChange(of: viewModel.showingNewExerciseView) {
            viewModel.load_exercises()
        }
    }
    
    @ViewBuilder
    var exerciseListView: some View {
        List(viewModel.exercises) { exercise in
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
                            Text((contents?.joined(separator: ", "))!)
                                .font(.footnote)
                                .foregroundColor(Color(.secondaryLabel))
                        }
                    }
                }
            }
            .swipeActions {
                Button {
                    viewModel.delete(
                        exerciseId: exercise.id
                    )
                    viewModel.load_exercises()
                } label: {
                    Image(systemName: "trash")
                        .tint(Color.red)
                }
            }
        }
    }
    
    @ViewBuilder
    var editWorkoutView: some View {
        Form {
            TextField("Name", text: $viewModel.name)

            DatePicker("Time", selection: $viewModel.time)
                .padding(1)
            
            TextField("Location", text: $viewModel.location)
            
            CLButton(title: "Save", background: viewModel.background) {
                if viewModel.canSave && !viewModel.dataIsInit {
                    viewModel.save(
                        userId: userId
                    )
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
    WorkoutView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        workoutId: "07FCE443-3617-422E-B396-E34F05421D3E"
    )
}
