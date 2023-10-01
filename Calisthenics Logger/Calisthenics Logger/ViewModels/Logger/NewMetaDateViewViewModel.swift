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
    
    func save(userId: String, workoutId: String, exericseId: String) {
        // Create model
        var unit = ""
        if template == "Reps" {
            unit = ""
        } else if template == "Time" {
            unit = "s"
        }
        let newMetaDateId = UUID().uuidString
        let newMetaDate = MetaDate(
            id: newMetaDateId,
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
            .document(newMetaDateId)
            .setData(newMetaDate.asDictionary())
    }
}
