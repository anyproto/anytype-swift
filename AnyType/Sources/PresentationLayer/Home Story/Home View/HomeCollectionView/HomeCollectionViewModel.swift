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
	
	var documentsCell = [HomeCollectionViewCellType]()
	@Published var error: String = ""
	
	init() {
		self.obtainDocuments()
	}
	
	func obtainDocuments() {
		documentService.obtainDocuments { result in
			switch result {
			case .success(let documents):
				processObtainedDocuments(documents: documents)
			case .failure(let error):
				self.error = error.localizedDescription
			}
		}
	}

}

extension HomeCollectionViewModel {
	
	private func processObtainedDocuments(documents: [DocumentModel]) {
		for document in documents {
			var documentCellModel = HomeCollectionViewDocumentCellModel(title: document.name)
			documentCellModel.emojiImage = document.emojiImage
			documentsCell.append(.document(documentCellModel))
		}
		documentsCell.append(.plus)
	}
}
