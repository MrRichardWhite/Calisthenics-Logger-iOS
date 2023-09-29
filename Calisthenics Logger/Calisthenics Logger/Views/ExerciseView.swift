//
//  ExerciseView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 28.09.23.
//

import FirebaseFirestoreSwift
import SwiftUI

struct ExerciseView: View {
    @StateObject var viewModel: ExerciseViewViewModel
    @FirestoreQuery var metadata: [MetaDate]
    
    private let userId: String
    private let workoutId: String
    private let exerciseId: String

    init(userId: String, workoutId: String, exerciseId: String) {
        self.userId = userId
        self.workoutId = workoutId
        self.exerciseId = exerciseId
        self._metadata = FirestoreQuery(
            collectionPath: "users/\(userId)/workouts/\(workoutId)/exercises/\(exerciseId)/metadata"
        )
        self._viewModel = StateObject(
            wrappedValue: ExerciseViewViewModel(
                userId: userId,
                workoutId: workoutId,
                exerciseId: exerciseId
            )
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List(metadata) { metadate in
                    NavigationLink(
                        destination: MetaDateView(
                            userId: userId,
                            workoutId: workoutId,
                            exerciseId: exerciseId,
                            metadateId: metadate.id
                        )
                    ) {
                        VStack(alignment: .leading) {
                            Text(metadate.name)
                        }
                    }
                    
                    .swipeActions {
                        Button {
                            // Delete
                            viewModel.delete(
                                metadateId: metadate.id
                            )
                        } label: {
                            Image(systemName: "trash")
                                .tint(Color.red)
                        }
                    }
                }
//                .listStyle(PlainListStyle())
            }
            .navigationTitle("Exercise")
            .toolbar {
                Button {
                    // Action
                    viewModel.showingNewMetaDateView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showingNewMetaDateView){
                NewMetaDateView(
                    newMetaDatePresented: $viewModel.showingNewMetaDateView,
                    workoutId: workoutId,
                    exerciseId: exerciseId
                )
            }
        }
    }
}

#Preview {
    ExerciseView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        workoutId: "EC44C268-3D9F-4D11-BEA0-FCFD2745B354",
        exerciseId: "007F5FDA-6573-4B55-847E-9E3E5D88B8E1"
    )
}
