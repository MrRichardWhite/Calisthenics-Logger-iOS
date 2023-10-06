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
    
    private let userRef: DocumentReference

    init(userId: String) {
        self.userId = userId
        
        self.userRef = Firestore.firestore()
            .collection("users")
            .document(userId)
    }
    
    func delete(exerciseTemplateId: String) {
        let exerciseTemplateRef = userRef
            .collection("exerciseTemplates")
            .document(exerciseTemplateId)
        
        exerciseTemplateRef.delete()
    }
}
