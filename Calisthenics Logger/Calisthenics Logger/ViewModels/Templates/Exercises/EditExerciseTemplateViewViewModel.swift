//
//  EditExerciseTemplateViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestore
import Foundation

class EditExerciseTemplateViewViewModel: ObservableObject {
    @Published var name = ""
    @Published var metadateTemplateIdsLocal: [String] = []
    @Published var created = Date().timeIntervalSince1970
    @Published var showAlert = false
    @Published var newMetadateTemplateId: String
    
    private let userId: String
    @Published var exerciseTemplateId: String
    
    init(userId: String, exerciseTemplateId: String) {
        self.userId = userId
        self.exerciseTemplateId = exerciseTemplateId
        self.newMetadateTemplateId = ""
        
        Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("exerciseTemplates")
            .document(exerciseTemplateId)
            .getDocument { document, error in
                guard let document = document, document.exists else {
                    return
                }
                let data = document.data()
                self.name = data?["name"] as? String ?? "name"
                self.metadateTemplateIdsLocal = data?["metadateTemplateIds"] as? [String] ?? []
                self.created = data?["created"] as? TimeInterval ?? Date().timeIntervalSince1970
            }
    }
    
    func save(userId: String) {
        guard canSave else {
            return
        }
        
        let updatedExerciseTemplate = ExerciseTemplate(
            id: exerciseTemplateId,
            name: name,
            metadateTemplateIds: metadateTemplateIdsLocal,
            created: created,
            edited: Date().timeIntervalSince1970
        )
        
        Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("exerciseTemplates")
            .document(exerciseTemplateId)
            .updateData(updatedExerciseTemplate.asDictionary())
    }
    
    var canSave: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        return true
    }
    
    func metadateTemplateIdsGlobal(metadateTemplates: [MetadateTemplate]) -> [String] {
        return metadateTemplates.map { $0.id }
    }
    
    func metadateTemplateNamesGlobal(metadateTemplates: [MetadateTemplate]) -> [String] {
        return metadateTemplates.map { $0.name }
    }
    
    func newMetadateTemplateIds(metadateTemplates: [MetadateTemplate]) -> [String] {
        return metadateTemplateIdsGlobal(metadateTemplates: metadateTemplates).filter {
            !metadateTemplateIdsLocal.contains($0)
        }
    }
    
    func id2name(metadateTemplates: [MetadateTemplate], id: String) -> String {
        for metadateTemplate in metadateTemplates {
            if metadateTemplate.id == id {
                return metadateTemplate.name
            }
        }
        return "unknown"
    }
}
