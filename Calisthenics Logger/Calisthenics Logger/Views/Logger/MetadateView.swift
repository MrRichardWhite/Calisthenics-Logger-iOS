//
//  MetadateView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 28.09.23.
//

import FirebaseFirestoreSwift
import SwiftUI

struct MetadateView: View {
    @StateObject var viewModel: MetadateViewViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var reloadInWorkout: Bool
    @Binding var reloadInExercise: Bool

    private let userId: String
    private let workoutId: String
    private let exerciseId: String
    private let metadateId: String
    
    init(
        userId: String, workoutId: String, exerciseId: String, metadateId: String,
        reloadInWorkout: Binding<Bool>, reloadInExercise: Binding<Bool>
    ) {
        self.userId = userId
        self.workoutId = workoutId
        self.exerciseId = exerciseId
        self.metadateId = metadateId
        
        self._reloadInWorkout = reloadInWorkout
        self._reloadInExercise = reloadInExercise
        
        self._viewModel = StateObject(
            wrappedValue: MetadateViewViewModel(
                userId: userId,
                workoutId: workoutId,
                exerciseId: exerciseId,
                metadateId: metadateId
            )
        )
    }
    
    var body: some View {
        NavigationStack {
            Form {
                HStack {
                    TextField("Name", text: $viewModel.metadate.name)
                    Divider()
                    TextField("Unit", text: $viewModel.metadate.unit)
                }
                
                elementsListView
                    
                CLButton(title: "Save", background: viewModel.background) {
                    if viewModel.canSave && !viewModel.dataIsInit {
                        viewModel.save()
                        reloadInWorkout = true
                        reloadInExercise = true
                        self.presentationMode.wrappedValue.dismiss()
                    } else {
                        if !viewModel.canSave {
                            viewModel.alertTitle = "Error"
                            viewModel.alertMessage = "Please fill in the name field!"
                        }
                        if viewModel.dataIsInit {
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
            .toolbar {
                Button {
                    viewModel.add()
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
    }
    
    @ViewBuilder
    var elementsListView: some View {
        List($viewModel.elements) { $element in
            TextField("Element", text: $element.content)
            .swipeActions {
                Button {
                    viewModel.delete(
                        elementId: element.id
                    )
                } label: {
                    Image(systemName: "trash")
                        .tint(Color.red)
                }
            }
        }
    }
}

#Preview {
    MetadateView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        workoutId: "07FCE443-3617-422E-B396-E34F05421D3E",
        exerciseId: "0FE3F549-61A2-41CF-9C25-80AB0E20C78B",
        metadateId: "22225346-DA6B-491F-97C0-59AE5A7C4E2F",
        reloadInWorkout: Binding(
            get: { return true },
            set: { _ in }
        ),
        reloadInExercise: Binding(
            get: { return true },
            set: { _ in }
        )
    )
}
