//
//  MetadateViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 28.09.23.
//

import FirebaseFirestore
import Foundation
import SwiftUI

class MetadateViewViewModel: ObservableObject {
    @Published var nameInit = ""
    @Published var unitInit = ""
    @Published var elementsInit: [Element] = []
    @Published var name = ""
    @Published var unit = ""
    @Published var elements: [Element] = []
    @Published var created = Date().timeIntervalSince1970
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var showAlert = false
    @Published var showingNewMetadateView = false
    
    private let userId: String
    private let workoutId: String
    private let exerciseId: String
    private let metadateId: String
    
    private let metadateRef: DocumentReference
    
    private var elementIdsAdd: [String] = []
    private var elementIdsDelete: [String] = []
    
    init(userId: String, workoutId: String, exerciseId: String, metadateId: String) {
        self.userId = userId
        self.workoutId = workoutId
        self.exerciseId = exerciseId
        self.metadateId = metadateId
        
        self.metadateRef = Firestore.firestore()
            .collection("users")
            .document(userId)
            .collection("workouts")
            .document(workoutId)
            .collection("exercises")
            .document(exerciseId)
            .collection("metadata")
            .document(metadateId)
        
        metadateRef.getDocument { document, error in
            guard let document = document, document.exists else {
                return
            }
            
            let data = document.data()
            let name = data?["name"] as? String ?? ""
            let unit = data?["unit"] as? String ?? ""
            self.nameInit = name
            self.unitInit = unit
            self.name = name
            self.unit = unit
            self.created = data?["created"] as? TimeInterval ?? Date().timeIntervalSince1970
        }
        
        metadateRef.collection("elements").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    let elements = snapshot.documents.map { data in
                        Element(
                            id: data["id"] as? String ?? "",
                            content: data["content"] as? String ?? "",
                            created: data["created"] as? TimeInterval ?? Date().timeIntervalSince1970,
                            edited: data["edited"] as? TimeInterval ?? Date().timeIntervalSince1970
                        )
                    }
                    self.elementsInit += elements
                    self.elements += elements
                }
            }
        }
    }
    
    func delete(elementId: String) {
        elementIdsDelete.append(elementId)
        
        if let index: Int = elements.firstIndex(where: { $0.id == elementId }) {
            elements.remove(at: index)
        }
    }
    
    func save(userId: String) {
        guard canSave else {
            return
        }
        
        let updatedMetadate = Metadate(
            id: metadateId,
            name: name,
            unit: unit,
            created: created,
            edited: Date().timeIntervalSince1970
        )
        
        metadateRef.updateData(updatedMetadate.asDictionary())
        
        nameInit = name
        unitInit = unit
        
        for element in elements {
            let elementRef = metadateRef
                .collection("elements")
                .document(element.id)
            
            if elementIdsAdd.contains(element.id) {
                let newElement = Element(
                    id: element.id,
                    content: element.content,
                    created: Date().timeIntervalSince1970,
                    edited: Date().timeIntervalSince1970
                )
                
                elementRef.setData(newElement.asDictionary())
            } else {
                let updatedElement = Element(
                    id: element.id,
                    content: element.content,
                    created: element.created,
                    edited: Date().timeIntervalSince1970
                )
                
                elementRef.updateData(updatedElement.asDictionary())
            }
        }
        
        for elementIdDelete in elementIdsDelete {
            let elementRef = metadateRef
                .collection("elements")
                .document(elementIdDelete)
            
            elementRef.delete()
        }
        
        elementIdsAdd = []
        elementIdsDelete = []
        
        elementsInit = elements
    }
    
    var canSave: Bool {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        return true
    }
    
    func add() {
        let newElementId = UUID().uuidString
        let newElement = Element(
            id: newElementId,
            content: "",
            created: Date().timeIntervalSince1970,
            edited: Date().timeIntervalSince1970
        )
        
        elementIdsAdd.append(newElementId)
        elements.append(newElement)
    }
    
    var dataIsInit: Bool {
        guard name == nameInit else {
            return false
        }
        guard unit == unitInit else {
            return false
        }
        guard elements.count == elementsInit.count else {
            return false
        }
        for (element, elementInit) in zip(elements, elementsInit) {
            guard element.id == elementInit.id else {
                return false
            }
            guard element.content == elementInit.content else {
                return false
            }
            guard element.created == elementInit.created else {
                return false
            }
            guard element.edited == elementInit.edited else {
                return false
            }
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
    
    var elementIds: [String] {
        return elements.map { $0.id }
    }
}
