//
//  NewExerciseViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 29.09.23.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class NewExerciseViewViewModel: ObservableObject {
    @Published var template = ""
    
    init() {}
    
    func save(userId: String, workoutId: String) {
        // Create model
        let newExerciseId = UUID().uuidString
        let newExercise = Exercise(
            id: newExerciseId,
            name: template,
            created: Date().timeIntervalSince1970
        )
        
        // Save model
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userId)
            .collection("workouts")
            .document(workoutId)
            .collection("exercises")
            .document(newExerciseId)
            .setData(newExercise.asDictionary())
    }
}
