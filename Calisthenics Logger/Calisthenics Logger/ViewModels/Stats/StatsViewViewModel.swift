//
//  StatsViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import FirebaseFirestore
import Foundation

class StatsViewViewModel: ObservableObject {
    @Published var showingNewStatView = false
    @Published var reloadSamples = 0
    
    private let userId: String
    
    private let userRef: DocumentReference
    
    init(userId: String) {
        self.userId = userId
        
        self.userRef = Firestore.firestore()
            .collection("users")
            .document(userId)
    }
    
    func delete(statId: String) {
        let statRef = userRef
            .collection("stats")
            .document(statId)
        
        statRef.collection("samples").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    for data in snapshot.documents {
                        let sampleId = data["id"] as? String ?? ""
                        
                        let sampleRef = statRef.collection("samples").document(sampleId)
                        sampleRef.delete()
                    }
                }
            }
        }
        
        statRef.collection("filters").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    for data in snapshot.documents {
                        let filterId = data["id"] as? String ?? ""
                        
                        let filterRef = statRef.collection("filters").document(filterId)
                        filterRef.delete()
                    }
                }
            }
        }
        
        statRef.delete()
    }
    
    func id2exerciseTemplate(exerciseTemplates: [ExerciseTemplate], id: String) -> ExerciseTemplate? {
        for exerciseTemplate in exerciseTemplates {
            if exerciseTemplate.id == id {
                return exerciseTemplate
            }
        }
        return nil
    }
    
    func id2metadateTemplate(metadateTemplates: [MetadateTemplate], id: String) -> MetadateTemplate? {
        for metadateTemplate in metadateTemplates {
            if metadateTemplate.id == id {
                return metadateTemplate
            }
        }
        return nil
    }
    
    func id2exerciseTemplateCategory(exerciseTemplates: [ExerciseTemplate], id: String) -> String {
        for exerciseTemplate in exerciseTemplates {
            if exerciseTemplate.id == id {
                return exerciseTemplate.category
            }
        }
        return ""
    }
}
