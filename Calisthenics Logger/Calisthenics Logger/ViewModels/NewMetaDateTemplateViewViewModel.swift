//
//  NewMetaDateTemplateViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation

class NewMetaDateTemplateViewViewModel: ObservableObject {
    @Published var time = Date()
    @Published var name = ""
    @Published var unit = ""
    @Published var elementsCount = 1
    @Published var showAlert = false
    
    init() {}
    
    func save(userId: String) {
        guard canSave else {
            return
        }
        
        // Create model
        let newMetaDateTemplateId = UUID().uuidString
        let newMetaDateTemplate = MetaDateTemplate(
            id: newMetaDateTemplateId,
            name: name,
            unit: unit,
            elementsCount: elementsCount,
            created: Date().timeIntervalSince1970
        )
        
        // Save model
        let db = Firestore.firestore()
        
        db.collection("users")
            .document(userId)
            .collection("metadateTemplates")
            .document(newMetaDateTemplateId)
            .setData(newMetaDateTemplate.asDictionary())
    }
    
    var canSave: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        return true
    }
}
