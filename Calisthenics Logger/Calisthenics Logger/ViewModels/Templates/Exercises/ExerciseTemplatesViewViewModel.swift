//
//  ExerciseTemplatesViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestore
import Foundation

class ExerciseTemplatesViewViewModel: ObservableObject {
    @Published var showingNewExerciseTemplateView = false
    
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    func delete(exerciseTemplateId: String) {
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userId)
            .collection("exerciseTemplates")
            .document(exerciseTemplateId)
            .delete()
    }
}
