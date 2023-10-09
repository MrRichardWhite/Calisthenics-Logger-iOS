//
//  NewMetadateTemplateView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import SwiftUI

struct NewMetadateTemplateView: View {
    @StateObject var viewModel: NewMetadateTemplateViewViewModel
    @Binding var newMetadateTemplatePresented: Bool
    
    private let userId: String
    
    init(userId: String, newMetadateTemplatePresented: Binding<Bool>) {
        self.userId = userId
        
        self._newMetadateTemplatePresented = newMetadateTemplatePresented
        
        self._viewModel = StateObject(
            wrappedValue: NewMetadateTemplateViewViewModel(
                userId: userId
            )
        )
    }
    
    var body: some View {
        VStack {
            Text("New Metadate Template")
                .font(.system(size: 32))
                .bold()
                .padding(.top)
            
            Form {
                TextField("Name", text: $viewModel.name)

                TextField("Unit", text: $viewModel.unit)
                    .autocorrectionDisabled()
                    .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                
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
                
                CLButton(title: "Add", background: viewModel.background) {
                    if viewModel.canSave {
                        viewModel.save()
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
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        newMetadateTemplatePresented: Binding(
            get: { return true },
            set: { _ in }
        )
    )
}
