//
//  WorkoutViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 29.09.23.
//

import FirebaseFirestore
import Foundation

class WorkoutViewViewModel: ObservableObject {
    @Published var showingEditWorkoutView = false
    @Published var showingNewExerciseView = false
    @Published var reloadInWorkout = false
    
    @Published var exercises: [Exercise] = []
    @Published var metadata: [String:[Metadate]] = [:]
    @Published var elements: [String:[String: [Element]]] = [:]
    
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
        
        load()
    }
    
    func load() {
        exercises = []
        metadata = [:]
        elements = [:]
        
        loadExercises()
    }
    
    func loadExercises() {
        workoutRef.collection("exercises").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    var exercises: [Exercise] = []
                    
                    for data in snapshot.documents {
                        let exercise = Exercise(
                            id: data["id"] as? String ?? "",
                            name: data["name"] as? String ?? "",
                            category: data["category"] as? String ?? "",
                            created: data["created"] as? TimeInterval ?? Date().timeIntervalSince1970,
                            edited: data["id"] as? TimeInterval ?? Date().timeIntervalSince1970
                        )
                        exercises.append(exercise)
                        
                        self.loadMetadata(exerciseId: exercise.id)
                    }
                    exercises.sort { $0.name.withoutEmoji() < $1.name.withoutEmoji() }
                    self.exercises = exercises
                }
            }
        }
    }
    
    func loadMetadata(exerciseId: String) {
        let exerciseRef = workoutRef
            .collection("exercises")
            .document(exerciseId)
        
        exerciseRef.collection("metadata").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    var metadata: [Metadate] = []
                    
                    for data in snapshot.documents {
                        let metadate = Metadate(
                            id: data["id"] as? String ?? "",
                            name: data["name"] as? String ?? "",
                            unit: data["unit"] as? String ?? "",
                            created: data["created"] as? TimeInterval ?? Date().timeIntervalSince1970,
                            edited: data["id"] as? TimeInterval ?? Date().timeIntervalSince1970
                        )
                        metadata.append(metadate)
                        
                        self.loadElements(exerciseId: exerciseId, metadateId: metadate.id)
                    }
                    metadata.sort { $0.name.withoutEmoji() < $1.name.withoutEmoji() }
                    self.metadata[exerciseId] = metadata
                }
            }
        }
    }
    
    func loadElements(exerciseId: String, metadateId: String) {
        self.elements[exerciseId] = [:]
        
        let exerciseRef = workoutRef
            .collection("exercises")
            .document(exerciseId)
        
        let metadateRef = exerciseRef
            .collection("metadata")
            .document(metadateId)
        
        metadateRef.collection("elements").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    var elements: [Element] = []
                    
                    for data in snapshot.documents {
                        let element = Element(
                            id: data["id"] as? String ?? "",
                            content: data["content"] as? String ?? "",
                            created: data["created"] as? TimeInterval ?? Date().timeIntervalSince1970,
                            edited: data["id"] as? TimeInterval ?? Date().timeIntervalSince1970
                        )
                        elements.append(element)
                    }
                    elements.sort { $0.created < $1.created }
                    self.elements[exerciseId]?[metadateId] = elements
                }
            }
        }
    }
    
    func delete(exerciseId: String) {
        let exerciseRef = workoutRef.collection("exercises").document(exerciseId)
        deleteExercise(exerciseRef: exerciseRef)
    }
    
    func deleteExercise(exerciseRef: DocumentReference) {
        exerciseRef.delete()
        exerciseRef.collection("metadata").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    for data in snapshot.documents {
                        let metadateId = data["id"] as? String ?? ""
                        let metadateRef = exerciseRef.collection("metadata").document(metadateId)
                        self.deleteMetadate(metadateRef: metadateRef)
                    }
                }
            }
        }
    }
    
    func deleteMetadate(metadateRef: DocumentReference) {
        metadateRef.delete()
        metadateRef.collection("elements").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    for data in snapshot.documents {
                        let elementId = data["id"] as? String ?? ""
                        let elementRef = metadateRef.collection("elements").document(elementId)
                        self.deleteElement(elementRef: elementRef)
                    }
                }
            }
        }
    }
    
    func deleteElement(elementRef: DocumentReference) {
        elementRef.delete()
    }
}
