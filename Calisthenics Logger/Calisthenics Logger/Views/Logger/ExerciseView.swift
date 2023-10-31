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

    init(
        userId: String, workoutId: String, exerciseId: String,
        reloadInWorkout: Binding<Bool>
    ) {
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
                    newMetadatePresented: $viewModel.showingNewMetadateView,
                    reloadInWorkout: $reloadInWorkout,
                    reloadInExercise: $viewModel.reloadInExercise
                )
            }
            .sheet(isPresented: $viewModel.showingEditExerciseView){
                EditExerciseView(
                    userId: userId,
                    workoutId: workoutId,
                    exerciseId: exerciseId,
                    editExercisePresented: $viewModel.showingEditExerciseView,
                    reloadInWorkout: $reloadInWorkout
                )
            }
        }
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
                    if showText(text: text) {
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
                    reloadInWorkout = true
                } label: {
                    Image(systemName: "trash")
                }
                .tint(.red)
            }
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
    ExerciseView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        workoutId: "BF86C030-9675-44ED-8C84-E1FC61C93C90",
        exerciseId: "CEA0A767-B355-4F31-9AE4-D3919ABDFAB1",
        reloadInWorkout: Binding(
            get: { return true },
            set: { _ in }
        )
    )
}
