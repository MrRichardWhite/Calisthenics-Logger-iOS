//
//  NewMetadateTemplateView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import SwiftUI

struct NewMetadateTemplateView: View {
    @StateObject var viewModel = NewMetadateTemplateViewViewModel()
    @Binding var newMetadateTemplatePresented: Bool
    
    let userId: String
    
    var body: some View {
        VStack {
            Text("New Metadate Template")
                .font(.system(size: 32))
                .bold()
                .padding(.top)
            
            Form {
                // Name
                TextField("name", text: $viewModel.name)
                
                // Unit
                TextField("unit", text: $viewModel.unit)
                    .autocorrectionDisabled()
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                
                // Number of Elements
                var stepperTitle: String {
                    var d = "\(viewModel.elementsCount) element"
                    if viewModel.elementsCount != 1 {
                        d += "s"
                    }
                    return d
                }
                Stepper(
                    stepperTitle,
                    value: $viewModel.elementsCount,
                    in: 1...69,
                    step: 1
                )
                
                // Button
                CLButton(title: "Add", background: .green) {
                    if viewModel.canSave {
                        viewModel.save(
                            userId: userId
                        )
                        newMetadateTemplatePresented = false
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
    NewMetadateTemplateView(
        newMetadateTemplatePresented: Binding(
            get: { return true },
            set: { _ in }
        ),
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1"
    )
}
