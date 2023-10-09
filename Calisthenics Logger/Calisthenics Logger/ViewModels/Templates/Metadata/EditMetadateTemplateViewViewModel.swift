//
//  EditMetadateTemplateViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestore
import Foundation
import SwiftUI

class EditMetadateTemplateViewViewModel: ObservableObject {
    @Published var nameInit = ""
    @Published var unitInit = ""
    @Published var elementsCountInit = 1
    @Published var name = ""
    @Published var unit = ""
    @Published var elementsCount = 1
    @Published var created = Date().timeIntervalSince1970
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var showAlert = false

    private let userId: String
    private let metadateTemplateId: String
    
    private let userRef: DocumentReference
    private let metadateTemplateRef: DocumentReference
    
    init(userId: String, metadateTemplateId: String) {
        self.userId = userId
        self.metadateTemplateId = metadateTemplateId
        
        self.userRef = Firestore.firestore()
            .collection("users")
            .document(userId)
        self.metadateTemplateRef = userRef
            .collection("metadateTemplates")
            .document(metadateTemplateId)
        
        metadateTemplateRef.getDocument { document, error in
            guard let document = document, document.exists else {
                print("Document does not exist")
                return
            }
            let data = document.data()
            let name = data?["name"] as? String ?? ""
            let unit = data?["unit"] as? String ?? ""
            let elementsCount = data?["elementsCount"] as? Int ?? 1

            self.nameInit = name
            self.unitInit = unit
            self.elementsCountInit = elementsCount
            self.name = name
            self.unit = unit
            self.elementsCount = elementsCount
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
        
        metadateTemplateRef.updateData(updatedMetadateTemplate.asDictionary())
    }
    
    var canSave: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        return true
    }
    
    var dataIsInit: Bool {
        guard name == nameInit else {
            return false
        }
        guard unit == unitInit else {
            return false
        }
        guard elementsCount == elementsCountInit else {
            return false
        }
        return true
    }
    
    var background: Color {
        if canSave && !dataIsInit {
            return .blue
        } else {
            return .gray
        }
    }
}
