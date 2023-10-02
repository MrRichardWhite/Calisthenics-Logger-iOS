//
//  NewExerciseTemplateViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class NewExerciseTemplateViewViewModel: ObservableObject {
    @Published var time = Date()
    @Published var name = ""
    @Published var showAlert = false
    
    init() {}
    
    func save(userId: String) {
        guard canSave else {
            return
        }
        
        // Create model
        let newExerciseTemplateId = UUID().uuidString
        let newExerciseTemplate = ExerciseTemplate(
            id: newExerciseTemplateId,
            name: name,
            metadateTemplateIds: [],
            created: Date().timeIntervalSince1970,
            edited: Date().timeIntervalSince1970
        )
        
        // Save model
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userId)
            .collection("exerciseTemplates")
            .document(newExerciseTemplateId)
            .setData(newExerciseTemplate.asDictionary())
    }
    
    var canSave: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        return true
    }
}
