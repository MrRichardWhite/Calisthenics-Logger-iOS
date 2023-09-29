//
//  NewMetaDateView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 29.09.23.
//

import SwiftUI

struct NewMetaDateView: View {
    @StateObject var viewModel = NewMetaDateViewViewModel()
    @Binding var newMetaDatePresented: Bool
    let workoutId: String
    let exerciseId: String
    
    let templates = ["", "Reps", "Time"]

    var body: some View {
        VStack {
            Text("New MetaDate")
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
                CLButton(title: "Save", background: .pink) {
                    viewModel.save(
                        workoutId: workoutId,
                        exericseId: exerciseId
                    )
                    newMetaDatePresented = false
                }
                .padding()
            }
        }
    }
}

#Preview {
    NewMetaDateView(
        newMetaDatePresented: Binding(
            get: {
                return true
            },
            set: {_ in
        
            }
        ),
        workoutId: "EC44C268-3D9F-4D11-BEA0-FCFD2745B354",
        exerciseId: "007F5FDA-6573-4B55-847E-9E3E5D88B8E1"
    )
}
