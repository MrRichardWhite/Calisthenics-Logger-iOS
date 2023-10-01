//
//  ExerciseTemplateComponentsViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestore
import Foundation

class ExerciseTemplateComponentsViewViewModel: ObservableObject {
    private let userId: String
    private let exerciseTemplateId: String
    
    init(userId: String, exerciseTemplateId: String) {
        self.userId = userId
        self.exerciseTemplateId = exerciseTemplateId
    }
    
    func delete() {
        
    }
}
