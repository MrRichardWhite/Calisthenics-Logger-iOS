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
    @FirestoreQuery var metadateTemplatesQuery: [MetadateTemplate]
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    private let userId: String
    private let exerciseTemplateId: String
    
    init(userId: String, exerciseTemplateId: String) {
        self.userId = userId
        self.exerciseTemplateId = exerciseTemplateId
        self._metadateTemplatesQuery = FirestoreQuery(
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
                TextField("Name", text: $viewModel.name)
                
                TextField("Category", text: $viewModel.category)
                
                NavigationLink(
                    destination: editExerciseTemplateContentView
                ) {
                    Text("Metadata")
                }
                
                CLButton(title: "Save", background: viewModel.background) {
                    if viewModel.canSave && !viewModel.dataIsInit {
                        viewModel.save(
                            userId: userId
                        )
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
            Picker("Metadate", selection: $viewModel.newMetadateTemplateId) {
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
    
    var metadateTemplates: [MetadateTemplate] {
        var metadateTemplatesSorted: [MetadateTemplate] = metadateTemplatesQuery
        metadateTemplatesSorted.sort { $0.name.withoutEmoji() < $1.name.withoutEmoji() }
        return metadateTemplatesSorted
    }
}

#Preview {
    EditExerciseTemplateView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        exerciseTemplateId: "8741A6C4-87EC-48C8-9469-697532EE0C7A"
    )
}
