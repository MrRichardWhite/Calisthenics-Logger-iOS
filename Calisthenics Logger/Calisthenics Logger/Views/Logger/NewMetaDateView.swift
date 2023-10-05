//
//  NewMetadateView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 29.09.23.
//

import SwiftUI

struct NewMetadateView: View {
    @StateObject var viewModel = NewMetadateViewViewModel()
    @Binding var newMetadatePresented: Bool
    
    let userId: String
    let workoutId: String
    let exerciseId: String
    
    let templates = ["", "Reps", "Time"]

    var body: some View {
        VStack {
            Text("New Metadate")
                .font(.system(size: 32))
                .bold()
                .padding(.top)
            
            Form {
                // Template
                Picker("Template", selection: $viewModel.template) {
                    ForEach(templates, id: \.self) {
                        Text($0)
                    }
                }
                
                // Button
                CLButton(title: "Add", background: .green) {
                    viewModel.save(
                        userId: userId,
                        workoutId: workoutId,
                        exericseId: exerciseId
                    )
                    newMetadatePresented = false
                }
                .padding()
            }
        }
    }
}

#Preview {
    NewMetadateView(
        newMetadatePresented: Binding(
            get: { return true },
            set: { _ in }
        ),
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        workoutId: "EC44C268-3D9F-4D11-BEA0-FCFD2745B354",
        exerciseId: "007F5FDA-6573-4B55-847E-9E3E5D88B8E1"
    )
}
