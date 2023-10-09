//
//  NewMetadateTemplateViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseAuth
import FirebaseFirestore
import Foundation
import SwiftUI

class NewMetadateTemplateViewViewModel: ObservableObject {
    @Published var time = Date()
    @Published var name = ""
    @Published var unit = ""
    @Published var elementsCount = 1
    @Published var showAlert = false
    
    private let userId: String
    
    private let userRef: DocumentReference
    
    init(userId: String) {
        self.userId = userId
        
        self.userRef = Firestore.firestore()
            .collection("users")
            .document(userId)
    }
    
    func save() {
        guard canSave else {
            return
        }
        
        let newMetadateTemplateId = UUID().uuidString
        let newMetadateTemplate = MetadateTemplate(
            id: newMetadateTemplateId,
            name: name,
            unit: unit,
            elementsCount: elementsCount,
            created: Date().timeIntervalSince1970,
            edited: Date().timeIntervalSince1970
        )
        
        let newMetadateTemplateRef = userRef
            .collection("metadateTemplates")
            .document(newMetadateTemplateId)
        
        newMetadateTemplateRef.setData(newMetadateTemplate.asDictionary())
    }
    
    var canSave: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        return true
    }
    
    var background: Color {
        if canSave {
            return .green
        } else {
            return .gray
        }
    }
}
