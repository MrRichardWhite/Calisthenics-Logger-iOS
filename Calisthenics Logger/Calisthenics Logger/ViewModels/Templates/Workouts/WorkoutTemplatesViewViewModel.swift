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
    
    private let userRef: DocumentReference
    
    init(userId: String) {
        self.userId = userId
        
        self.userRef = Firestore.firestore()
            .collection("users")
            .document(userId)
    }
    
    func delete(workoutTemplateId: String) {
        let workoutTemplateRef = userRef
            .collection("workoutTemplates")
            .document(workoutTemplateId)
        
        workoutTemplateRef.delete()
    }
}
