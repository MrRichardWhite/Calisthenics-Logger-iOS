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

    private let userId: String
    private let workoutId: String
    private let exerciseId: String
    private let metadateId: String
    
    init(userId: String, workoutId: String, exerciseId: String, metadateId: String) {
        self.userId = userId
        self.workoutId = workoutId
        self.exerciseId = exerciseId
        self.metadateId = metadateId
        
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
                    TextField("Name", text: $viewModel.name)
                    Divider()
                    TextField("Unit", text: $viewModel.unit)
                }
                
                elementsListView
                    
                CLButton(title: "Save", background: viewModel.background) {
                    if viewModel.canSave && !viewModel.dataIsInit {
                        viewModel.save()
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
        workoutId: "EC44C268-3D9F-4D11-BEA0-FCFD2745B354",
        exerciseId: "175BC775-8F64-4306-86FD-00569ACC2BFC",
        metadateId: "31DD6686-C338-4294-88B5-3E0644454529"
    )
}
