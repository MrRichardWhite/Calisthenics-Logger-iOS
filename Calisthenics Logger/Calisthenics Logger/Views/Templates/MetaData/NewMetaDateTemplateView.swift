//
//  NewMetaDateTemplateView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import SwiftUI

struct NewMetaDateTemplateView: View {
    @StateObject var viewModel = NewMetaDateTemplateViewViewModel()
    @Binding var newMetaDateTemplatePresented: Bool
    
    let userId: String
    
    var body: some View {
        VStack {
            Text("New MetaDate Template")
                .font(.system(size: 32))
                .bold()
                .padding(.top)
            
            Form {
                // Name
                TextField("Name", text: $viewModel.name)
                
                // Unit
                TextField("Unit", text: $viewModel.unit)
                
                // Number of Elements

                Stepper(
                    "Number of Elements: \(Int(viewModel.elementsCount))",
                    value: $viewModel.elementsCount,
                    in: 1...69,
                    step: 1
                )

                // Button
                CLButton(title: "Save", background: .pink) {
                    if viewModel.canSave {
                        viewModel.save(
                            userId: userId
                        )
                        newMetaDateTemplatePresented = false
                    } else {
                        viewModel.showAlert = true
                    }
                }
                .padding()
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text("Please fill in the name field!")
                )
            }
        }
    }
}

#Preview {
    NewMetaDateTemplateView(
        newMetaDateTemplatePresented: Binding(
            get: { return true },
            set: { _ in }
        ),
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1"
    )
}
