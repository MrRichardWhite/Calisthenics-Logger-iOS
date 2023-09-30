//
//  WorkoutTemplateComponentsView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestoreSwift
import SwiftUI

struct WorkoutTemplateComponentsView: View {
    @StateObject var viewModel: WorkoutTemplateComponentsViewViewModel
    
    private let userId: String
    private let workoutTemplateId: String

    init(userId: String, workoutTemplateId: String) {
        self.userId = userId
        self.workoutTemplateId = workoutTemplateId
        self._viewModel = StateObject(
            wrappedValue: WorkoutTemplateComponentsViewViewModel(
                userId: userId,
                workoutTemplateId: workoutTemplateId
            )
        )
    }
    
    var body: some View {
        Text("Hello World!")
    }
}

#Preview {
    WorkoutTemplateComponentsView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        workoutTemplateId: "KkKTJbKlzHqJLSKeSn2V"
    )
}
