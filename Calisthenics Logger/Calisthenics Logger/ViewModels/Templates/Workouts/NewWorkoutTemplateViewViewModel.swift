//
//  NewWorkoutTemplateViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class NewWorkoutTemplateViewViewModel: ObservableObject {
    @Published var time = Date()
    @Published var name = ""
    @Published var showAlert = false
    
    init() {}
    
    func save(userId: String) {
        guard canSave else {
            return
        }
        
        // Create model
        let newWorkoutTemplateId = UUID().uuidString
        let newWorkoutTemplate = WorkoutTemplate(
            id: newWorkoutTemplateId,
            name: name,
            exerciseTemplateIds: [],
            created: Date().timeIntervalSince1970
        )
        
        // Save model
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userId)
            .collection("workoutTemplates")
            .document(newWorkoutTemplateId)
            .setData(newWorkoutTemplate.asDictionary())
    }
    
    var canSave: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        return true
    }
}
