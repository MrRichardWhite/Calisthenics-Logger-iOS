//
//  NewStatView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 09.10.23.
//

import FirebaseFirestore
import SwiftUI

struct NewStatView: View {
    @StateObject var viewModel: NewStatViewViewModel
    @Binding var reloadSamples: Int
    @Binding var newStatPresented: Bool
    
    let userId: String
    
    let userRef: DocumentReference
    
    init(userId: String, reloadSamples: Binding<Int>, newStatPresented: Binding<Bool>) {
        self.userId = userId
        self.userRef = Firestore.firestore().collection("users").document(userId)
        
        self._reloadSamples = reloadSamples
        self._newStatPresented = newStatPresented

        self._viewModel = StateObject(
            wrappedValue: NewStatViewViewModel(
                userId: userId
            )
        )
    }

    var body: some View {
        VStack {
            Text("New Stat")
                .font(.system(size: 32))
                .bold()
                .padding(.top)
            
            Form {
                Picker("Exercise", selection: $viewModel.pickedExerciseTemplateId) {
                    ForEach(viewModel.exerciseTemplateIds, id: \.self) { exerciseTemplateId in
                        Text(viewModel.id2name(exerciseTemplateId: exerciseTemplateId))
                    }
                }
                
                Picker("Metadate", selection: $viewModel.pickedMetadateTemplateId) {
                    ForEach(viewModel.metadateTemplateIds, id: \.self) { metadateTemplateId in
                        Text(viewModel.id2name(metadateTemplateId: metadateTemplateId))
                    }
                }
                
                Picker("Aggregation", selection: $viewModel.pickedAggregation) {
                    ForEach(aggregations, id: \.self) { aggregation in
                        Text(aggregation)
                    }
                }
                
                CLAsyncButton(title: "Add", background: .green) {
                    await viewModel.save()
                    reloadSamples += 1
                    newStatPresented = false
                }
                .padding()
            }
        }
    }
}

#Preview {
    NewStatView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        reloadSamples: Binding(
            get: { return 0 },
            set: { _ in }
        ),
        newStatPresented: Binding(
            get: { return true },
            set: { _ in }
        )
    )
}
