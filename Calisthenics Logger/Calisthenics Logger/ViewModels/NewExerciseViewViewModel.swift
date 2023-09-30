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
        let newId = UUID().uuidString
        let newExercise = Exercise(
            id: newId,
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
            .document(newId)
            .setData(newExercise.asDictionary())
    }
}
