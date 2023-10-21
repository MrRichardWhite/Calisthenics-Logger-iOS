//
//  SampleLoader.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 21.10.23.
//

import FirebaseFirestore
import Foundation

class sampleLoader {
    private let exerciseTemplates: [ExerciseTemplate]
    private let metadateTemplates: [MetadateTemplate]
    
    private let stat: Stat
    private let filters: [Filter]
    
    private let userRef: DocumentReference
    private let statRef: DocumentReference
    
    init(
        exerciseTemplates: [ExerciseTemplate], metadateTemplates: [MetadateTemplate],
        stat: Stat, filters: [Filter],
        userRef: DocumentReference, statRef: DocumentReference
    ) {
        self.exerciseTemplates = exerciseTemplates
        self.metadateTemplates = metadateTemplates
        
        self.stat = stat
        self.filters = filters
        
        self.userRef = userRef
        self.statRef = statRef
    }
    
    func id2exerciseTemplate(id: String) -> ExerciseTemplate? {
        for exerciseTemplate in exerciseTemplates {
            if exerciseTemplate.id == id {
                return exerciseTemplate
            }
        }
        return nil
    }
    
    func id2metadateTemplate(id: String) -> MetadateTemplate? {
        for metadateTemplate in metadateTemplates {
            if metadateTemplate.id == id {
                return metadateTemplate
            }
        }
        return nil
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
        guard let exerciseTemplate = self.id2exerciseTemplate(id: self.stat.exerciseTemplateId) else {
            return false
        }
        guard exerciseName == exerciseTemplate.name else {
            return false
        }
        
        if filters.count == 0 {
            return true
        }
        
        let d = await self.getMetadateElementContentsDict(exerciseRef: exerciseRef)
        for (metadateName, metadateElementContents) in d {
            for f in filters {
                guard f.metadateTemplateId != "", f.relation != "", f.bound != "" else {
                    continue
                }
                
                guard let metadateTemplate = self.id2metadateTemplate(id: f.metadateTemplateId) else {
                    continue
                }
                guard metadateName == metadateTemplate.name else {
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
        guard let metadateTemplate = self.id2metadateTemplate(id: self.stat.metadateTemplateId) else {
            return false
        }
        guard metadateName == metadateTemplate.name else {
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
            
            let sampleRef = self.statRef.collection("samples").document(newSampleId)
            try await sampleRef.setData(newSample.asDictionary())
        }
        catch {}
    }
}
