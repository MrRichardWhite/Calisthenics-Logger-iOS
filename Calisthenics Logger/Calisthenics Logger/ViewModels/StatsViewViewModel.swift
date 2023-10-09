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
    
    func deleteFilter(filterRef: DocumentReference) {
        filterRef.delete()
    }
    
    func deleteStat(statRef: DocumentReference) {
        statRef
            .collection("stats")
            .getDocuments { snapshot, error in
                if error == nil {
                    if let snapshot = snapshot {
                        for data in snapshot.documents {
                            let filterId = data["id"] as? String ?? "id"
                            let filterRef = statRef
                                .collection("filters")
                                .document(filterId)
                            
                            self.deleteFilter(filterRef: filterRef)
                        }
                    }
                }
            }
        
        statRef.delete()
    }
    
    func delete(statId: String) {
        let statRef = userRef
            .collection("stats")
            .document(statId)
        
        deleteStat(statRef: statRef)
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
