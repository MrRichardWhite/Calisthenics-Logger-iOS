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
    
    private let userId: String
    private let workoutId: String
    private let exerciseId: String

    init(userId: String, workoutId: String, exerciseId: String) {
        self.userId = userId
        self.workoutId = workoutId
        self.exerciseId = exerciseId
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
                    viewModel.load_metadata()
                } label: {
                    Image(systemName: "arrow.clockwise")
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
        }
        .onChange(of: viewModel.showingNewMetadateView) {
            viewModel.load_metadata()
        }
    }
    
    @ViewBuilder
    var metadataListView: some View {
        List(viewModel.metadata) { metadate in
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
                        .padding(.bottom, 5)
                    
                    let contents = viewModel.elements[metadate.id, default: []].map { $0.content }
                    Text(contents.joined(separator: ", "))
                        .font(.footnote)
                        .foregroundColor(Color(.secondaryLabel))
                }
            }
            .swipeActions {
                Button {
                    viewModel.delete(
                        metadateId: metadate.id
                    )
                    viewModel.load_metadata()
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
        workoutId: "07FCE443-3617-422E-B396-E34F05421D3E",
        exerciseId: "0FE3F549-61A2-41CF-9C25-80AB0E20C78B"
    )
}
