//
//  LoggerViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import FirebaseFirestore
import Foundation

class LoggerViewViewModel: ObservableObject {
    @Published var showingNewWorkoutView = false
    
    private let userId: String
    
    private let userRef: DocumentReference
    
    init(userId: String) {
        self.userId = userId
        
        self.userRef = Firestore.firestore()
            .collection("users")
            .document(userId)
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
    
    func deleteWorkout(workoutRef: DocumentReference) {
        workoutRef
            .collection("exercises")
            .getDocuments { snapshot, error in
                if error == nil {
                    if let snapshot = snapshot {
                        for data in snapshot.documents {
                            let exerciseId = data["id"] as? String ?? "id"
                            let exerciseRef = workoutRef
                                .collection("exercises")
                                .document(exerciseId)
                            
                            self.deleteExercise(exerciseRef: exerciseRef)
                        }
                    }
                }
            }
        
        workoutRef.delete()
    }
    
    func delete(workoutId: String) {
        let workoutRef = userRef
            .collection("workouts")
            .document(workoutId)
        
        deleteWorkout(workoutRef: workoutRef)
    }
}
