//
//  MetadateTemplatesViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestore
import Foundation

class MetadateTemplatesViewViewModel: ObservableObject {
    @Published var showingNewMetadateTemplateView = false
    
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    func delete(metadateTemplateId: String) {
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userId)
            .collection("metadateTemplates")
            .document(metadateTemplateId)
            .delete()
    }
}