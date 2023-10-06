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
    
    private let userRef: DocumentReference
    
    init(userId: String) {
        self.userId = userId
        
        self.userRef = Firestore.firestore()
            .collection("users")
            .document(userId)
    }
    
    func delete(metadateTemplateId: String) {
        let metadateTemplateRef = userRef
            .collection("metadateTemplates")
            .document(metadateTemplateId)
        
        metadateTemplateRef.delete()
    }
}
