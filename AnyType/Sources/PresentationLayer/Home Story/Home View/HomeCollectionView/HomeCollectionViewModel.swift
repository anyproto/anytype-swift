//
//  HomeCollectionViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 13.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import SwiftUI

enum HomeCollectionViewCellType: Hashable {
    case plus
    case document(HomeCollectionViewDocumentCellModel)
}

class HomeCollectionViewModel: ObservableObject {
    private let documentService = TestDocumentService()
    var documentsHeaders: DocumentsHeaders?
    
    var documentsCell = [HomeCollectionViewCellType]()
    @Published var error: String = ""
    
    init() {
        self.obtainDocuments()
    }
    
    func obtainDocuments() {
        documentService.obtainDocuments { [weak self] result in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let documents):
                strongSelf.documentsHeaders = documents
                processObtainedDocuments(documents: documents)
            case .failure(let error):
                strongSelf.error = error.localizedDescription
            }
        }
    }

}

extension HomeCollectionViewModel {
    
    private func processObtainedDocuments(documents: DocumentsHeaders) {
        for document in documents.headers {
            var documentCellModel = HomeCollectionViewDocumentCellModel(title: document.name)
            documentCellModel.emojiImage = document.icon
            documentsCell.append(.document(documentCellModel))
        }
        documentsCell.append(.plus)
    }
}
