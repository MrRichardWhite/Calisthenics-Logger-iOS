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
    
    @Published var exercises: [Exercise] = []
    @Published var metadata: [String:[Metadate]] = [:]
    @Published var elements: [String:[String: [Element]]] = [:]
    
    private let userId: String
    private let workoutId: String
    
    private let workoutRef: DocumentReference
    
    init(userId: String, workoutId: String) {
        self.userId = userId
        self.workoutId = workoutId
        
        self.workoutRef = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("workouts")
            .document(workoutId)
        
        load_exercises()
    }
    
    func deleteElement(elementRef: DocumentReference) {
        elementRef.delete()
    }
    
    func deleteMetadate(metadateRef: DocumentReference) {
        metadateRef.collection("elements").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    for data in snapshot.documents {
                        let elementId = data["id"] as? String ?? ""
                        let elementRef = metadateRef
                            .collection("elements")
                            .document(elementId)
                        
                        self.deleteElement(elementRef: elementRef)

                    }
                }
            }
        }
        
        metadateRef.delete()
    }
    
    func deleteExercise(exerciseRef: DocumentReference) {
        exerciseRef.collection("metadata").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    for data in snapshot.documents {
                        let metadateId = data["id"] as? String ?? ""
                        let metadateRef = exerciseRef
                            .collection("metadata")
                            .document(metadateId)
                        
                        self.deleteMetadate(metadateRef: metadateRef)
                    }
                }
            }
        }
        
        exerciseRef.delete()
    }
    
    func delete(exerciseId: String) {
        let exerciseRef = workoutRef
            .collection("exercises")
            .document(exerciseId)
        
        deleteExercise(exerciseRef: exerciseRef)
    }
    
    func load_elements(exerciseId: String, metadateId: String) {
        elements[exerciseId]?[metadateId] = []
        
        let exerciseRef = workoutRef
            .collection("exercises")
            .document(exerciseId)
        
        let metadateRef = exerciseRef
            .collection("metadata")
            .document(metadateId)
        
        metadateRef.collection("elements").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    for data in snapshot.documents {
                        let element = Element(
                            id: data["id"] as? String ?? "",
                            content: data["content"] as? String ?? "",
                            created: data["created"] as? TimeInterval ?? Date().timeIntervalSince1970,
                            edited: data["id"] as? TimeInterval ?? Date().timeIntervalSince1970
                        )
                        self.elements[exerciseId]?[metadateId]?.append(element)
                    }
                }
            }
        }
    }
    
    func load_metadata(exerciseId: String) {
        metadata[exerciseId] = []
        elements[exerciseId] = [:]
        
        let exerciseRef = workoutRef
            .collection("exercises")
            .document(exerciseId)
        
        exerciseRef.collection("metadata").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    for data in snapshot.documents {
                        let metadate = Metadate(
                            id: data["id"] as? String ?? "",
                            name: data["name"] as? String ?? "",
                            unit: data["unit"] as? String ?? "",
                            created: data["created"] as? TimeInterval ?? Date().timeIntervalSince1970,
                            edited: data["id"] as? TimeInterval ?? Date().timeIntervalSince1970
                        )
                        self.metadata[exerciseId]?.append(metadate)
                        
                        self.load_elements(exerciseId: exerciseId, metadateId: metadate.id)
                    }
                }
            }
        }
    }
    
    func load_exercises() {
        exercises = []
        
        workoutRef.collection("exercises").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    for data in snapshot.documents {
                        let exercise = Exercise(
                            id: data["id"] as? String ?? "",
                            name: data["name"] as? String ?? "",
                            category: data["category"] as? String ?? "",
                            created: data["created"] as? TimeInterval ?? Date().timeIntervalSince1970,
                            edited: data["id"] as? TimeInterval ?? Date().timeIntervalSince1970
                        )
                        self.exercises.append(exercise)
                        
                        self.load_metadata(exerciseId: exercise.id)
                    }
                }
            }
        }
    }
    
    func group(exercises: [Exercise]) -> (
        dict: Dictionary<String, Array<Exercise>>,
        keys: Array<String>
    ) {
        let dict = Dictionary(grouping: exercises) { $0.category }
        let keys = dict.map { $0.key }
        
        return (dict, keys)
    }
}
