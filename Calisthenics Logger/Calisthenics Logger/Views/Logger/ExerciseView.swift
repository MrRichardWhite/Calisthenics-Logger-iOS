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
    @Binding var reloadInWorkout: Bool
    
    private let userId: String
    private let workoutId: String
    private let exerciseId: String

    init(userId: String, workoutId: String, exerciseId: String, reloadInWorkout: Binding<Bool>) {
        self.userId = userId
        self.workoutId = workoutId
        self.exerciseId = exerciseId
        
        self._reloadInWorkout = reloadInWorkout
        
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
                metadataListView
            }
            .navigationTitle("Exercise")
            .toolbar {
                Button {
                    viewModel.showingEditExerciseView = true
                } label: {
                    Image(systemName: "pencil")
                }

                Button {
                    viewModel.showingNewMetadateView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showingNewMetadateView){
                NewMetadateView(
                    userId: userId,
                    workoutId: workoutId,
                    exerciseId: exerciseId,
                    newMetadatePresented: $viewModel.showingNewMetadateView
                )
            }
            .sheet(isPresented: $viewModel.showingEditExerciseView){
                EditExerciseView(
                    userId: userId,
                    workoutId: workoutId,
                    exerciseId: exerciseId,
                    editExercisePresented: $viewModel.showingEditExerciseView
                )
            }
        }
        .onChange(
            of: viewModel.showingNewMetadateView,
            perform: { _ in
                viewModel.loadMetadata()
            }
        )
        .onChange(
            of: viewModel.reloadInExercise,
            perform: { _ in
                if viewModel.reloadInExercise {
                    viewModel.loadMetadata()
                    viewModel.reloadInExercise = false
                }
            }
        )
    }
    
    @ViewBuilder
    var metadataListView: some View {
        List(viewModel.metadata) { metadate in
            NavigationLink(
                destination: MetadateView(
                    userId: userId,
                    workoutId: workoutId,
                    exerciseId: exerciseId,
                    metadateId: metadate.id,
                    reloadInWorkout: $reloadInWorkout,
                    reloadInExercise: $viewModel.reloadInExercise
                )
            ) {
                VStack(alignment: .leading) {
                    Text(metadate.name)
                        .padding(.bottom, 5)
                    
                    let contents = viewModel.elements[metadate.id, default: []].map {
                        $0.content != "" ? $0.content : "..."
                    }
                    let text = String(
                        contents.joined(separator: " | ")
                    )
                    if !(
                        text.contains("|") &&
                        text.contains(" ") &&
                        text.contains(".") &&
                        Set(text).count == 3
                    ) {
                        Text(text)
                            .font(.footnote)
                            .foregroundColor(Color(.secondaryLabel))
                    }
                }
            }
            .swipeActions {
                Button {
                    viewModel.delete(
                        metadateId: metadate.id
                    )
                    viewModel.loadMetadata()
                } label: {
                    Image(systemName: "trash")
                        .tint(Color.red)
                }
            }
        }
    }
}

#Preview {
    ExerciseView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        workoutId: "07FCE443-3617-422E-B396-E34F05421D3E",
        exerciseId: "0FE3F549-61A2-41CF-9C25-80AB0E20C78B",
        reloadInWorkout: Binding(
            get: { return true },
            set: { _ in }
        )
    )
}
