//
//  ExerciseViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 28.09.23.
//

import FirebaseFirestore
import Foundation
import SwiftUI

class ExerciseViewViewModel: ObservableObject {
    @Published var showingEditExerciseView = false
    @Published var showingNewMetadateView = false
    @Published var reloadInExercise = false
    
    @Published var metadata: [Metadate] = []
    @Published var elements: [String: [Element]] = [:]
    
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
        
        loadMetadata()
    }
    
    func loadMetadata() {
        exerciseRef.collection("metadata").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    var metadata = snapshot.documents.map { data in
                        let metadate = Metadate(
                            id: data["id"] as? String ?? "",
                            name: data["name"] as? String ?? "",
                            unit: data["unit"] as? String ?? "",
                            created: data["created"] as? TimeInterval ?? Date().timeIntervalSince1970,
                            edited: data["edited"] as? TimeInterval ?? Date().timeIntervalSince1970
                        )
                        self.loadElements(metadateId: metadate.id)
                        return metadate
                    }
                    
                    metadata.sort { $0.name.withoutEmoji() < $1.name.withoutEmoji() }
                    
                    self.metadata = metadata
                }
            }
        }
    }
    
    func loadElements(metadateId: String) {
        let metadateRef = exerciseRef
            .collection("metadata")
            .document(metadateId)
        
        metadateRef.collection("elements").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    var elements = snapshot.documents.map { data in
                        Element(
                            id: data["id"] as? String ?? "",
                            content: data["content"] as? String ?? "",
                            created: data["created"] as? TimeInterval ?? Date().timeIntervalSince1970,
                            edited: data["edited"] as? TimeInterval ?? Date().timeIntervalSince1970
                        )
                    }
                    
                    elements.sort { $0.created < $1.created }
                    
                    self.elements[metadateId] = elements
                }
            }
        }
    }
    
    func delete(metadateId: String) {
        let metadateRef = exerciseRef.collection("metadata").document(metadateId)
        deleteMetdate(metadateRef: metadateRef)
    }
    
    func deleteMetdate(metadateRef: DocumentReference) {
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
