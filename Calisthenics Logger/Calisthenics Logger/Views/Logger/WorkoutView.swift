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
    
    private let userId: String
    private let workoutId: String

    init(userId: String, workoutId: String) {
        self.userId = userId
        self.workoutId = workoutId
        
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
            .sheet(isPresented: $viewModel.showingNewExerciseView){
                NewExerciseView(
                    userId: userId,
                    workoutId: workoutId,
                    newExercisePresented: $viewModel.showingNewExerciseView,
                    reloadInWorkout: $viewModel.reloadInWorkout
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
        .onChange(
            of: viewModel.reloadInWorkout,
            perform: { _ in
                if viewModel.reloadInWorkout {
                    viewModel.load()
                    viewModel.reloadInWorkout = false
                }
            }
        )
    }
    
    @ViewBuilder
    var exerciseListView: some View {
        VStack {
            let dict = Dictionary(grouping: viewModel.exercises) { $0.category }
            let categories = dict.map { $0.key }.sorted()
            
            Form {
                ForEach(categories, id: \.self) { category in
                    
                    let exercises = dict[category] ?? []
                    
                    Section(
                        header: Text(category)
                            .font(.title2)
                            .padding()
                    ) {
                        List(exercises) { exercise in
                            exerciseElementView(exercise: exercise)
                        }
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    func exerciseElementView(exercise: Exercise) -> some View {
        NavigationLink(
            destination: ExerciseView(
                userId: userId,
                workoutId: workoutId,
                exerciseId: exercise.id,
                reloadInWorkout: $viewModel.reloadInWorkout
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
                        
                        let contents = viewModel.elements[exercise.id]?[metadate.id, default: []].map {
                            $0.content != "" ? $0.content : "..."
                        }
                        let text = String(
                            (contents?.joined(separator: " | "))!
                        )
                        if showText(text: text) {
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
            }
            .tint(.red)
        }
    }
    
    func showText(text: String) -> Bool {
        let emptySingle = text == "..."
        let emptyMulti = (
            text.contains("|") &&
            text.contains(" ") &&
            text.contains(".") &&
            Set(text).count == 3
        )
        let empty = emptySingle || emptyMulti
        let fits = text.count <= 32
        return !empty && fits
    }
}

#Preview {
    WorkoutView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        workoutId: "BF86C030-9675-44ED-8C84-E1FC61C93C90"
    )
}
