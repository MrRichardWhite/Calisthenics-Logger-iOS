//
//  MetaDateTemplatesView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestoreSwift
import SwiftUI

struct MetaDateTemplatesView: View {
    @StateObject var viewModel: MetaDateTemplatesViewViewModel
    @FirestoreQuery var metadateTemplates: [MetaDateTemplate]
    
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        self._metadateTemplates = FirestoreQuery(
            collectionPath: "users/\(userId)/metadateTemplates"
        )
        self._viewModel = StateObject(
            wrappedValue: MetaDateTemplatesViewViewModel(userId: userId)
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List(metadateTemplates) { metadateTemplate in
                    NavigationLink(
                        destination: MetaDateTemplateComponentsView(
                            userId: userId,
                            metadateTemplateId: metadateTemplate.id
                        )
                    ) {
                        Text(metadateTemplate.name)
                    }
                    
                    .swipeActions {
                        Button {
                            // Delete
                            viewModel.delete(metadateTemplateId: metadateTemplate.id)
                        } label: {
                            Image(systemName: "trash")
                                .tint(Color.red)
                        }
                    }
                }
            }
            .toolbar {
                Button {
                    // Action
                    viewModel.showingNewMetaDateTemplateView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showingNewMetaDateTemplateView){
                NewMetaDateTemplateView(
                    newMetaDateTemplatePresented: $viewModel.showingNewMetaDateTemplateView,
                    userId: userId
                )
            }
        }
    }
}

#Preview {
    MetaDateTemplatesView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1"
    )
}
