//
//  WorkoutsViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import FirebaseFirestore
import Foundation

class WorkoutsViewViewModel: ObservableObject {
    @Published var showingNewWorkoutView = false
    
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    /// Delete workout
    /// - Parameter id: Workout id to delete
    func delete(id: String) {
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userId)
            .collection("workouts")
            .document(id)
            .delete()
    }
}
