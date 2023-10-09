//
//  WorkoutViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 29.09.23.
//

import FirebaseFirestore
import Foundation
import SwiftUI

class WorkoutViewViewModel: ObservableObject {
    @Published var nameInit = ""
    @Published var timeInit = Date()
    @Published var locationInit = ""
    @Published var name = ""
    @Published var time = Date()
    @Published var location = ""
    @Published var created = Date().timeIntervalSince1970
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var showAlert = false
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
        
        workoutRef.getDocument { document, error in
                guard let document = document, document.exists else {
                    return
                }
                let data = document.data()
                let time = Date(
                    timeIntervalSince1970: TimeInterval(
                        data?["time"] as? TimeInterval ?? Date().timeIntervalSince1970
                    )
                )
                let name = data?["name"] as? String ?? "name"
                let location = data?["location"] as? String ?? "location"
                let created = data?["created"] as? TimeInterval ?? Date().timeIntervalSince1970
                
                self.nameInit = name
                self.timeInit = time
                self.locationInit = location
                self.name = name
                self.time = time
                self.location = location
                self.created = created
            }
        
        load_exercises()
    }
    
    func deleteElement(elementRef: DocumentReference) {
        elementRef.delete()
    }
    
    func deleteMetadate(metadateRef: DocumentReference) {
        metadateRef
            .collection("elements")
            .getDocuments { snapshot, error in
                if error == nil {
                    if let snapshot = snapshot {
                        for data in snapshot.documents {
                            let elementId = data["id"] as? String ?? "id"
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
        exerciseRef
            .collection("metadata")
            .getDocuments { snapshot, error in
                if error == nil {
                    if let snapshot = snapshot {
                        for data in snapshot.documents {
                            let metadateId = data["id"] as? String ?? "id"
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
    
    func save(userId: String) {
        guard canSave else {
            return
        }
        
        let updatedWorkout = Workout(
            id: workoutId,
            name: name,
            time: time.timeIntervalSince1970,
            location: location,
            created: created,
            edited: Date().timeIntervalSince1970
        )
        
        workoutRef.setData(updatedWorkout.asDictionary())
        
        nameInit = name
        timeInit = time
        locationInit = location
    }
    
    var canSave: Bool {
        guard !location.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        return true
    }
    
    var dataIsInit: Bool {
        guard name == nameInit else {
            return false
        }
        guard time == timeInit else {
            return false
        }
        guard location == locationInit else {
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
    
    func load_elements(exerciseId: String, metadateId: String) {
        elements[exerciseId]?[metadateId] = []
        
        let exerciseRef = workoutRef
            .collection("exercises")
            .document(exerciseId)
        
        let metadateRef = exerciseRef
            .collection("metadata")
            .document(metadateId)
        
        metadateRef
            .collection("elements")
            .getDocuments { snapshot, error in
                if error == nil {
                    if let snapshot = snapshot {
                        for data in snapshot.documents {
                            let element = Element(
                                id: data["id"] as? String ?? "id",
                                content: data["content"] as? String ?? "content",
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
        
        exerciseRef
            .collection("metadata")
            .getDocuments { snapshot, error in
                if error == nil {
                    if let snapshot = snapshot {
                        for data in snapshot.documents {
                            let metadate = Metadate(
                                id: data["id"] as? String ?? "id",
                                name: data["name"] as? String ?? "name",
                                unit: data["unit"] as? String ?? "unit",
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
        
        workoutRef
            .collection("exercises")
            .getDocuments { snapshot, error in
                if error == nil {
                    if let snapshot = snapshot {
                        for data in snapshot.documents {
                            let exercise = Exercise(
                                id: data["id"] as? String ?? "id",
                                name: data["name"] as? String ?? "name",
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
}
