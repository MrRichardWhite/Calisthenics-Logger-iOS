//
//  NewExerciseViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 29.09.23.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class NewExerciseViewViewModel: ObservableObject {
    @Published var exerciseTemplates: [ExerciseTemplate] = [
        ExerciseTemplate(
            id: "",
            name: "",
            metadateTemplateIds: [],
            created: Date().timeIntervalSince1970,
            edited: Date().timeIntervalSince1970
        )
    ]
    @Published var metadateTemplates: [MetadateTemplate] = []
    @Published var pickedExerciseTemplateId = ""

    private let userId: String
    private let workoutId: String
    
    private let userRef: DocumentReference
    private let workoutRef: DocumentReference
    
    init(userId: String, workoutId: String) {
        self.userId = userId
        self.workoutId = workoutId
        
        self.userRef = Firestore.firestore()
            .collection("users")
            .document(userId)
        self.workoutRef = userRef
            .collection("workouts")
            .document(workoutId)

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
    
    func save(userId: String, workoutId: String) {
        let newExerciseId = UUID().uuidString
        let newExercise = Exercise(
            id: newExerciseId,
            name: pickedExerciseTemplate.name,
            created: Date().timeIntervalSince1970,
            edited: Date().timeIntervalSince1970
        )
        
        let exerciseRef = workoutRef
            .collection("exercises")
            .document(newExerciseId)
        
        exerciseRef.setData(newExercise.asDictionary())
        
        for metadateTemplateId in pickedExerciseTemplate.metadateTemplateIds {
            let metadateTemplate = id2metadateTemplate(metadateTemplateId: metadateTemplateId)
            
            let newMetadateId = UUID().uuidString
            let newMetadate = Metadate(
                id: newMetadateId,
                name: metadateTemplate.name,
                unit: metadateTemplate.unit,
                created: Date().timeIntervalSince1970,
                edited: Date().timeIntervalSince1970
            )
            
            let metadateRef = exerciseRef
                .collection("metadata")
                .document(newMetadateId)
            
            metadateRef.setData(newMetadate.asDictionary())

            for _ in 1...metadateTemplate.elementsCount {
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
    }
    
    var exerciseTemplateIds: [String] {
        return exerciseTemplates.map { $0.id }
    }
    
    var pickedExerciseTemplate: ExerciseTemplate {
        for exerciseTemplate in exerciseTemplates {
            if exerciseTemplate.id == pickedExerciseTemplateId {
                return exerciseTemplate
            }
        }
        return exerciseTemplates[0]
    }
    
    func id2name(id: String) -> String {
        for exerciseTemplate in exerciseTemplates {
            if exerciseTemplate.id == id {
                return exerciseTemplate.name
            }
        }
        return "unknown"
    }
    
    func id2metadateTemplate(metadateTemplateId: String) -> MetadateTemplate {
        for metadateTemplate in metadateTemplates {
            if metadateTemplate.id == metadateTemplateId {
                return metadateTemplate
            }
        }
        return MetadateTemplate(
            id: "",
            name: "",
            unit: "",
            elementsCount: 1,
            created: Date().timeIntervalSince1970,
            edited: Date().timeIntervalSince1970
        )
    }
}
