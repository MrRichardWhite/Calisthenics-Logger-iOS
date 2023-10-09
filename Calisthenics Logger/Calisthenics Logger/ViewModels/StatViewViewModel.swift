//
//  StatViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 08.10.23.
//

import FirebaseFirestore
import Foundation
import SwiftUI

class StatViewViewModel: ObservableObject {
    @Published var exerciseTemplateIdInit = ""
    @Published var metadateTemplateIdInit = ""
    @Published var exerciseTemplateId = ""
    @Published var metadateTemplateId = ""
    @Published var created = Date().timeIntervalSince1970
    
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var showAlert = false
    
    private let userId: String
    private let statId: String
    
    private let statRef: DocumentReference

    init(userId: String, statId: String) {
        self.userId = userId
        self.statId = statId
        
        self.statRef = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("stats")
            .document(statId)
        
        statRef.getDocument { document, error in
                guard let document = document, document.exists else {
                    return
                }
                let data = document.data()
                let exerciseTemplateId = data?["exerciseTemplateId"] as? String ?? "exerciseTemplateId"
                let metadateTemplateId = data?["metadateTemplateId"] as? String ?? "metadateTemplateId"
                let created = data?["created"] as? TimeInterval ?? Date().timeIntervalSince1970
                
                self.exerciseTemplateIdInit = exerciseTemplateId
                self.metadateTemplateIdInit = metadateTemplateId
                self.exerciseTemplateId = exerciseTemplateId
                self.metadateTemplateId = metadateTemplateId
                self.created = created
            }
    }
    
    func save() {
        let updatedStat = Stat(
            id: statId,
            exerciseTemplateId: exerciseTemplateId,
            metadateTemplateId: metadateTemplateId,
            created: created,
            edited: Date().timeIntervalSince1970
        )
        
        statRef.setData(updatedStat.asDictionary())
        
        exerciseTemplateIdInit = exerciseTemplateId
        metadateTemplateIdInit = metadateTemplateId
    }
    
    func exerciseTemplateIds(exerciseTemplates: [ExerciseTemplate]) -> [String] {
        return exerciseTemplates.map { $0.id }
    }
    
    func exerciseTemplateNames(exerciseTemplates: [ExerciseTemplate]) -> [String] {
        return exerciseTemplates.map { $0.name }
    }
    
    func id2name(exerciseTemplates: [ExerciseTemplate], id: String) -> String {
        for exerciseTemplate in exerciseTemplates {
            if exerciseTemplate.id == id {
                return exerciseTemplate.name
            }
        }
        return "unknown"
    }
    
    func metadateTemplateIds(metadateTemplates: [MetadateTemplate]) -> [String] {
        return metadateTemplates.map { $0.id }
    }
    
    func exerciseTemplateNames(metadateTemplates: [MetadateTemplate]) -> [String] {
        return metadateTemplates.map { $0.name }
    }
    
    func id2name(metadateTemplates: [MetadateTemplate], id: String) -> String {
        for metadateTemplate in metadateTemplates {
            if metadateTemplate.id == id {
                return metadateTemplate.name
            }
        }
        return "unknown"
    }
    
    var dataIsInit: Bool {
        guard exerciseTemplateId == exerciseTemplateIdInit else {
            return false
        }
        guard metadateTemplateId == metadateTemplateIdInit else {
            return false
        }
        return true
    }
    
    var background: Color {
        if !dataIsInit {
            return .blue
        } else {
            return .gray
        }
    }
}
