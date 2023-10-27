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
    @FirestoreQuery var exerciseTemplatesQuery: [ExerciseTemplate]
    
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        self._exerciseTemplatesQuery = FirestoreQuery(
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
                            viewModel.delete(exerciseTemplateId: exerciseTemplate.id)
                        } label: {
                            Image(systemName: "trash")
                        }
                        .tint(.red)
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
                    userId: userId,
                    newExerciseTemplatePresented: $viewModel.showingNewExerciseTemplateView
                )
            }
        }
    }
    
    var exerciseTemplates: [ExerciseTemplate] {
        var exerciseTemplatesSorted: [ExerciseTemplate] = exerciseTemplatesQuery
        exerciseTemplatesSorted.sort { $0.name.withoutEmoji() < $1.name.withoutEmoji() }
        return exerciseTemplatesSorted
    }
}

#Preview {
    ExerciseTemplatesView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1"
    )
}
