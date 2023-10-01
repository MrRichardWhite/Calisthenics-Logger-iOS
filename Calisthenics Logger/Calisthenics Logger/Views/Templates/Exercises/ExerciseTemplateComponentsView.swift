//
//  ExerciseTemplateComponentsView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestoreSwift
import SwiftUI

struct ExerciseTemplateComponentsView: View {
    @StateObject var viewModel: ExerciseTemplateComponentsViewViewModel
    
    private let userId: String
    private let exerciseTemplateId: String

    init(userId: String, exerciseTemplateId: String) {
        self.userId = userId
        self.exerciseTemplateId = exerciseTemplateId
        self._viewModel = StateObject(
            wrappedValue: ExerciseTemplateComponentsViewViewModel(
                userId: userId,
                exerciseTemplateId: exerciseTemplateId
            )
        )
    }
    
    var body: some View {
        Text("Hello World!")
    }
}

#Preview {
    ExerciseTemplateComponentsView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        exerciseTemplateId: "8741A6C4-87EC-48C8-9469-697532EE0C7A"
    )
}
