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
    @FirestoreQuery var metadateTemplatesQuery: [MetadateTemplate]
    
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
        self._metadateTemplatesQuery = FirestoreQuery(
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
                    userId: userId,
                    newMetadateTemplatePresented: $viewModel.showingNewMetadateTemplateView
                )
            }
        }
    }
    
    var metadateTemplates: [MetadateTemplate] {
        var metadateTemplatesSorted: [MetadateTemplate] = metadateTemplatesQuery
        metadateTemplatesSorted.sort { $0.name.withoutEmoji() < $1.name.withoutEmoji() }
        return metadateTemplatesSorted
    }
}

#Preview {
    MetadateTemplatesView(
        userId: "kHldraThHdSyYWPAEeiu7Wkhm1y1"
    )
}
