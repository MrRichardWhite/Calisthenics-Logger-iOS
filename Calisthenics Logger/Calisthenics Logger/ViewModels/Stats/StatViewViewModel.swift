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
        stat.unit = id2metadateTemplate(id: stat.metadateTemplateId).unit
        stat.edited = Date().timeIntervalSince1970
        statRef.setData(stat.asDictionary())
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
    
    func id2exerciseTemplate(id: String) -> ExerciseTemplate {
        for exerciseTemplate in exerciseTemplates {
            if exerciseTemplate.id == id {
                return exerciseTemplate
            }
        }
        return ExerciseTemplate(id: "", name: "", category: "", metadateTemplateIds: [], created: 0, edited: 0)
    }
    
    var metadateTemplateIds: [String] {
        return metadateTemplates.map { $0.id }
    }
    
    var metadateTemplateNames: [String] {
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
    
    func updateSamples() async {
        await deleteSamples()
        await updateSamplesInWorkouts()
    }
    
    func deleteSamples() async {
        do {
            let collectionSnapshot = try await statRef.collection("samples").getDocuments()
            for documentSnapshot in collectionSnapshot.documents {
                let data = documentSnapshot.data()
                
                let sampleId = data["id"] as? String ?? ""
                
                let sampleRef = self.statRef.collection("samples").document(sampleId)
                
                try await sampleRef.delete()
            }
        }
        catch {}
    }
    
    func updateSamplesInWorkouts() async {
        do {
            let collectionSnapshot = try await userRef.collection("workouts").getDocuments()
            for documentSnapshot in collectionSnapshot.documents {
                let data = documentSnapshot.data()
                
                let workoutId = data["id"] as? String ?? ""
                let workoutDate = data["time"] as? TimeInterval ?? Date().timeIntervalSince1970
                
                let workoutRef = self.userRef.collection("workouts").document(workoutId)
                
                await self.updateSamplesInExercises(workoutRef: workoutRef, workoutDate: workoutDate)
            }
        }
        catch {}
    }
    
    func updateSamplesInExercises(workoutRef: DocumentReference, workoutDate: TimeInterval) async {
        do {
            let collectionSnapshot = try await workoutRef.collection("exercises").getDocuments()
            for documentSnapshot in collectionSnapshot.documents {
                let data = documentSnapshot.data()
                
                let exerciseId = data["id"] as? String ?? ""
                let exerciseName = data["name"] as? String ?? ""
                
                let exerciseRef = workoutRef.collection("exercises").document(exerciseId)
                
                guard await self.willUpdateSamplesInMetadates(exerciseRef: exerciseRef, exerciseName: exerciseName) else {
                    continue
                }
                
                await self.updateSamplesInMetadata(exerciseRef: exerciseRef, workoutDate: workoutDate)
            }
        }
        catch {}
    }
    
    func willUpdateSamplesInMetadates(exerciseRef: DocumentReference, exerciseName: String) async -> Bool {
        guard exerciseName == self.id2exerciseTemplate(id: self.stat.exerciseTemplateId).name else {
            return false
        }
        
        let d = await self.getMetadateElementContentsDict(exerciseRef: exerciseRef)
        for (metadateName, metadateElementContents) in d {
            for f in filters {
                guard f.metadateTemplateId != "", f.relation != "", f.bound != "" else {
                    continue
                }
                
                guard metadateName == self.id2metadateTemplate(id: f.metadateTemplateId).name else {
                    continue
                }
                
                for content in metadateElementContents {
                    var bools: [Bool] = [content == f.bound, content != f.bound]
                    if let content_d = Double(content),
                       let f_bound_d = Double(f.bound) {
                        bools += [
                            content_d <= f_bound_d, content_d < f_bound_d,
                            content_d >= f_bound_d, content_d > f_bound_d
                        ]
                    }
                    
                    for (relation, bool) in zip(relations, bools) {
                        if f.relation == relation {
                            guard bool else {
                                return false
                            }
                        }
                    }
                }
            }
        }
        
        return true
    }
    
    func getMetadateElementContentsDict(exerciseRef: DocumentReference) async -> [String: [String]] {
        var d: [String: [String]] = [:]
        
        do {
            let collectionSnapshot = try await exerciseRef.collection("metadata").getDocuments()
            for documentSnapshot in collectionSnapshot.documents {
                let data = documentSnapshot.data()
                
                let metadateId = data["id"] as? String ?? ""
                let metadateName = data["name"] as? String ?? ""

                let metadateRef = exerciseRef.collection("metadata").document(metadateId)
                
                d[metadateName] = await self.getMetadateElementContentsList(metadateRef: metadateRef)
            }
        }
        catch {}
        
        return d
    }
    
    func getMetadateElementContentsList(metadateRef: DocumentReference) async -> [String] {
        do {
            let collectionSnapshot = try await metadateRef.collection("elements").getDocuments()
            let l = collectionSnapshot.documents.map { documentSnapshot in
                let data = documentSnapshot.data()
                return data["content"] as? String ?? ""
            }
            return l
        }
        catch {}
        return []
    }
    
    func updateSamplesInMetadata(exerciseRef: DocumentReference, workoutDate: TimeInterval) async {
        do {
            let collectionSnapshot = try await exerciseRef.collection("metadata").getDocuments()
            for documentSnapshot in collectionSnapshot.documents {
                let data = documentSnapshot.data()
                
                let metadateId = data["id"] as? String ?? ""
                let metadateName = data["name"] as? String ?? ""
                
                let metadateRef = exerciseRef.collection("metadata").document(metadateId)
                
                guard willUpdateSamplesInElements(metadateName: metadateName) else {
                    continue
                }
                
                await self.updateSamplesInElements(metadateRef: metadateRef, workoutDate: workoutDate)
            }
        }
        catch {}
    }
    
    func willUpdateSamplesInElements(metadateName: String) -> Bool {
        guard metadateName == self.id2metadateTemplate(id: self.stat.metadateTemplateId).name else {
            return false
        }
        return true
    }
    
    func updateSamplesInElements(metadateRef: DocumentReference, workoutDate: TimeInterval) async {
        do {
            let collectionSnapshot = try await metadateRef.collection("elements").getDocuments()
            
            let contents = collectionSnapshot.documents
                .map { data in data["content"] as? String ?? ""}
                .filter { $0 != "" }
                .map { Double($0) ?? 0 }
            
            var content: Double
            switch self.stat.aggregation {
                case "max":  content = contents.max() ?? 0.0
                case "min":  content = contents.min() ?? 0.0
                case "sum":  content = contents.sum() ?? 0.0
                case "mean": content = contents.mean() ?? 0.0
                default: content = 0.0
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
            
            try await sampleRef.setData(newSample.asDictionary())
        }
        catch {}
    }
}
