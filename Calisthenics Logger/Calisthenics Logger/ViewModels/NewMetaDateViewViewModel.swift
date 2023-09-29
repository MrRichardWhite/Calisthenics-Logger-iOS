//
//  NewMetaDateViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 29.09.23.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class NewMetaDateViewViewModel: ObservableObject {
    @Published var template = ""
    
    init() {}
    
    func save(workoutId: String, exericseId: String) {
        // Get current user id
        guard let userId = Auth.auth().currentUser?.uid else {
            return
        }
        
        // Create model
        var unit = ""
        if template == "Reps" {
            unit = ""
        } else if template == "Time" {
            unit = "s"
        }
        let newId = UUID().uuidString
        let newMetaDate = MetaDate(
            id: newId,
            name: template,
            unit: unit,
            created: Date().timeIntervalSince1970
        )
        
        // Save model
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userId)
            .collection("workouts")
            .document(workoutId)
            .collection("exercises")
            .document(exericseId)
            .collection("metadata")
            .document(newId)
            .setData(newMetaDate.asDictionary())
    }
}
