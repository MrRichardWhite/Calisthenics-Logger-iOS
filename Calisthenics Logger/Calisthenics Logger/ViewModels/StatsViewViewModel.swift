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
        
        statRef.collection("stats").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    for data in snapshot.documents {
                        let sampleId = data["id"] as? String ?? ""
                        let sampleRef = statRef
                            .collection("samples")
                            .document(sampleId)
                        
                        sampleRef.delete()
                        
                        let filterId = data["id"] as? String ?? ""
                        let filterRef = statRef
                            .collection("filters")
                            .document(filterId)
                        
                        filterRef.delete()
                    }
                }
            }
        }
        
        statRef.delete()
    }
    
    func id2name(exerciseTemplates: [ExerciseTemplate], id: String) -> String {
        for exerciseTemplate in exerciseTemplates {
            if exerciseTemplate.id == id {
                return exerciseTemplate.name
            }
        }
        return "non existant exercise"
    }
    
    func id2name(metadateTemplates: [MetadateTemplate], id: String) -> String {
        for metadateTemplate in metadateTemplates {
            if metadateTemplate.id == id {
                return metadateTemplate.name
            }
        }
        return "non existant metadate"
    }
}
