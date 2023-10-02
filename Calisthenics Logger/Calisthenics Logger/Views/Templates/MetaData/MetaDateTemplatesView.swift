//
//  MetadateTemplatesView.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestoreSwift
import SwiftUI

struct MetadateTemplatesView: View {
    @StateObject var viewModel: MetadateTemplatesViewViewModel
    @FirestoreQuery var metadateTemplates: [MetadateTemplate]
    
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        self._metadateTemplates = FirestoreQuery(
            collectionPath: "users/\(userId)/metadateTemplates"
        )
        self._viewModel = StateObject(
            wrappedValue: MetadateTemplatesViewViewModel(userId: userId)
        )
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                List(metadateTemplates) { metadateTemplate in
                    NavigationLink(
                        destination: EditMetadateTemplateView(
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
                    viewModel.showingNewMetadateTemplateView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            .sheet(isPresented: $viewModel.showingNewMetadateTemplateView){
                NewMetadateTemplateView(
                    newMetadateTemplatePresented: $viewModel.showingNewMetadateTemplateView,
                    userId: userId
                )
            }
        }
    }
}

#Preview {
    MetadateTemplatesView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1"
    )
}
