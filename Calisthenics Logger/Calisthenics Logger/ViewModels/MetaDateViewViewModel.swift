//
//  MetaDateViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 28.09.23.
//

import FirebaseFirestore
import Foundation

class MetaDateViewViewModel: ObservableObject {
    @Published var showingNewMetaDateView = false
    
    private let userId: String
    private let workoutId: String
    private let exerciseId: String
    private let metadateId: String
    
    init(userId: String, workoutId: String, exerciseId: String, metadateId: String) {
        self.userId = userId
        self.workoutId = workoutId
        self.exerciseId = exerciseId
        self.metadateId = metadateId
    }
    
    func delete(elementId: String) {
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userId)
            .collection("workouts")
            .document(workoutId)
            .collection("exercises")
            .document(exerciseId)
            .collection("metadata")
            .document(metadateId)
            .collection("elements")
            .document(elementId)
            .delete()
    }
}
