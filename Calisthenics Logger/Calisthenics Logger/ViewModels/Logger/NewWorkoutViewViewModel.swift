//
//  NewWorkoutViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI

class NewWorkoutViewViewModel: ObservableObject {
    @Published var time = Date()
    @Published var location = ""
    @Published var showAlert = false
    @Published var workoutTemplates: [WorkoutTemplate] = [
        WorkoutTemplate(
            id: "",
            name: "",
            exerciseTemplateIds: [],
            created: Date().timeIntervalSince1970,
            edited: Date().timeIntervalSince1970
        )
    ]
    @Published var exerciseTemplates: [ExerciseTemplate] = []
    @Published var metadateTemplates: [MetadateTemplate] = []
    @Published var pickedWorkoutTemplateId = ""

    private let userId: String
    
    private let userRef: DocumentReference
    
    init(userId: String) {
        self.userId = userId
        
        self.userRef = Firestore.firestore()
            .collection("users")
            .document(userId)
        
        userRef
            .collection("workoutTemplates")
            .getDocuments { snapshot, error in
                if error == nil {
                    if let snapshot = snapshot {
                        let workoutTemplates = snapshot.documents.map { data in
                            WorkoutTemplate(
                                id: data["id"] as? String ?? "id",
                                name: data["name"] as? String ?? "name",
                                exerciseTemplateIds: data["exerciseTemplateIds"] as? [String] ?? [],
                                created: data["created"] as? TimeInterval ?? Date().timeIntervalSince1970,
                                edited: data["edited"] as? TimeInterval ?? Date().timeIntervalSince1970
                            )
                        }
                        self.workoutTemplates += workoutTemplates
                    }
                }
            }
        
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
    
    func save(userId: String) {
        guard canSave else {
            return
        }
        
        let newWorkoutId = UUID().uuidString
        let newWorkout = Workout(
            id: newWorkoutId,
            name: pickedWorkoutTemplate.name,
            time: time.timeIntervalSince1970,
            location: location,
            created: Date().timeIntervalSince1970,
            edited: Date().timeIntervalSince1970
        )
        
        let workoutRef = userRef
            .collection("workouts")
            .document(newWorkoutId)

        workoutRef.setData(newWorkout.asDictionary())
        
        for exerciseTemplateId in pickedWorkoutTemplate.exerciseTemplateIds {
            let exerciseTemplate = id2exerciseTemplate(exerciseTemplateId: exerciseTemplateId)
            
            let newExerciseId = UUID().uuidString
            let newExercise = Exercise(
                id: newExerciseId,
                name: exerciseTemplate.name,
                created: Date().timeIntervalSince1970,
                edited: Date().timeIntervalSince1970
            )
            
            let exerciseRef = workoutRef
                .collection("exercises")
                .document(newExerciseId)

            exerciseRef.setData(newExercise.asDictionary())
            
            for exerciseTemplateId in pickedWorkoutTemplate.exerciseTemplateIds {
                let exerciseTemplate = id2exerciseTemplate(exerciseTemplateId: exerciseTemplateId)
                
                for metadateTemplateId in exerciseTemplate.metadateTemplateIds {
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
        }
    }
    
    var canSave: Bool {
        guard !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        return true
    }
    
    var workoutTemplateIds: [String] {
        return workoutTemplates.map { $0.id }
    }
    
    var pickedWorkoutTemplate: WorkoutTemplate {
        for workoutTemplate in workoutTemplates {
            if workoutTemplate.id == pickedWorkoutTemplateId {
                return workoutTemplate
            }
        }
        return workoutTemplates[0]
    }
    
    func id2name(id: String) -> String {
        for workoutTemplate in workoutTemplates {
            if workoutTemplate.id == id {
                return workoutTemplate.name
            }
        }
        return "unknown"
    }
    
    func id2exerciseTemplate(exerciseTemplateId: String) -> ExerciseTemplate {
        for exerciseTemplate in exerciseTemplates {
            if exerciseTemplate.id == exerciseTemplateId {
                return exerciseTemplate
            }
        }
        return ExerciseTemplate(
            id: "",
            name: "",
            metadateTemplateIds: [],
            created: Date().timeIntervalSince1970,
            edited: Date().timeIntervalSince1970
        )
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
    
    var background: Color {
        if canSave {
            return .green
        } else {
            return .gray
        }
    }
}
