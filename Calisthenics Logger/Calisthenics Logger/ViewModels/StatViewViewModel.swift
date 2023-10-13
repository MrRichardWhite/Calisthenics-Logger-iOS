//
//  StatViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 08.10.23.
//

import FirebaseFirestore
import Foundation
import SwiftUI

class StatViewViewModel: ObservableObject {
    @Published var exerciseTemplates: [ExerciseTemplate] = []
    @Published var metadateTemplates: [MetadateTemplate] = []
    
    @Published var exerciseTemplateIdInit = ""
    @Published var metadateTemplateIdInit = ""
    @Published var aggregationInit = ""
    @Published var exerciseTemplateId = ""
    @Published var metadateTemplateId = ""
    @Published var aggregation = ""
    @Published var created = Date().timeIntervalSince1970
    
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var showAlert = false
    
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
        
        statRef.getDocument { document, error in
            guard let document = document, document.exists else {
                return
            }
            
            let data = document.data()
            let exerciseTemplateId = data?["exerciseTemplateId"] as? String ?? ""
            let metadateTemplateId = data?["metadateTemplateId"] as? String ?? ""
            let aggregation = data?["aggregation"] as? String ?? ""
            let created = data?["created"] as? TimeInterval ?? Date().timeIntervalSince1970
            
            self.exerciseTemplateIdInit = exerciseTemplateId
            self.metadateTemplateIdInit = metadateTemplateId
            self.aggregationInit = aggregation
            self.exerciseTemplateId = exerciseTemplateId
            self.metadateTemplateId = metadateTemplateId
            self.aggregation = aggregation
            self.created = created
        }
        
