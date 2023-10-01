//
//  WorkoutViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 29.09.23.
//

import FirebaseFirestore
import Foundation

class WorkoutViewViewModel: ObservableObject {
    @Published var showingNewExerciseView = false
    
    private let userId: String
    private let workoutId: String
    
    init(userId: String, workoutId: String) {
        self.userId = userId
        self.workoutId = workoutId
    }
    
    func delete(exerciseId: String) {
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userId)
            .collection("workouts")
            .document(workoutId)
            .collection("exercises")
            .document(exerciseId)
            .delete()
    }
}
