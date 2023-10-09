//
//  EditWorkoutViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 09.10.23.
//

import FirebaseFirestore
import Foundation
import SwiftUI

class EditWorkoutViewViewModel: ObservableObject {
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
            let name = data?["name"] as? String ?? ""
            let location = data?["location"] as? String ?? ""
            let created = data?["created"] as? TimeInterval ?? Date().timeIntervalSince1970
            
            self.nameInit = name
            self.timeInit = time
            self.locationInit = location
            self.name = name
            self.time = time
            self.location = location
            self.created = created
        }
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
}
