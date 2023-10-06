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
    @FirestoreQuery var workoutTemplates: [WorkoutTemplate]
    
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        self._workoutTemplates = FirestoreQuery(
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
                                .tint(Color.red)
                        }
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
}

#Preview {
    WorkoutTemplatesView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1"
    )
}
