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
            Form {
                HStack {
                    TextField("Name", text: $viewModel.name)
                    Divider()
                    TextField("Unit", text: $viewModel.unit)
                        .autocorrectionDisabled()
                        .autocapitalization(/*@START_MENU_TOKEN@*/.none/*@END_MENU_TOKEN@*/)
                }
                
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
                
                CLButton(title: "Save", background: viewModel.background) {
                    if viewModel.canSave && !viewModel.dataIsInit {
                        viewModel.save(
                            userId: userId
                        )
                        self.presentationMode.wrappedValue.dismiss()
                    } else {
                        if !viewModel.canSave {
                            viewModel.alertTitle = "Error"
                            viewModel.alertMessage = "Please fill in the name field!"
                        }
                        if viewModel.dataIsInit {
                            viewModel.alertTitle = "Warning"
                            viewModel.alertMessage = "Data was not changed!"
                        }
                        viewModel.showAlert = true
                    }
                }
                .padding()
            }
            .alert(isPresented: $viewModel.showAlert) {
                Alert(
                    title: Text(viewModel.alertTitle),
                    message: Text(viewModel.alertMessage)
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
