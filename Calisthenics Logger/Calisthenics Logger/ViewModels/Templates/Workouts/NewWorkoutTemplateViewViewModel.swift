//
//  NewWorkoutTemplateViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI

class NewWorkoutTemplateViewViewModel: ObservableObject {
    @Published var time = Date()
    @Published var name = ""
    @Published var showAlert = false
    
    private let userId: String
    
    private let userRef: DocumentReference
    
    init(userId: String) {
        self.userId = userId
        
        self.userRef = Firestore.firestore()
            .collection("users")
            .document(userId)
    }
    
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
            created: Date().timeIntervalSince1970,
            edited: Date().timeIntervalSince1970
        )
        
        let workoutTemplateRef = userRef
            .collection("workoutTemplates")
            .document(newWorkoutTemplateId)
        
        workoutTemplateRef.setData(newWorkoutTemplate.asDictionary())
    }
    
    var canSave: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        return true
    }
    
    var background: Color {
        if canSave {
            return .green
        } else {
            return .gray
        }
    }
}
