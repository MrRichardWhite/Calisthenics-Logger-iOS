//
//  LoggerView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import FirebaseFirestoreSwift
import SwiftUI

struct WorkoutsView: View {
    @StateObject var viewModel: LoggerViewViewModel
    @FirestoreQuery var workouts: [Workout]
    
    private let userId: String

    init(userId: String) {
        self.userId = userId
        self._workouts = FirestoreQuery(
            collectionPath: "users/\(userId)/workouts"
        )
        self._viewModel = StateObject(
            wrappedValue: LoggerViewViewModel(userId: userId)
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List(workouts) { workout in
                    NavigationLink(
                        destination: WorkoutView(
                            userId: userId,
                            workoutId: workout.id
                        )
                    ) {
                        VStack(alignment: .leading) {
                            Text(workout.location)

                            Text("\(Date(timeIntervalSince1970: workout.time).formatted(date: .abbreviated, time: .shortened))")
                                .font(.footnote)
                                .foregroundColor(Color(.secondaryLabel))
                        }
                    }
                    
                    .swipeActions {
                        Button {
                            // Delete
                            viewModel.delete(workoutId: workout.id)
                        } label: {
                            Image(systemName: "trash")
                                .tint(Color.red)
                        }
                    }
                }
//                .listStyle(PlainListStyle())
            }
            .navigationTitle("Logger")
            .toolbar {
                Button {
                    // Action
                    viewModel.showingNewWorkoutView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showingNewWorkoutView){
                NewWorkoutView(newWorkoutPresented: $viewModel.showingNewWorkoutView)
            }
        }
    }
}

#Preview {
    WorkoutsView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1"
    )
}
