//
//  EditWorkoutTemplateViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestore
import Foundation

class EditWorkoutTemplateViewViewModel: ObservableObject {
    @Published var name = ""
    @Published var exerciseTemplateIdsLocal: [String] = []
    @Published var created = Date().timeIntervalSince1970
    @Published var showAlert = false
    @Published var newExerciseTemplateId: String
    
    private let userId: String
    @Published var workoutTemplateId: String
    
    init(userId: String, workoutTemplateId: String) {
        self.userId = userId
        self.workoutTemplateId = workoutTemplateId
        self.newExerciseTemplateId = ""
        
        Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("workoutTemplates")
            .document(workoutTemplateId)
            .getDocument { document, error in
                guard let document = document, document.exists else {
                    return
                }
                let data = document.data()
                self.name = data?["name"] as? String ?? "name"
                self.exerciseTemplateIdsLocal = data?["exerciseTemplateIds"] as? [String] ?? []
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
        
        Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("workoutTemplates")
            .document(workoutTemplateId)
            .updateData(updatedWorkoutTemplate.asDictionary())
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
}
