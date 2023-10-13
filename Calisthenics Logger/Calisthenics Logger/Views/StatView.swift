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
            Form {
                Section {
                    Picker("Exercise", selection: $viewModel.exerciseTemplateId) {
                        ForEach(viewModel.exerciseTemplateIds, id: \.self) { exerciseTemplateId in
                            Text(viewModel.id2exerciseTemplate(id: exerciseTemplateId).name)
                        }
                    }
                    
                    Picker("Metdate", selection: $viewModel.metadateTemplateId) {
                        ForEach(viewModel.metadateTemplateIds, id: \.self) { exerciseTemplateId in
                            Text(viewModel.id2metadateTemplate(id: exerciseTemplateId).name)
                        }
                    }
                    
                    Picker("Aggregation", selection: $viewModel.aggregation) {
                        ForEach(aggregations, id: \.self) { aggregation in
                            Text(aggregation)
                        }
                    }
                    
                    CLButton(title: "Save", background: viewModel.background) {
                        if !viewModel.dataIsInit {
                            viewModel.save()
                            viewModel.updateSamples()
                        } else {
                            viewModel.alertTitle = "Warning"
                            viewModel.alertMessage = "Data was not changed!"
                            viewModel.showAlert = true
                        }
                    }
                    .padding()
                }
                
                Section {
                    NavigationLink(
                        destination: filtersView(statId: statId)
                    ) {
                        VStack(alignment: .leading) {
                            Text("Filters")
                        }
                    }
                }
                
                Section {
                    NavigationLink(
                        destination: ChartView(userId: userId, statId: statId)
                    ) {
                        VStack(alignment: .leading) {
                            Text("Chart")
                        }
                    }
                }
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text(viewModel.alertTitle),
                    message: Text(viewModel.alertMessage)
                )
            }
            .navigationTitle("Stat")
        }
    }
    
    @ViewBuilder
    func filtersView(statId: String) -> some View {
        Text("Hello World!")
    }
}

#Preview {
    StatView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        statId: "D5E5E158-856A-45DD-828A-0AB06CD533E9"
    )
}
