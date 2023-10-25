//
//  StatsView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 27.09.23.
//

import FirebaseFirestoreSwift
import SwiftUI
import Charts

struct StatsView: View {
    @StateObject var viewModel: StatsViewViewModel
    @FirestoreQuery var exerciseTemplates: [ExerciseTemplate]
    @FirestoreQuery var metadateTemplates: [MetadateTemplate]
    @FirestoreQuery var statsQuery: [Stat]
    
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        
        self._exerciseTemplates = FirestoreQuery(
            collectionPath: "users/\(userId)/exerciseTemplates"
        )
        self._metadateTemplates = FirestoreQuery(
            collectionPath: "users/\(userId)/metadateTemplates"
        )
        self._statsQuery = FirestoreQuery(
            collectionPath: "users/\(userId)/stats"
        )
        self._viewModel = StateObject(
            wrappedValue: StatsViewViewModel(
                userId: userId
            )
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                let dict = Dictionary(grouping: stats) {
                    viewModel.id2exerciseTemplateCategory(
                        exerciseTemplates: exerciseTemplates,
                        id: $0.exerciseTemplateId)
                }
                let categories = dict.map { $0.key }.sorted()
                
                Form {
                    ForEach(categories, id: \.self) { category in
                        
                        let stats = dict[category] ?? []
                        
                        Section(
                            header: Text(category)
                                .font(.title2)
                                .padding()
                        ) {
                            List(stats) { stat in
                                NavigationLink(
                                    destination: StatView(
                                        userId: userId,
                                        statId: stat.id,
                                        reloadSamples: $viewModel.reloadSamples
                                    )
                                ) {
                                    VStack(alignment: .leading) {
                                        if let exerciseTemplate = viewModel.id2exerciseTemplate(
                                            exerciseTemplates: exerciseTemplates,
                                            id: stat.exerciseTemplateId
                                        ) {
                                            Text("\(exerciseTemplate.name)")
                                                .bold()
                                                .padding(.bottom, 5)
                                        }
                                        
                                        if let metadateTemplate = viewModel.id2metadateTemplate(
                                            metadateTemplates: metadateTemplates,
                                            id: stat.metadateTemplateId
                                        ) {
                                            Text("\(metadateTemplate.name)")
                                                .foregroundColor(Color(.secondaryLabel))
                                        }
                                        
                                        ChartView(
                                            userId: userId,
                                            statId: stat.id,
                                            lite: true,
                                            reloadSamples: $viewModel.reloadSamples
                                        )
                                    }
                                }
                                
                                .swipeActions {
                                    Button {
                                        viewModel.delete(statId: stat.id)
                                    } label: {
                                        Image(systemName: "trash")
                                            .tint(Color.red)
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .navigationTitle("Stats")
            .toolbar {
                HStack {
                    Button {
                        viewModel.showingNewStatView = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingNewStatView){
                NewStatView(
                    userId: userId,
                    reloadSamples: $viewModel.reloadSamples,
                    newStatPresented: $viewModel.showingNewStatView
                )
            }
        }
    }
    
    var stats: [Stat] {
        var statsSorted: [Stat] = statsQuery
        statsSorted.sort {
            guard let exerciseTemplate0 = viewModel.id2exerciseTemplate(exerciseTemplates: exerciseTemplates, id: $0.exerciseTemplateId) else {
                return true
            }
            guard let metadateTemplate0 = viewModel.id2metadateTemplate(metadateTemplates: metadateTemplates, id: $0.metadateTemplateId) else {
                return true
            }
            
            guard let exerciseTemplate1 = viewModel.id2exerciseTemplate(exerciseTemplates: exerciseTemplates, id: $1.exerciseTemplateId) else {
                return true
            }
            guard let metadateTemplate1 = viewModel.id2metadateTemplate(metadateTemplates: metadateTemplates, id: $1.metadateTemplateId) else {
                return true
            }
            
            return (
                exerciseTemplate0.name.withoutEmoji(),
                metadateTemplate0.name.withoutEmoji()
            )
            <
            (
                exerciseTemplate1.name.withoutEmoji(),
                metadateTemplate1.name.withoutEmoji()
            )
        }
        return statsSorted
    }
}

#Preview {
    StatsView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1"
    )
}
