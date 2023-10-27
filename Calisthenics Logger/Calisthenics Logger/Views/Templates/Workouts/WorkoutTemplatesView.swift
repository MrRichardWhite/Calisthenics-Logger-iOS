//
//  WorkoutTemplatesView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestoreSwift
import SwiftUI

struct WorkoutTemplatesView: View {
    @StateObject var viewModel: WorkoutTemplatesViewViewModel
    @FirestoreQuery var workoutTemplatesQuery: [WorkoutTemplate]
    
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        self._workoutTemplatesQuery = FirestoreQuery(
            collectionPath: "users/\(userId)/workoutTemplates"
        )
        self._viewModel = StateObject(
            wrappedValue: WorkoutTemplatesViewViewModel(userId: userId)
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List(workoutTemplates) { workoutTemplate in
                    NavigationLink(
                        destination: EditWorkoutTemplateView(
                            userId: userId,
                            workoutTemplateId: workoutTemplate.id
                        )
                    ) {
                        Text(workoutTemplate.name)
                    }
                    
                    .swipeActions {
                        Button {
                            viewModel.delete(workoutTemplateId: workoutTemplate.id)
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
                    viewModel.showingNewWorkoutTemplateView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showingNewWorkoutTemplateView){
                NewWorkoutTemplateView(
                    userId: userId,
                    newWorkoutTemplatePresented: $viewModel.showingNewWorkoutTemplateView
                )
            }
        }
    }
    
    var workoutTemplates: [WorkoutTemplate] {
        var workoutTemplatesSorted: [WorkoutTemplate] = workoutTemplatesQuery
        workoutTemplatesSorted.sort { $0.name.withoutEmoji() < $1.name.withoutEmoji() }
        return workoutTemplatesSorted
    }
}

#Preview {
    WorkoutTemplatesView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1"
    )
}
