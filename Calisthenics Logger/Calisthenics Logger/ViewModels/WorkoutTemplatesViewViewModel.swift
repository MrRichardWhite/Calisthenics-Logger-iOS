//
//  WorkoutTemplatesViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestore
import Foundation

class WorkoutTemplatesViewViewModel: ObservableObject {
    @Published var showingNewWorkoutTemplateView = false
    
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    func delete(workoutTemplateId: String) {
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userId)
            .collection("workoutTemplates")
            .document(workoutTemplateId)
            .delete()
    }
}
