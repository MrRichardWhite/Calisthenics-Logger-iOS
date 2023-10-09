//
//  NewStatView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 09.10.23.
//

import SwiftUI

struct NewStatView: View {
    @StateObject var viewModel: NewStatViewViewModel
    @Binding var newStatPresented: Bool
    
    let userId: String
    
    init(userId: String, newStatPresented: Binding<Bool>) {
        self.userId = userId
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
                        let text = viewModel.id2name(
                            exerciseTemplateId: exerciseTemplateId
                        )
                        Text(text)
                    }
                }
                
                Picker("Metadate", selection: $viewModel.pickedMetadateTemplateId) {
                    ForEach(viewModel.metadateTemplateIds, id: \.self) { metadateTemplateId in
                        let text = viewModel.id2name(
                            metadateTemplateId: metadateTemplateId
                        )
                        Text(text)
                    }
                }
                
                CLButton(title: "Add", background: .green) {
                    viewModel.save()
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
        newStatPresented: Binding(
            get: { return true },
            set: { _ in }
        )
    )
}
