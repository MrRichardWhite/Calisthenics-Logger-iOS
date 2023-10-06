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
    @FirestoreQuery var metadata: [Metadate]
    
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
                metadataListView
                editExerciseView
            }
            .navigationTitle("Exercise")
            .toolbar {
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
        }
    }
    
    @ViewBuilder
    var metadataListView: some View {
        List(metadata) { metadate in
            NavigationLink(
                destination: MetadateView(
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
                    viewModel.delete(
                        metadateId: metadate.id
                    )
                } label: {
                    Image(systemName: "trash")
                        .tint(Color.red)
                }
            }
        }
    }
    
    @ViewBuilder
    var editExerciseView: some View {
        Form {
            TextField("Name", text: $viewModel.name)
            
            CLButton(title: "Save", background: viewModel.background) {
                if viewModel.canSave && !viewModel.dataIsInit {
                    viewModel.save(
                        userId: userId
                    )
                } else {
                    if !viewModel.canSave {
                        viewModel.alertTitle = "Error"
                        viewModel.alertMessage = "Please fill in the name field!"
                    }
                    if !viewModel.dataIsInit {
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
    ExerciseView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        workoutId: "EC44C268-3D9F-4D11-BEA0-FCFD2745B354",
        exerciseId: "175BC775-8F64-4306-86FD-00569ACC2BFC"
    )
}
