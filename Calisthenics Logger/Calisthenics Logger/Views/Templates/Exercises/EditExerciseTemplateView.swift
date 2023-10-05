//
//  ExerciseTemplateComponentsView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestoreSwift
import SwiftUI

struct EditExerciseTemplateView: View {
    @StateObject var viewModel: EditExerciseTemplateViewViewModel
    @FirestoreQuery var metadateTemplates: [MetadateTemplate]
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    private let userId: String
    private let exerciseTemplateId: String
    
    init(userId: String, exerciseTemplateId: String) {
        self.userId = userId
        self.exerciseTemplateId = exerciseTemplateId
        self._metadateTemplates = FirestoreQuery(
            collectionPath: "users/\(userId)/metadateTemplates"
        )
        self._viewModel = StateObject(
            wrappedValue: EditExerciseTemplateViewViewModel(
                userId: userId,
                exerciseTemplateId: exerciseTemplateId
            )
        )
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("name", text: $viewModel.name)
                
                NavigationLink(
                    destination: editExerciseTemplateContentView
                ) {
                    Text("Metadata")
                }
                
                CLButton(title: "Save", background: .blue) {
                    if viewModel.canSave {
                        viewModel.save(
                            userId: userId
                        )
                        self.presentationMode.wrappedValue.dismiss()
                    } else {
                        viewModel.showAlert = true
                    }
                }
                .padding()
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text("Please fill in the name field!")
                )
            }
        }
    }
    
    @ViewBuilder
    var editExerciseTemplateContentView: some View {
        NavigationStack {
            List {
                ForEach(viewModel.metadateTemplateIdsLocal, id: \.self) { metadateTemplateId in
                    let text = viewModel.id2name(
                        metadateTemplates: metadateTemplates,
                        id: metadateTemplateId
                    )
                    Text(text)
                }
                .onDelete { i in
                    viewModel.metadateTemplateIdsLocal.remove(atOffsets: i)
                }
            }
            
            if viewModel.newMetadateTemplateIds(metadateTemplates: metadateTemplates).count > 0 {
                addExerciseTemplateContentView
            }
        }
    }
    
    @ViewBuilder
    var addExerciseTemplateContentView: some View {
        Form {
            Picker("New Metadate", selection: $viewModel.newMetadateTemplateId) {
                ForEach(viewModel.newMetadateTemplateIds(metadateTemplates: metadateTemplates), id: \.self) { metadateTemplateId in
                    let text = viewModel.id2name(
                        metadateTemplates: metadateTemplates,
                        id: metadateTemplateId
                    )
                    Text(text)
                }
            }
            
            CLButton(title: "Add", background: .green) {
                let newMetadateTemplateIds = viewModel.newMetadateTemplateIds(
                    metadateTemplates: metadateTemplates
                )
                guard newMetadateTemplateIds.count > 0 else {
                    return
                }
                if viewModel.newMetadateTemplateId == "" || viewModel.metadateTemplateIdsLocal.contains(viewModel.newMetadateTemplateId) {
                    viewModel.newMetadateTemplateId = newMetadateTemplateIds[0]
                }
                viewModel.metadateTemplateIdsLocal.append(
                    viewModel.newMetadateTemplateId
                )
            }
            .padding()
        }
    }
}

#Preview {
    EditExerciseTemplateView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        exerciseTemplateId: "8741A6C4-87EC-48C8-9469-697532EE0C7A"
    )
}
