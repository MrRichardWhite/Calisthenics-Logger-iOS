//
//  NewMetadateViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 29.09.23.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class NewMetadateViewViewModel: ObservableObject {
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
        let newMetadateId = UUID().uuidString
        let newMetadate = Metadate(
            id: newMetadateId,
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
            .document(newMetadateId)
            .setData(newMetadate.asDictionary())
    }
}
