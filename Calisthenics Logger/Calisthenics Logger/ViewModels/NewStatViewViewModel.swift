//
//  NewStatViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 09.10.23.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class NewStatViewViewModel: ObservableObject {
    @Published var exerciseTemplates: [ExerciseTemplate] = []
    @Published var metadateTemplates: [MetadateTemplate] = []
    @Published var pickedExerciseTemplateId = ""
    @Published var pickedMetadateTemplateId = ""
    
    private let userId: String
    
    private let userRef: DocumentReference
    
    init(userId: String) {
        self.userId = userId
        
        self.userRef = Firestore.firestore()
            .collection("users")
            .document(userId)

        userRef
            .collection("exerciseTemplates")
            .getDocuments { snapshot, error in
                if error == nil {
                    if let snapshot = snapshot {
                        let exerciseTemplates = snapshot.documents.map { data in
                            ExerciseTemplate(
                                id: data["id"] as? String ?? "id",
                                name: data["name"] as? String ?? "name",
                                metadateTemplateIds: data["metadateTemplateIds"] as? [String] ?? [],
                                created: data["created"] as? TimeInterval ?? Date().timeIntervalSince1970,
                                edited: data["edited"] as? TimeInterval ?? Date().timeIntervalSince1970
                            )
                        }
                        self.exerciseTemplates += exerciseTemplates
                    }
                }
            }
        
        userRef
            .collection("metadateTemplates")
            .getDocuments { snapshot, error in
                if error == nil {
                    if let snapshot = snapshot {
                        let metadateTemplates = snapshot.documents.map { data in
                            MetadateTemplate(
                                id: data["id"] as? String ?? "id",
                                name: data["name"] as? String ?? "name",
                                unit: data["unit"] as? String ?? "unit",
                                elementsCount: data["elementsCount"] as? Int ?? 0,
                                created: data["created"] as? TimeInterval ?? Date().timeIntervalSince1970,
                                edited: data["edited"] as? TimeInterval ?? Date().timeIntervalSince1970
                            )
                        }
                        self.metadateTemplates += metadateTemplates
                    }
                }
            }
    }
    
    func save() {
        let newStatId = UUID().uuidString
        let newStat = Stat(
            id: newStatId,
            exerciseTemplateId: pickedExerciseTemplateId,
            metadateTemplateId: pickedMetadateTemplateId,
            created: Date().timeIntervalSince1970,
            edited: Date().timeIntervalSince1970
        )
        
        let statRef = userRef
            .collection("stats")
            .document(newStatId)
        
        statRef.setData(newStat.asDictionary())
    }
    
    var exerciseTemplateIds: [String] {
        return exerciseTemplates.map { $0.id }
    }
    
    func id2name(exerciseTemplateId: String) -> String {
        for exerciseTemplate in exerciseTemplates {
            if exerciseTemplate.id == exerciseTemplateId {
                return exerciseTemplate.name
            }
        }
        return "non existant exercise"
    }
    
    var pickedExerciseTemplate: ExerciseTemplate {
        for exerciseTemplate in exerciseTemplates {
            if exerciseTemplate.id == pickedExerciseTemplateId {
                return exerciseTemplate
            }
        }
        return exerciseTemplates[0]
    }
    
    var metadateTemplateIds: [String] {
        return metadateTemplates.map { $0.id }
    }
    
    func id2name(metadateTemplateId: String) -> String {
        for metadateTemplate in metadateTemplates {
            if metadateTemplate.id == metadateTemplateId {
                return metadateTemplate.name
            }
        }
        return "non existant metadate"
    }
    
    var pickedMetadateTemplate: MetadateTemplate {
        for metadateTemplate in metadateTemplates {
            if metadateTemplate.id == pickedMetadateTemplateId {
                return metadateTemplate
            }
        }
        return metadateTemplates[0]
    }
}
