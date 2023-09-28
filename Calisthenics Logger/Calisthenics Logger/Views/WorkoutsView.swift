//
//  WorkoutsView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import FirebaseFirestoreSwift
import SwiftUI

struct WorkoutsView: View {
    @StateObject var viewModel: WorkoutsViewViewModel
    @FirestoreQuery var workouts: [Workout]
    
    private let userId: String

    init(userId: String) {
        self.userId = userId
        self._workouts = FirestoreQuery(
            collectionPath: "users/\(userId)/workouts"
        )
        self._viewModel = StateObject(
            wrappedValue: WorkoutsViewViewModel(userId: userId)
        )
    }
    
    var body: some View {
        NavigationView {
            VStack {
                List(workouts) { workout in
                    VStack(alignment: .leading) {
                        Text(workout.location)

                        Text("\(Date(timeIntervalSince1970: workout.time).formatted(date: .abbreviated, time: .shortened))")
                            .font(.footnote)
                            .foregroundColor(Color(.secondaryLabel))
                    }
                    .swipeActions {
                        Button {
                            // Delete
                            viewModel.delete(id: workout.id)
                        } label: {
                            Image(systemName: "trash")
                                .tint(Color.red)
                        }
                    }
                }
//                .listStyle(PlainListStyle())
            }
            .navigationTitle("Workouts")
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
    WorkoutsView(userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1")
}
