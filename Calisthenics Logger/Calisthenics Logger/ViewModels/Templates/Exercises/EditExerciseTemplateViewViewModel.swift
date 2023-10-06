//
//  EditExerciseTemplateViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestore
import Foundation
import SwiftUI

class EditExerciseTemplateViewViewModel: ObservableObject {
    @Published var nameInit = ""
    @Published var metadateTemplateIdsLocalInit: [String] = []
    @Published var name = ""
    @Published var metadateTemplateIdsLocal: [String] = []
    @Published var created = Date().timeIntervalSince1970
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var showAlert = false
    @Published var newMetadateTemplateId: String

    private let userId: String
    private let exerciseTemplateId: String
    
    private let userRef: DocumentReference
    private let exerciseTemplateRef: DocumentReference
    
    init(userId: String, exerciseTemplateId: String) {
        self.userId = userId
        self.exerciseTemplateId = exerciseTemplateId
        
        self.userRef = Firestore.firestore()
            .collection("users")
            .document(userId)
        self.exerciseTemplateRef = userRef
            .collection("exerciseTemplates")
            .document(exerciseTemplateId)

        self.newMetadateTemplateId = ""
        
        exerciseTemplateRef.getDocument { document, error in
                guard let document = document, document.exists else {
                    return
                }
                let data = document.data()
                let name = data?["name"] as? String ?? "name"
                let metadateTemplateIdsLocal = data?["metadateTemplateIds"] as? [String] ?? []
                
                self.nameInit = name
                self.metadateTemplateIdsLocalInit = metadateTemplateIdsLocal
                self.name = name
                self.metadateTemplateIdsLocal = metadateTemplateIdsLocal
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
        
        exerciseTemplateRef.updateData(updatedExerciseTemplate.asDictionary())
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
    
    var dataIsInit: Bool {
        guard name == nameInit else {
            return false
        }
        guard metadateTemplateIdsLocal == metadateTemplateIdsLocalInit else {
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
