//
//  ExerciseTemplatesView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestoreSwift
import SwiftUI

struct ExerciseTemplatesView: View {
    @StateObject var viewModel: ExerciseTemplatesViewViewModel
    @FirestoreQuery var exerciseTemplates: [ExerciseTemplate]
    
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        self._exerciseTemplates = FirestoreQuery(
            collectionPath: "users/\(userId)/exerciseTemplates"
        )
        self._viewModel = StateObject(
            wrappedValue: ExerciseTemplatesViewViewModel(userId: userId)
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List(exerciseTemplates) { exerciseTemplate in
                    NavigationLink(
                        destination: EditExerciseTemplateView(
                            userId: userId,
                            exerciseTemplateId: exerciseTemplate.id
                        )
                    ) {
                        Text(exerciseTemplate.name)
                    }
                    .swipeActions {
                        Button {
                            // Delete
                            viewModel.delete(exerciseTemplateId: exerciseTemplate.id)
                        } label: {
                            Image(systemName: "trash")
                                .tint(Color.red)
                        }
                    }
                }
            }
            .toolbar {
                Button {
                    // Action
                    viewModel.showingNewExerciseTemplateView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showingNewExerciseTemplateView){
                NewExerciseTemplateView(
                    newExerciseTemplatePresented: $viewModel.showingNewExerciseTemplateView,
                    userId: userId
                )
            }
        }
    }
}

#Preview {
    ExerciseTemplatesView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1"
    )
}