        loadExerciseTemplates()
        loadMetadateTemplates()
        updateSamples()
    }
    
    func loadExerciseTemplates() {
        userRef.collection("exerciseTemplates").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    var exerciseTemplates = snapshot.documents.map { data in
                        ExerciseTemplate(
                            id: data["id"] as? String ?? "",
                            name: data["name"] as? String ?? "",
                            category: data["category"] as? String ?? "",
                            metadateTemplateIds: data["metadateTempateIds"] as? [String] ?? [],
                            created: data["created"] as? TimeInterval ?? Date().timeIntervalSince1970,
                            edited: data["edited"] as? TimeInterval ?? Date().timeIntervalSince1970
                        )
                    }
                    exerciseTemplates.sort { $0.name.withoutEmoji() < $1.name.withoutEmoji() }
                    self.exerciseTemplates = exerciseTemplates
                }
            }
        }
    }
    
    func loadMetadateTemplates() {
        userRef.collection("metadateTemplates").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    var metadateTemplates = snapshot.documents.map { data in
                        MetadateTemplate(
                            id: data["id"] as? String ?? "",
                            name: data["name"] as? String ?? "",
                            unit: data["unit"] as? String ?? "",
                            elementsCount: data["elementsCount"] as? Int ?? 1,
                            created: data["created"] as? TimeInterval ?? Date().timeIntervalSince1970,
                            edited: data["edited"] as? TimeInterval ?? Date().timeIntervalSince1970
                        )
                    }
                    metadateTemplates.sort { $0.name.withoutEmoji() < $1.name.withoutEmoji() }
                    self.metadateTemplates = metadateTemplates
                }
            }
        }
    }
    
    func save() {
        let updatedStat = Stat(
            id: statId,
            exerciseTemplateId: exerciseTemplateId,
            metadateTemplateId: metadateTemplateId,
            aggregation: aggregation,
            created: created,
            edited: Date().timeIntervalSince1970
        )
        
        statRef.setData(updatedStat.asDictionary())
        
        exerciseTemplateIdInit = exerciseTemplateId
        metadateTemplateIdInit = metadateTemplateId
        aggregationInit = aggregation
    }
    
    func exerciseTemplateIds(exerciseTemplates: [ExerciseTemplate]) -> [String] {
        return exerciseTemplates.map { $0.id }
    }
    
    func exerciseTemplateNames(exerciseTemplates: [ExerciseTemplate]) -> [String] {
        return exerciseTemplates.map { $0.name }
    }
    
    func id2exerciseTemplate(id: String) -> ExerciseTemplate {
        for exerciseTemplate in exerciseTemplates {
            if exerciseTemplate.id == id {
                return exerciseTemplate
            }
        }
        return ExerciseTemplate(id: "", name: "", category: "", metadateTemplateIds: [], created: 0, edited: 0)
    }
    
    func metadateTemplateIds(metadateTemplates: [MetadateTemplate]) -> [String] {
        return metadateTemplates.map { $0.id }
    }
    
    func exerciseTemplateNames(metadateTemplates: [MetadateTemplate]) -> [String] {
        return metadateTemplates.map { $0.name }
    }
    
    func id2metadateTemplate(id: String) -> MetadateTemplate {
        for metadateTemplate in metadateTemplates {
            if metadateTemplate.id == id {
                return metadateTemplate
            }
        }
        return MetadateTemplate(id: "", name: "", unit: "", elementsCount: 0, created: 0, edited: 0)
    }
    
    var dataIsInit: Bool {
        guard exerciseTemplateId == exerciseTemplateIdInit else {
            return false
        }
        guard metadateTemplateId == metadateTemplateIdInit else {
            return false
        }
        guard aggregation == aggregationInit else {
            return false
        }
        return true
    }
    
    var background: Color {
        if !dataIsInit {
            return .blue
        } else {
            return .gray
        }
    }
    
    func updateSamples() {
        deleteSamples()
        loadSamples()
    }
    
    func deleteSamples() {
        statRef.collection("samples").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    for data in snapshot.documents {
                        let sampleId = data["id"] as? String ?? ""
                        let sampleRef = self.statRef
                            .collection("samples")
                            .document(sampleId)
                        
                        sampleRef.delete()
                    }
                }
            }
        }
    }
    
    func loadSamples() {
        userRef.collection("workouts").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    for data in snapshot.documents {
                        let workoutId = data["id"] as? String ?? ""
                        let workoutDate = data["time"] as? TimeInterval ?? Date().timeIntervalSince1970
                        
                        let workoutRef = self.userRef
                            .collection("workouts")
                            .document(workoutId)
                        
                        self.loadSamplesInExercises(workoutRef: workoutRef, workoutDate: workoutDate)
                    }
                }
            }
        }
    }
    
    func loadSamplesInExercises(workoutRef: DocumentReference, workoutDate: TimeInterval) {
        workoutRef.collection("exercises").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    for data in snapshot.documents {
                        let exerciseId = data["id"] as? String ?? ""
                        let exerciseName = data["name"] as? String ?? ""
                        
                        let exerciseRef = workoutRef
                            .collection("exercises")
                            .document(exerciseId)
                        
                        if exerciseName == self.id2exerciseTemplate(id: self.exerciseTemplateId).name {
                            self.loadSamplesInMetadates(exerciseRef: exerciseRef, workoutDate: workoutDate)
                        }
                    }
                }
            }
        }
    }
    
    func loadSamplesInMetadates(exerciseRef: DocumentReference, workoutDate: TimeInterval) {
        exerciseRef.collection("metadata").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    for data in snapshot.documents {
                        let metadateId = data["id"] as? String ?? ""
                        let metadateName = data["name"] as? String ?? ""
                        
                        let metadateRef = exerciseRef
                            .collection("metadata")
                            .document(metadateId)
                        
                        if metadateName == self.id2metadateTemplate(id: self.metadateTemplateId).name {
                            self.loadSamplesInElements(metadateRef: metadateRef, workoutDate: workoutDate)
                        }
                    }
                }
            }
        }
    }
    
    func loadSamplesInElements(metadateRef: DocumentReference, workoutDate: TimeInterval) {
        metadateRef.collection("elements").getDocuments { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    let contents = snapshot.documents
                        .map { data in data["content"] as? String ?? ""}
                        .filter { $0 != "" }
                        .map { Double($0) ?? 0 }
                    
                    var content = 0.0
                    if self.aggregation == "max" {
                        content = contents.max() ?? 0.0
                    }
                    if self.aggregation == "min" {
                        content = contents.min() ?? 0.0
                    }
                    if self.aggregation == "sum" {
                        content = contents.sum()
                    }
                    if self.aggregation == "mean" {
                        content = contents.mean()
                    }
                    
                    let newSampleId = UUID().uuidString
                    let newSample = Sample(
                        id: newSampleId,
                        date: workoutDate,
                        content: content
                    )
                    
                    let sampleRef = self.statRef
                        .collection("samples")
                        .document(newSampleId)
                    
                    sampleRef.setData(newSample.asDictionary())
                }
            }
        }
    }
    
    var exerciseTemplateIds: [String] {
        exerciseTemplates.map { $0.id }
    }

    var metadateTemplateIds: [String] {
        metadateTemplates.map { $0.id }
    }
}
