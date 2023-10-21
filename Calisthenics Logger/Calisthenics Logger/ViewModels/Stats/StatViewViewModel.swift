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
    
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    @Published var showAlert = false
    
    private var statInit = Stat()
    @Published var stat = Stat()
    
    private var filtersInit: [Filter] = []
    @Published var filters: [Filter] = []
    private var filterIdsAdd: [String] = []
    private var filterIdsDelete: [String] = []
    
    @Published var showingNewFilterView = false
    @Published var newFilterMetadateTemplateId = ""
    @Published var newFilterRelation = ""
    @Published var newFilterBound = ""
    
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
        
        loadStat()
        loadExerciseTemplates()
        loadMetadateTemplates()
        loadFilters()

    }
    
    func loadStat() {
        statRef.getDocument { document, error in
            guard let document = document, document.exists else {
                return
            }
            
            let data = document.data()
            let stat = Stat(
                id: self.statId,
                exerciseTemplateId: data?["exerciseTemplateId"] as? String ?? "",
                metadateTemplateId: data?["metadateTemplateId"] as? String ?? "",
                aggregation: data?["aggregation"] as? String ?? "",
                unit: data?["unit"] as? String ?? "",
                created: data?["created"] as? TimeInterval ?? Date().timeIntervalSince1970,
                edited: data?["edited"] as? TimeInterval ?? Date().timeIntervalSince1970
            )
            
            self.statInit = stat
            self.stat = stat
        }
    }
    
    func loadExerciseTemplates() {
        do {
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
    
    func loadFilters() {
        statRef.collection("filters").getDocuments() { snapshot, error in
            if error == nil {
                if let snapshot = snapshot {
                    let filters = snapshot.documents.map { data in
                        Filter(
                            id: data["id"] as? String ?? "",
                            metadateTemplateId: data["metadateTemplateId"] as? String ?? "",
                            relation: data["relation"] as? String ?? "",
                            bound: data["bound"] as? String ?? "",
                            created: data["created"] as? TimeInterval ?? Date().timeIntervalSince1970,
                            edited: data["edited"] as? TimeInterval ?? Date().timeIntervalSince1970
                        )
                    }
                    self.filtersInit = filters
                    self.filters = filters
                }
            }
        }
    }
    
    func addFilter() {
        let newFilter = Filter(
            id: UUID().uuidString,
            metadateTemplateId: newFilterMetadateTemplateId,
            relation: newFilterRelation,
            bound: newFilterBound,
            created: Date().timeIntervalSince1970,
            edited: Date().timeIntervalSince1970
        )
        filters.append(newFilter)
        filterIdsAdd.append(newFilter.id)
    }
    
    func deleteFilter(filterId: String) {
        if let index = filterIdsAdd.firstIndex(where: { $0 == filterId }) {
            filterIdsAdd.remove(at: index)
        } else {
            filterIdsDelete.append(filterId)
        }
        
        if let index = filters.firstIndex(where: { $0.id == filterId }) {
            filters.remove(at: index)
        }
    }
    
    func save() {
        saveStat()
        saveFilters()
    }
    
    func saveStat() {
        if let metadateTemplate = id2metadateTemplate(id: stat.metadateTemplateId) {
            stat.unit = metadateTemplate.unit
        }
        stat.edited = Date().timeIntervalSince1970
        statRef.setData(stat.asDictionary())
        
        statInit = stat
    }
    
    func saveFilters() {
        for filterId in filterIdsDelete {
            let filterRef = statRef.collection("filters").document(filterId)
            filterRef.delete()
        }
        
        for f in filters {
            let filterRef = statRef.collection("filters").document(f.id)
            let g = Filter(
                id: f.id,
                metadateTemplateId: f.metadateTemplateId,
                relation: f.relation,
                bound: f.bound,
                created: f.created,
                edited: Date().timeIntervalSince1970
            )
            
            if filterIdsAdd.contains(f.id) {
                filterRef.setData(g.asDictionary())
            } else {
                filterRef.updateData(g.asDictionary())
            }
        }
        
        filterIdsAdd = []
        filterIdsDelete = []
        
        filtersInit = filters
    }
    
    var dataIsInit: Bool {
        guard stat.exerciseTemplateId == statInit.exerciseTemplateId,
              stat.metadateTemplateId == statInit.metadateTemplateId,
              stat.aggregation == statInit.aggregation else {
            return false
        }
        
        guard filterIdsAdd.count == 0, filterIdsDelete.count == 0 else {
            return false
        }
        
        for f in filters {
            for g in filtersInit {
                if f.id == g.id {
                    guard f.metadateTemplateId == g.metadateTemplateId,
                          f.relation == g.relation,
                          f.bound == g.bound else {
                        return false
                    }
                }
            }
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
    
    var exerciseTemplateIds: [String] {
        return exerciseTemplates.map { $0.id }
    }
    
    var exerciseTemplateNames: [String] {
        return exerciseTemplates.map { $0.name }
    }
    
    func id2exerciseTemplate(id: String) -> ExerciseTemplate? {
        for exerciseTemplate in exerciseTemplates {
            if exerciseTemplate.id == id {
                return exerciseTemplate
            }
        }
        return nil
    }
    
    var metadateTemplateIds: [String] {
        return metadateTemplates.map { $0.id }
    }
    
    var metadateTemplateNames: [String] {
        return metadateTemplates.map { $0.name }
    }
    
    func id2metadateTemplate(id: String) -> MetadateTemplate? {
        for metadateTemplate in metadateTemplates {
            if metadateTemplate.id == id {
                return metadateTemplate
            }
        }
        return nil
    }
}
