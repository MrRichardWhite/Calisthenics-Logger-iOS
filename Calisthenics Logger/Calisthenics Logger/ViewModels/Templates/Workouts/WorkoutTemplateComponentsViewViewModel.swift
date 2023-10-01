//
//  WorkoutTemplateComponentsViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestore
import Foundation

class WorkoutTemplateComponentsViewViewModel: ObservableObject {
    private let userId: String
    private let workoutTemplateId: String
    
    init(userId: String, workoutTemplateId: String) {
        self.userId = userId
        self.workoutTemplateId = workoutTemplateId
    }
    
    func delete() {
        
    }
}
