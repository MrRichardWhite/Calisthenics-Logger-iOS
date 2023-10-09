//
//  NewExerciseTemplateViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI

class NewExerciseTemplateViewViewModel: ObservableObject {
    @Published var time = Date()
    @Published var name = ""
    @Published var category = ""
    @Published var showAlert = false
    
    private let userId: String
    
    private let userRef: DocumentReference
    
    init(userId: String) {
        self.userId = userId
        
        self.userRef = Firestore.firestore()
            .collection("users")
            .document(userId)
    }
    
    func save() {
        guard canSave else {
            return
        }
        
        let newExerciseTemplateId = UUID().uuidString
        let newExerciseTemplate = ExerciseTemplate(
            id: newExerciseTemplateId,
            name: name,
            category: category,
            metadateTemplateIds: [],
            created: Date().timeIntervalSince1970,
            edited: Date().timeIntervalSince1970
        )
        
        let newExerciseTemplateRef = userRef
            .collection("exerciseTemplates")
            .document(newExerciseTemplateId)
        
        newExerciseTemplateRef.setData(newExerciseTemplate.asDictionary())
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
