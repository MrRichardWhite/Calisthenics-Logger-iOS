//
//  EditMetadateTemplateView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestoreSwift
import SwiftUI

struct EditMetadateTemplateView: View {
    @StateObject var viewModel: EditMetadateTemplateViewViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    private let userId: String
    private let metadateTemplateId: String

    init(userId: String, metadateTemplateId: String) {
        self.userId = userId
        self.metadateTemplateId = metadateTemplateId
        self._viewModel = StateObject(
            wrappedValue: EditMetadateTemplateViewViewModel(
                userId: userId,
                metadateTemplateId: metadateTemplateId
            )
        )
    }
    
    var body: some View {
        VStack {
//            Text("Edit Metadate Template")
//                .font(.system(size: 32))
//                .bold()
//                .padding(.top)
            
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
                CLButton(title: "Save", background: .blue) {
                    if viewModel.canSave {
                        viewModel.save(
                            userId: userId
                        )
                    } else {
                        viewModel.showAlert = true
                    }
                    self.presentationMode.wrappedValue.dismiss()
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
    EditMetadateTemplateView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        metadateTemplateId: "356A799F-C391-4621-832F-5B8E449380D2"
    )
}
