//
//  MetaDateView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 28.09.23.
//

import FirebaseFirestoreSwift
import SwiftUI

struct MetaDateView: View {
    @StateObject var viewModel: MetaDateViewViewModel
    @FirestoreQuery var elements: [Element]
    
    private let userId: String
    private let workoutId: String
    private let exerciseId: String
    private let metadateId: String
    
    init(userId: String, workoutId: String, exerciseId: String, metadateId: String) {
        self.userId = userId
        self.workoutId = workoutId
        self.exerciseId = exerciseId
        self.metadateId = metadateId
        self._elements = FirestoreQuery(
            collectionPath: "users/\(userId)/workouts/\(workoutId)/exercises/\(exerciseId)/metadata/\(metadateId)/elements"
        )
        self._viewModel = StateObject(
            wrappedValue: MetaDateViewViewModel(
                userId: userId,
                workoutId: workoutId,
                exerciseId: exerciseId,
                metadateId: metadateId
            )
        )
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    MetaDateView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        workoutId: "EC44C268-3D9F-4D11-BEA0-FCFD2745B354",
        exerciseId: "007F5FDA-6573-4B55-847E-9E3E5D88B8E1",
        metadateId: "7D42442B-63CE-4918-8D42-3D54F9CF2CC7"
    )
}
