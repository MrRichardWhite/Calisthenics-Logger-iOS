//
//  NewWorkoutViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class NewWorkoutViewViewModel: ObservableObject {
    @Published var time = Date()
    @Published var location = ""
    @Published var template = ""
    @Published var showAlert = false
    
    init() {}
    
    func save(userId: String) {
        guard canSave else {
            return
        }
        
//        // Get current user id
//        guard let uId = Auth.auth().currentUser?.uid else {
//            return
//        }
        
        // Create model
        let newWorkoutId = UUID().uuidString
        let newWorkout = Workout(
            id: newWorkoutId,
            time: time.timeIntervalSince1970,
            location: location,
            created: Date().timeIntervalSince1970
        )
        
        // Save model
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userId)
            .collection("workouts")
            .document(newWorkoutId)
            .setData(newWorkout.asDictionary())
    }
    
    var canSave: Bool {
        guard !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        return true
    }
}
