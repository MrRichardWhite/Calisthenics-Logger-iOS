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

    @Published var metadata: [Metadate] = []
    @Published var elements: [String: [Element]] = [:]
    
    private let userId: String
    private let workoutId: String
    private let exerciseId: String
    
    private let exerciseRef: DocumentReference
    
    init(userId: String, workoutId: String, exerciseId: String) {
        self.userId = userId
        self.workoutId = workoutId
        self.exerciseId = exerciseId
        
        self.exerciseRef = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("workouts")
            .document(workoutId)
            .collection("exercises")
            .document(exerciseId)
        
        load_metadata()
    }
    
    func deleteElement(elementRef: DocumentReference) {
        elementRef.delete()
    }
    
    func deleteMetdate(metadateRef: DocumentReference) {
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
                        
                        metadateRef.delete()
                    }
                }
            }
    }
    
    func delete(metadateId: String) {
        let metadateRef = exerciseRef
            .collection("metadata")
            .document(metadateId)
        
        deleteMetdate(metadateRef: metadateRef)
    }
    
    func load_elements(metadateId: String) {
        elements[metadateId] = []
        
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
                            self.elements[metadateId]?.append(element)
                        }
                    }
                }
            }
    }
    
    func load_metadata() {
        metadata = []
        
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
                            self.metadata.append(metadate)
                            
                            self.load_elements(metadateId: metadate.id)
                        }
                    }
                }
            }
    }
}
