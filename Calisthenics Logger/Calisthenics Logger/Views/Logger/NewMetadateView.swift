//
//  NewMetadateView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 29.09.23.
//

import SwiftUI

struct NewMetadateView: View {
    @StateObject var viewModel: NewMetadateViewViewModel
    @Binding var newMetadatePresented: Bool
    @Binding var reloadInExercise: Bool
    
    let userId: String
    let workoutId: String
    let exerciseId: String
    
    init(
        userId: String, workoutId: String, exerciseId: String,
        newMetadatePresented: Binding<Bool>,
        reloadInExercise: Binding<Bool>
    ) {
        self.userId = userId
        self.workoutId = workoutId
        self.exerciseId = exerciseId
        
        self._newMetadatePresented = newMetadatePresented
        self._reloadInExercise = reloadInExercise
        
        self._viewModel = StateObject(
            wrappedValue: NewMetadateViewViewModel(
                userId: userId,
                workoutId: workoutId,
                exerciseId: exerciseId
            )
        )
    }
    
    var body: some View {
        VStack {
            Text("New Metadate")
                .font(.system(size: 32))
                .bold()
                .padding(.top)
            
            Form {
                Picker("Template", selection: $viewModel.pickedMetadateTemplateId) {
                    ForEach(viewModel.metadateTemplateIds, id: \.self) { metadateTemplateId in
                        let text = viewModel.id2name(
                            id: metadateTemplateId
                        )
                        Text(text)
                    }
                }
                
                CLButton(title: "Add", background: .green) {
                    viewModel.save(
                        userId: userId,
                        workoutId: workoutId,
                        exericseId: exerciseId
                    )
                    reloadInExercise = true
                    newMetadatePresented = false
                }
                .padding()
            }
        }
    }
}

#Preview {
    NewMetadateView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        workoutId: "EC44C268-3D9F-4D11-BEA0-FCFD2745B354",
        exerciseId: "007F5FDA-6573-4B55-847E-9E3E5D88B8E1",
        newMetadatePresented: Binding(
            get: { return true },
            set: { _ in }
        ),
        reloadInExercise: Binding(
            get: { return true },
            set: { _ in }
        )
    )
}
