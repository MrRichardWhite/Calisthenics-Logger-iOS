//
//  ExerciseViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 28.09.23.
//

import FirebaseFirestore
import Foundation

class ExerciseViewViewModel: ObservableObject {
    @Published var showingNewMetadateView = false
    
    private let userId: String
    private let workoutId: String
    private let exerciseId: String
    
    init(userId: String, workoutId: String, exerciseId: String) {
        self.userId = userId
        self.workoutId = workoutId
        self.exerciseId = exerciseId
    }
    
    func delete(metadateId: String) {
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userId)
            .collection("workouts")
            .document(workoutId)
            .collection("exercises")
            .document(exerciseId)
            .collection("metadata")
            .document(metadateId)
            .delete()
    }
}
