//
//  EditExerciseViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 09.10.23.
//

import FirebaseFirestore
import Foundation
import SwiftUI

class EditExerciseViewViewModel: ObservableObject {
    @Published var nameInit = ""
    @Published var name = ""
    @Published var categoryInit = ""
    @Published var category = ""
    @Published var created = Date().timeIntervalSince1970
    
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var showAlert = false
    
    private let userId: String
    private let workoutId: String
    private let exerciseId: String
    
    private let exerciseRef: DocumentReference
    
    init(userId: String, workoutId: String, exerciseId: String) {
        self.userId = userId
        self.workoutId = workoutId
        self.exerciseId = exerciseId
        
        self.exerciseRef = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("workouts")
            .document(workoutId)
            .collection("exercises")
            .document(exerciseId)
        
        exerciseRef.getDocument { document, error in
            guard let document = document, document.exists else {
                return
            }
            
            let data = document.data()
            let name = data?["name"] as? String ?? ""
            let category = data?["category"] as? String ?? ""
            let created = data?["created"] as? TimeInterval ?? Date().timeIntervalSince1970
            
            self.nameInit = name
            self.name = name
            self.categoryInit = category
            self.category = category
            self.created = created
        }
    }
    
    func save(userId: String) {
        guard canSave else {
            return
        }
        
        let updatedExercise = Exercise(
            id: exerciseId,
            name: name,
            category: category,
            created: created,
            edited: Date().timeIntervalSince1970
        )
        
        exerciseRef.setData(updatedExercise.asDictionary())
        
        nameInit = name
    }
    
    var canSave: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        return true
    }
    
    var dataIsInit: Bool {
        guard name == nameInit else {
            return false
        }
        guard category == categoryInit else {
            return false
        }
        return true
    }
    
    var background: Color {
        if canSave && !dataIsInit {
            return .yellow
        } else {
            return .gray
        }
    }
}
