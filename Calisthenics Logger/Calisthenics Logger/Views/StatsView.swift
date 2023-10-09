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
    @FirestoreQuery var stats: [Stat]
    
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        
        self._exerciseTemplates = FirestoreQuery(
            collectionPath: "users/\(userId)/exerciseTemplates"
        )
        self._metadateTemplates = FirestoreQuery(
            collectionPath: "users/\(userId)/metadateTemplates"
        )
        self._stats = FirestoreQuery(
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
                List(stats) { stat in
                    NavigationLink(
                        destination: StatView(
                            userId: userId,
                            statId: stat.id
                        )
                    ) {
                        VStack(alignment: .leading) {
                            let exerciseTemplateName = viewModel.id2name(
                                exerciseTemplates: exerciseTemplates,
                                id: stat.exerciseTemplateId
                            )
                            Text("\(exerciseTemplateName)")
                                .bold()
                                .padding(.bottom, 5)
                            
                            let metadateTemplateName = viewModel.id2name(
                                metadateTemplates: metadateTemplates,
                                id: stat.metadateTemplateId
                            )
                            Text("\(metadateTemplateName)")
                                .foregroundColor(Color(.secondaryLabel))
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
            .navigationTitle("Stats")
            .toolbar {
                Button {
                    viewModel.showingNewStatView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showingNewStatView){
                NewStatView(
                    userId: userId,
                    newStatPresented: $viewModel.showingNewStatView
                )
            }
        }
    }
}

#Preview {
    StatsView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1"
    )
}
