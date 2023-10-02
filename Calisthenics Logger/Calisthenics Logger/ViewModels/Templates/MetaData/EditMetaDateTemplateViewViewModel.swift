//
//  EditMetadateTemplateViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestore
import Foundation

class EditMetadateTemplateViewViewModel: ObservableObject {
    @Published var name = ""
    @Published var unit = ""
    @Published var elementsCount = 1
    @Published var created = Date().timeIntervalSince1970
    @Published var showAlert = false

    private let userId: String
    private let metadateTemplateId: String
    
    init(userId: String, metadateTemplateId: String) {
        self.userId = userId
        self.metadateTemplateId = metadateTemplateId
        
        let ref = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("metadateTemplates")
            .document(metadateTemplateId)
        
        ref.getDocument { document, error in
            guard let document = document, document.exists else {
                print("Document does not exist")
                return
            }
            let data = document.data()
            self.name = data?["name"] as? String ?? "name"
            self.unit = data?["unit"] as? String ?? "unit"
            self.elementsCount = data?["elementsCount"] as? Int ?? 1
            self.created = data?["created"] as? TimeInterval ?? Date().timeIntervalSince1970
        }
    }
    
    func save(userId: String) {
        guard canSave else {
            return
        }
        
        let updatedMetadateTemplate = MetadateTemplate(
            id: metadateTemplateId,
            name: name,
            unit: unit,
            elementsCount: elementsCount,
            created: created,
            edited: Date().timeIntervalSince1970
        )
        
        Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("metadateTemplates")
            .document(metadateTemplateId)
            .updateData(updatedMetadateTemplate.asDictionary())
    }
    
    var canSave: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        
        return true
    }
}
