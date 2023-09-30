//
//  MetaDateTemplateComponentsView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestoreSwift
import SwiftUI

struct MetaDateTemplateComponentsView: View {
    @StateObject var viewModel: MetaDateTemplateComponentsViewViewModel
    
    private let userId: String
    private let metadateTemplateId: String

    init(userId: String, metadateTemplateId: String) {
        self.userId = userId
        self.metadateTemplateId = metadateTemplateId
        self._viewModel = StateObject(
            wrappedValue: MetaDateTemplateComponentsViewViewModel(
                userId: userId,
                metadateTemplateId: metadateTemplateId
            )
        )
    }
    
    var body: some View {
        Text("Hello World!")
    }
}

#Preview {
    MetaDateTemplateComponentsView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1",
        metadateTemplateId: ""
    )
}
