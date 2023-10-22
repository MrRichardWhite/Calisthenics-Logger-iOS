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
    private var metadateInit = Metadate()
    @Published var metadate = Metadate()
    
    private var elementsInit: [Element] = []
    @Published var elements: [Element] = []
    
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var showAlert = false
    
    @Published var showingNewMetadateView = false
    
    private let userId: String
    private let workoutId: String
    private let exerciseId: String
    private let metadateId: String
    
    private let userRef: DocumentReference
    private let workoutRef: DocumentReference
    private let exerciseRef: DocumentReference
    private let metadateRef: DocumentReference
    
    private var elementIdsAdd: [String] = []
    private var elementIdsDelete: [String] = []
    
    init(userId: String, workoutId: String, exerciseId: String, metadateId: String) {
        self.userId = userId
        self.workoutId = workoutId
        self.exerciseId = exerciseId
        self.metadateId = metadateId
        
        self.userRef = Firestore.firestore()
            .collection("users")
            .document(userId)
        self.workoutRef = userRef
            .collection("workouts")
            .document(workoutId)
        self.exerciseRef = workoutRef
            .collection("exercises")
            .document(exerciseId)
        self.metadateRef = exerciseRef
            .collection("metadata")
            .document(metadateId)
        
        loadMetadate()
        loadElements()
    }
    
    func loadMetadate() {
        metadateRef.getDocument { document, error in
            guard let document = document, document.exists else {
                return
            }
            
            let data = document.data()
            let metadate = Metadate(
                id: data?["id"] as? String ?? "",
                name: data?["name"] as? String ?? "",
                unit: data?["unit"] as? String ?? "",
                created: data?["created"] as? TimeInterval ?? Date().timeIntervalSince1970,
                edited: data?["edited"] as? TimeInterval ?? Date().timeIntervalSince1970
            )
            
            self.metadateInit = metadate
            self.metadate = metadate
            
        }
    }
    
    func loadElements() {
        metadateRef.collection("elements").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    var elements = snapshot.documents.map { data in
                        Element(
                            id: data["id"] as? String ?? "",
                            content: data["content"] as? String ?? "",
                            created: data["created"] as? TimeInterval ?? Date().timeIntervalSince1970,
                            edited: data["edited"] as? TimeInterval ?? Date().timeIntervalSince1970
                        )
                    }
                    
                    elements.sort { $0.created < $1.created }
                    
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
    
    func save() {
        guard canSave else { return }
        
        saveMetadate()
        saveElements()
    }
    
    var canSave: Bool {
        guard !metadate.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return false
        }
        return true
    }
    
    func saveMetadate() {
        metadate.edited = Date().timeIntervalSince1970
        metadateRef.updateData(metadate.asDictionary())
        
        metadateInit = metadate
    }
    
    func saveElements() {
        for element in elements {
            let e = Element(
                id: element.id,
                content: element.content,
                created: element.created,
                edited: Date().timeIntervalSince1970
            )
            
            let elementRef = metadateRef.collection("elements").document(element.id)
            if elementIdsAdd.contains(element.id) {
                elementRef.setData(e.asDictionary())
            } else {
                elementRef.updateData(e.asDictionary())
            }
        }
        
        for elementIdDelete in elementIdsDelete {
            let elementRef = metadateRef.collection("elements").document(elementIdDelete)
            elementRef.delete()
        }
        
        elementIdsAdd = []
        elementIdsDelete = []
        
        elementsInit = elements
    }
    
    func add() {
        let newElement = Element()
        
        elements.append(newElement)
        elementIdsAdd.append(newElement.id)
    }
    
    var dataIsInit: Bool {
        guard metadate.name == metadateInit.name else { return false }
        guard metadate.unit == metadateInit.unit else { return false }
        
        guard elements.count == elementsInit.count else { return false }
        for (element, elementInit) in zip(elements, elementsInit) {
            guard element.content == elementInit.content else { return false }
        }
        
        return true
    }
    
    var background: Color {
        return canSave && !dataIsInit ? .blue : .gray
    }
    
    var elementIds: [String] {
        return elements.map { $0.id }
    }
}
