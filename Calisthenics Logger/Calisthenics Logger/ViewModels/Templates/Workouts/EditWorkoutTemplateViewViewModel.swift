//
//  EditWorkoutTemplateViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestore
import Foundation
import SwiftUI

class EditWorkoutTemplateViewViewModel: ObservableObject {
    @Published var nameInit = ""
    @Published var exerciseTemplateIdsLocalInit: [String] = []
    @Published var name = ""
    @Published var exerciseTemplateIdsLocal: [String] = []
    @Published var created = Date().timeIntervalSince1970
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var showAlert = false
    @Published var newExerciseTemplateId: String

    private let userId: String
    private var workoutTemplateId: String

    private let userRef: DocumentReference
    private let workoutTemplateRef: DocumentReference
    
    init(userId: String, workoutTemplateId: String) {
        self.userId = userId
        
        self.userRef = Firestore.firestore()
            .collection("users")
            .document(userId)
        self.workoutTemplateRef = userRef
            .collection("workoutTemplates")
            .document(workoutTemplateId)
        
        self.workoutTemplateId = workoutTemplateId
        self.newExerciseTemplateId = ""
        
        workoutTemplateRef.getDocument { document, error in
            guard let document = document, document.exists else {
                return
            }
            
            let data = document.data()
            let name = data?["name"] as? String ?? ""
            let exerciseTemplateIdsLocal = data?["exerciseTemplateIds"] as? [String] ?? []
            
            self.name = name
            self.exerciseTemplateIdsLocal = exerciseTemplateIdsLocal
            self.nameInit = name
            self.exerciseTemplateIdsLocalInit = exerciseTemplateIdsLocal
            self.created = data?["created"] as? TimeInterval ?? Date().timeIntervalSince1970
        }
    }
    
    func save(userId: String) {
        guard canSave else {
            return
        }
        
        let updatedWorkoutTemplate = WorkoutTemplate(
            id: workoutTemplateId,
            name: name,
            exerciseTemplateIds: exerciseTemplateIdsLocal,
            created: created,
            edited: Date().timeIntervalSince1970
        )
        
        workoutTemplateRef.updateData(updatedWorkoutTemplate.asDictionary())
    }
    
    var canSave: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        return true
    }
    
    func exerciseTemplateIdsGlobal(exerciseTemplates: [ExerciseTemplate]) -> [String] {
        return exerciseTemplates.map { $0.id }
    }
    
    func exerciseTemplateNamesGlobal(exerciseTemplates: [ExerciseTemplate]) -> [String] {
        return exerciseTemplates.map { $0.name }
    }
    
    func newExerciseTemplateIds(exerciseTemplates: [ExerciseTemplate]) -> [String] {
        return exerciseTemplateIdsGlobal(exerciseTemplates: exerciseTemplates)
    }
    
    func id2name(exerciseTemplates: [ExerciseTemplate], id: String) -> String {
        for exerciseTemplate in exerciseTemplates {
            if exerciseTemplate.id == id {
                return exerciseTemplate.name
            }
        }
        return "unknown"
    }
    
    var dataIsInit: Bool {
        guard name == nameInit else {
            return false
        }
        guard exerciseTemplateIdsLocal == exerciseTemplateIdsLocalInit else {
            return false
        }
        return true
    }
    
    var background: Color {
        if canSave && !dataIsInit {
            return .blue
        } else {
            return .gray
        }
    }
}
