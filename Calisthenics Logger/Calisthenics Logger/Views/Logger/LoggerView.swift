//
//  LoggerView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import FirebaseFirestoreSwift
import SwiftUI

struct LoggerView: View {
    @StateObject var viewModel: LoggerViewViewModel
    @FirestoreQuery var workouts: [Workout]
    
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        self._workouts = FirestoreQuery(
            collectionPath: "users/\(userId)/workouts"
        )
        self._viewModel = StateObject(
            wrappedValue: LoggerViewViewModel(
                userId: userId
            )
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
                            Text(workout.name)
                            let date = Date(
                                timeIntervalSince1970: workout.time
                            )
                                .formatted(date: .abbreviated, time: .shortened)
                            Text("\(date)")
                                .font(.footnote)
                                .foregroundColor(Color(.secondaryLabel))

                            Text("\(workout.location)")
                                .font(.footnote)
                                .foregroundColor(Color(.secondaryLabel))

                        }
                    }
                    
                    .swipeActions {
                        Button {
                            viewModel.delete(workoutId: workout.id)
                        } label: {
                            Image(systemName: "trash")
                                .tint(Color.red)
                        }
                    }
                }
            }
            .navigationTitle("Logger")
            .toolbar {
                Button {
                    viewModel.showingNewWorkoutView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showingNewWorkoutView){
                NewWorkoutView(
                    userId: userId,
                    newWorkoutPresented: $viewModel.showingNewWorkoutView
                )
            }
        }
    }
}

#Preview {
    LoggerView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1"
    )
}
