//
//  EditExerciseTemplateViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestore
import Foundation

@MainActor
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
        
//        self.metadateTemplateIdsGlobal = [
//            "356A799F-C391-4621-832F-5B8E449380D2",
//            "3BD4E384-B701-46A9-AFCE-94C259DBFB29",
//            "4BDE6066-2A9A-467D-9752-E14FAD0A19A3",
//            "93179AA1-7097-4228-AEC1-9C040A157132",
//            "E12073F6-AE6A-4A08-9B06-2A175ED8FD12"
//        ]
//        self.metadateTemplateNamesGlobal = [
//            "Reps",
//            "Weight",
//            "Time",
//            "Variation",
//            "Ring Strap Length"
//        ]
        
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
