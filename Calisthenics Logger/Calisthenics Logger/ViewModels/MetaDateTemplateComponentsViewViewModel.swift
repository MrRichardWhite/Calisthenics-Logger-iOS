//
//  MetaDateTemplateComponentsViewViewModel.swift
//  Calisthenics Logger
//
//  Created by Richard Weiss on 30.09.23.
//

import FirebaseFirestore
import Foundation

class MetaDateTemplateComponentsViewViewModel: ObservableObject {
    private let userId: String
    private let metadateTemplateId: String
    
    init(userId: String, metadateTemplateId: String) {
        self.userId = userId
        self.metadateTemplateId = metadateTemplateId
    }
    
    func delete() {
        
    }
}
