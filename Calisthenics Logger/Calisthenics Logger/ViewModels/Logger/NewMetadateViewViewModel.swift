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
    @Published var metadateTemplates: [MetadateTemplate] = [
        MetadateTemplate(
            id: "",
            name: "",
            unit: "",
            elementsCount: 1,
            created: Date().timeIntervalSince1970,
            edited: Date().timeIntervalSince1970
        )
    ]
    @Published var pickedMetadateTemplateId = ""
    
    private let userId: String
    private let workoutId: String
    private let exerciseId: String
    
    private let userRef: DocumentReference
    private let workoutRef: DocumentReference
    private let exerciseRef: DocumentReference
    
    init(userId: String, workoutId: String, exerciseId: String) {
        self.userId = userId
        self.workoutId = workoutId
        self.exerciseId = exerciseId
        
        self.userRef = Firestore.firestore()
            .collection("users")
            .document(userId)
        self.workoutRef = userRef
            .collection("workouts")
            .document(workoutId)
        self.exerciseRef = workoutRef
            .collection("exercises")
            .document(exerciseId)
        
        userRef.collection("metadateTemplates").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    let metadateTemplates = snapshot.documents.map { data in
                        MetadateTemplate(
                            id: data["id"] as? String ?? "",
                            name: data["name"] as? String ?? "",
                            unit: data["unit"] as? String ?? "",
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
    
    func save(userId: String, workoutId: String, exericseId: String) {
        let newMetadateId = UUID().uuidString
        let newMetadate = Metadate(
            id: newMetadateId,
            name: pickedMetadateTemplate.name,
            unit: pickedMetadateTemplate.unit,
            created: Date().timeIntervalSince1970,
            edited: Date().timeIntervalSince1970
        )
        
        let metadateRef = exerciseRef
            .collection("metadata")
            .document(newMetadateId)
        
        metadateRef.setData(newMetadate.asDictionary())
        
        for _ in 1...pickedMetadateTemplate.elementsCount {
            let newElementId = UUID().uuidString
            let newElement = Element(
                id: newElementId,
                content: "",
                created: Date().timeIntervalSince1970,
                edited: Date().timeIntervalSince1970
            )
            
            let elementRef = metadateRef
                .collection("elements")
                .document(newElementId)
            
            elementRef.setData(newElement.asDictionary())
        }
    }
    
    var metadateTemplateIds: [String] {
        return metadateTemplates.map { $0.id }
    }
    
    var pickedMetadateTemplate: MetadateTemplate {
        for metadateTemplate in metadateTemplates {
            if metadateTemplate.id == pickedMetadateTemplateId {
                return metadateTemplate
            }
        }
        return metadateTemplates[0]
    }
    
    func id2name(id: String) -> String {
        for metadateTemplate in metadateTemplates {
            if metadateTemplate.id == id {
                return metadateTemplate.name
            }
        }
        return "unknown"
    }
}
