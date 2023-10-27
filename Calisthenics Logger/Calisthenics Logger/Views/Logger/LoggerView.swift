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
                let dk = viewModel.group(workouts: workouts)
                let dict = dk.dict
                let keys = dk.keys
                Form {
                    ForEach(keys, id: \.self) { date in
                        let month = DateFormatter().monthSymbols[(date.month ?? 0) - 1]
                        let year = String(date.year ?? 0)
                        
                        let workouts = dict[date] ?? []
                        
                        Section(
                            header: Text("\(month) - \(year)")
                                .font(.title2)
                                .padding()
                        ) {
                            List(workouts) { workout in
                                NavigationLink(
                                    destination: WorkoutView(
                                        userId: userId,
                                        workoutId: workout.id
                                    )
                                ) {
                                    VStack(alignment: .leading) {
                                        Text(workout.name)
                                            .bold()
                                        
                                        let date = Date(timeIntervalSince1970: workout.time)
                                            .formatted(date: .abbreviated, time: .shortened)
                                        Text("\(date)")
                                            .foregroundColor(Color(.secondaryLabel))

                                        Text("\(workout.location)")
                                            .foregroundColor(Color(.secondaryLabel))

                                    }
                                }
                                
                                .swipeActions {
                                    Button {
                                        viewModel.delete(workoutId: workout.id)
                                    } label: {
                                        Image(systemName: "trash")
                                            .tint(.red)
                                    }
                                }
                            }
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
