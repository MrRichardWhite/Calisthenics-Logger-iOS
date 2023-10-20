//
//  StatView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 08.10.23.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import SwiftUI

struct StatView: View {
    @StateObject var viewModel: StatViewViewModel
    
    @State var samples: [Sample] = []
    
    @State var reloadSamples: Bool = false
    
    @State var saveBG: Color = .gray
    
    private let userId: String
    private let statId: String
    
    private let userRef: DocumentReference
    
    init(userId: String, statId: String) {
        self.userId = userId
        self.statId = statId
        
        self.userRef = Firestore.firestore()
            .collection("users")
            .document(userId)
        
        self._viewModel = StateObject(
            wrappedValue: StatViewViewModel(
                userId: userId,
                statId: statId
            )
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                optionsView
                
                ChartView(
                    userId: userId,
                    statId: statId,
                    chartYAxisLabel: viewModel.stat.unit,
                    reloadSamples: $reloadSamples
                )
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text(viewModel.alertTitle),
                    message: Text(viewModel.alertMessage)
                )
            }
            .navigationTitle("Stat")
            .toolbar {
                AsyncButton {
                    reloadSamples = false
                    await viewModel.updateSamples()
                    reloadSamples = true
                } label: {
                    Image(systemName: "arrow.clockwise")
                }
            }
        }
    }
    
    @ViewBuilder
    var optionsView: some View {
        Form {
            Picker("Exercise", selection: $viewModel.stat.exerciseTemplateId) {
                ForEach(viewModel.exerciseTemplateIds, id: \.self) { exerciseTemplateId in
                    Text(viewModel.id2exerciseTemplate(id: exerciseTemplateId).name)
                }
            }
            
            Picker("Metdate", selection: $viewModel.stat.metadateTemplateId) {
                ForEach(viewModel.metadateTemplateIds, id: \.self) { exerciseTemplateId in
                    Text(viewModel.id2metadateTemplate(id: exerciseTemplateId).name)
                }
            }
            
            Picker("Aggregation", selection: $viewModel.stat.aggregation) {
                ForEach(aggregations, id: \.self) { aggregation in
                    Text(aggregation)
                }
            }
            
            NavigationLink(
                destination: filtersView
            ) {
                Text("Filters")
            }
            
            CLAsyncButton(title: "Save", background: saveBG) {
                if !viewModel.dataIsInit {
                    viewModel.save()
                    saveBG = .gray
                    
                    reloadSamples = false
                    await viewModel.updateSamples()
                    reloadSamples = true
                } else {
                    viewModel.alertTitle = "Warning"
                    viewModel.alertMessage = "Data was not changed!"
                    viewModel.showAlert = true
                }
            }
            .padding()
        }
        .onChange(of: viewModel.dataIsInit) {
            saveBG = viewModel.background
        }
    }
    
    @ViewBuilder
    var filtersView: some View {
        List {
            ForEach($viewModel.filters) { $f in
                Section {
                    VStack {
                        Picker("Metadate", selection: $f.metadateTemplateId) {
                            Text("").tag("")
                            ForEach(viewModel.metadateTemplateIds, id: \.self) { metadateTemplateId in
                                Text(viewModel.id2metadateTemplate(id: metadateTemplateId).name)
                            }
                        }
                        
                        Divider()
                        
                        Picker("Relation", selection: $f.relation) {
                            Text("").tag("")
                            ForEach(relations, id: \.self) { relation in
                                Text(relation)
                            }
                        }
                        
                        Divider()
                        
                        HStack {
                            Text("Bound")
                            TextField("...", text: $f.bound)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(.gray)
                        }
                        .padding(.top, 6)
                        .padding(.bottom, 6)
                    }
                }
                .swipeActions {
                    Button {
                        viewModel.deleteFilter(filterId: $f.id)
                        saveBG = viewModel.background
                    } label: {
                        Image(systemName: "trash")
                            .tint(Color.red)
                    }
                }
            }
        }
        .navigationTitle("Filters")
        .toolbar {
            Button {
                viewModel.showingNewFilterView = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $viewModel.showingNewFilterView){
            newFilterView
        }
    }
    
    @ViewBuilder
    var newFilterView: some View {
        Form {
            Picker("Metadate", selection: $viewModel.newFilterMetadateTemplateId) {
                Text("").tag("")
                ForEach(viewModel.metadateTemplateIds, id: \.self) { exerciseTemplateId in
                    Text(viewModel.id2metadateTemplate(id: exerciseTemplateId).name)
                }
            }
            
            Picker("Relation", selection: $viewModel.newFilterRelation) {
                Text("").tag("")
                ForEach(relations, id: \.self) { relation in
                    Text(relation)
                }
            }
            
            HStack {
                Text("Bound")
                TextField("...", text: $viewModel.newFilterBound)
                    .multilineTextAlignment(.trailing)
                    .foregroundColor(.gray)
            }
            .padding(.top, 6)
            .padding(.bottom, 6)

            CLButton(title: "Add", background: .green) {
                viewModel.addFilter()
                saveBG = viewModel.background
                viewModel.showingNewFilterView = false
            }
            .padding()
        }
    }
}

#Preview {
    StatView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        statId: "D5E5E158-856A-45DD-828A-0AB06CD533E9"
    )
}
