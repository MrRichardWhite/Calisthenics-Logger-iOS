//
//  ChartViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 11.10.23.
//

import FirebaseFirestore
import Foundation

class ChartViewViewModel: ObservableObject {
    @Published var sampleAnalytics: [Sample] = []
    @Published var loaded = false
    
    private let userId: String
    private let statId: String
    
    private let userRef: DocumentReference
    private let statRef: DocumentReference
    
    init(userId: String, statId: String) {
        self.userId = userId
        self.statId = statId
        
        self.userRef = Firestore.firestore()
            .collection("users")
            .document(userId)
        self.statRef = userRef
            .collection("stats")
            .document(statId)
        
        load()
    }
    
    func load() {
        sampleAnalytics = []
        loaded = false
        
        statRef.collection("samples").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    var sampleAnalytics = snapshot.documents.map { data in
                        Sample(
                            id: data["id"] as? String ?? "",
                            date: data["date"] as? TimeInterval ?? Date().timeIntervalSince1970,
                            content: data["content"] as? Double ?? 0.0
                        )
                    }
                    sampleAnalytics.sort { $0.date < $1.date }
                    self.sampleAnalytics = sampleAnalytics
                    self.loaded = true
                }
            }
        }
    }
    
    var contents: [Double] {
        return sampleAnalytics.map { $0.content }
    }
}
