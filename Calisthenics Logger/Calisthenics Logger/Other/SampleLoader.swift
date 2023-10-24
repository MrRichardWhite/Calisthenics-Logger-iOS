//
//  SampleLoader.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 21.10.23.
//

import FirebaseFirestore
import Foundation

class sampleLoader {
    @Published var message = ""
    
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
                
                guard let exerciseTemplate = self.id2exerciseTemplate(id: self.stat.exerciseTemplateId) else {
                    continue
                }
                guard exerciseName == exerciseTemplate.name else {
                    continue
                }
                
                let metadateElementsDict = await self.getMetadateElementsDict(exerciseRef: exerciseRef)
                guard let metadateTemplate = self.id2metadateTemplate(id: self.stat.metadateTemplateId) else {
                    continue
                }
                guard let elements = metadateElementsDict[metadateTemplate.name] else {
                    continue
                }
                let filterMask = await getFilterMask(
                    exerciseRef: exerciseRef,
                    elementsCount: elements.count,
                    workoutDate: workoutDate,
                    exerciseName: exerciseName,
                    metadateElementsDict: metadateElementsDict
                )
                
                await self.updateSamplesInMetadata(
                    exerciseRef: exerciseRef,
                    workoutDate: workoutDate,
                    filterMask: filterMask,
                    metadateElementsDict: metadateElementsDict
                )
                break
            }
        }
        catch {}
    }
    
    func getFilterMask(
        exerciseRef: DocumentReference,
        elementsCount: Int,
        workoutDate: TimeInterval,
        exerciseName: String,
        metadateElementsDict: [String: [Element]]
    ) async -> [Bool] {
        
        var mask = [Bool](repeating: true, count: elementsCount)
        
        if filters.count == 0 {
            return mask
        }
        
        for (metadateName, metadateElements) in metadateElementsDict {
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
                
                if metadateElements.count == 1 {
                    let element = metadateElements[0]
                    if !elementOk(f: f, element: element) {
                        mask = mask.map { _ in false }
                    }
                } else {
                    guard metadateElements.count == elementsCount else {
                        let date = Date(timeIntervalSince1970: workoutDate)
                            .formatted(date: .abbreviated, time: .shortened)
                        
                        var targetMetadateName = ""
                        if let metadateTemplate = self.id2metadateTemplate(id: self.stat.metadateTemplateId) {
                            targetMetadateName = metadateTemplate.name
                        }
                        
                        message = """
                            Workout: \(date)
                            Exercise: \(exerciseName)
                            Target Metadate \(targetMetadateName): \(elementsCount) elements
                            Metadate \(metadateName): \(metadateElements.count) elements
                        """
                        print(message)
                        
                        continue
                    }
                    
                    for (i, element) in metadateElements.enumerated() {
                        if !elementOk(f: f, element: element) {
                            mask[i] = false
                        }
                    }
                }
            }
        }
        
        return mask
    }
    
    func getMetadateElementsDict(exerciseRef: DocumentReference) async -> [String: [Element]] {
        var d: [String: [Element]] = [:]
        
        do {
            let collectionSnapshot = try await exerciseRef.collection("metadata").getDocuments()
            for documentSnapshot in collectionSnapshot.documents {
                let data = documentSnapshot.data()
                
                let metadateId = data["id"] as? String ?? ""
                let metadateName = data["name"] as? String ?? ""
                
                let metadateRef = exerciseRef.collection("metadata").document(metadateId)
                
                d[metadateName] = await self.getMetadateElementsList(metadateRef: metadateRef)
            }
        }
        catch {}
        
        return d
    }
    
    func getMetadateElementsList(metadateRef: DocumentReference) async -> [Element] {
        do {
            let collectionSnapshot = try await metadateRef.collection("elements").getDocuments()
            var l = collectionSnapshot.documents.map { documentSnapshot in
                let data = documentSnapshot.data()
                return Element(
                    id: data["content"] as? String ?? "",
                    content: data["content"] as? String ?? "",
                    created: data["created"] as? TimeInterval ?? Date().timeIntervalSince1970,
                    edited: data["edited"] as? TimeInterval ?? Date().timeIntervalSince1970
                )
            }
            l.sort { $0.created < $1.created }
            return l
        }
        catch {}
        return []
    }
    
    func elementOk(f: Filter, element: Element) -> Bool {
        var bools: [Bool] = [element.content == f.bound, element.content != f.bound]
        if let content = Double(element.content),
           let f_bound = Double(f.bound) {
            bools += [
                content <= f_bound, content < f_bound,
                content >= f_bound, content > f_bound
            ]
        }
        
        for (relation, bool) in zip(relations, bools) {
            if f.relation == relation {
                guard bool else {
                    return false
                }
            }
        }
        
        return true
    }
    
    func updateSamplesInMetadata(
        exerciseRef: DocumentReference,
        workoutDate: TimeInterval,
        filterMask: [Bool],
        metadateElementsDict: [String: [Element]]
    ) async {
        do {
            let collectionSnapshot = try await exerciseRef.collection("metadata").getDocuments()
            for documentSnapshot in collectionSnapshot.documents {
                let data = documentSnapshot.data()
                
                let metadateName = data["name"] as? String ?? ""
                
                guard let metadateTemplate = self.id2metadateTemplate(id: self.stat.metadateTemplateId) else {
                    continue
                }
                guard metadateName == metadateTemplate.name else {
                    continue
                }
                
                guard let metadateElementsList = metadateElementsDict[metadateName] else {
                    continue
                }

                await self.updateSamplesInElements(
                    workoutDate: workoutDate,
                    filterMask: filterMask,
                    metdateElementsList: metadateElementsList
                )
                break
            }
        }
        catch {}
    }
    
    func updateSamplesInElements(
        workoutDate: TimeInterval,
        filterMask: [Bool],
        metdateElementsList: [Element]
    ) async {
        do {
            var data: [Double] = []
            for (element, b) in zip(metdateElementsList, filterMask) {
                if b && element.content != "" {
                    if let date = Double(element.content) {
                        data.append(date)
                    }
                }
            }
            
            guard data.count != 0 else { return }
            
            var content: Double
            switch self.stat.aggregation {
                case "max":  content = data.max() ?? 0.0
                case "min":  content = data.min() ?? 0.0
                case "sum":  content = data.sum() ?? 0.0
                case "mean": content = data.mean() ?? 0.0
                default: content = 0.0
            }
            
            let newSample = Sample(
                id: UUID().uuidString,
                date: workoutDate,
                content: content
            )
            
            let sampleRef = self.statRef.collection("samples").document(newSample.id)
            try await sampleRef.setData(newSample.asDictionary())
        }
        catch {}
    }
}
