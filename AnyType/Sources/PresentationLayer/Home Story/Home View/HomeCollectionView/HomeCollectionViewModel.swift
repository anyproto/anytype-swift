//
//  HomeCollectionViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 13.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import Combine
import SwiftUI

enum HomeCollectionViewCellType: Hashable {
    case plus
    case document(HomeCollectionViewDocumentCellModel)
}

class HomeCollectionViewModel: ObservableObject {
    private let dashboardService: DashboardServiceProtocol = DashboardService()
    private var subscriptions = Set<AnyCancellable>()
    var documentsHeaders: DocumentsHeaders?
    var documentsCell = [HomeCollectionViewCellType]()
    @Published var error: String = ""
    
    init() {
        self.obtainDocuments()
        self.subscribeDashBoard()
    }
    
    private func subscribeDashBoard() {
		dashboardService.subscribeDashboardEvents()
			.receive(on: RunLoop.main)
			.sink(receiveCompletion: { _ in
			})
			{ value in
				print("\(value)")
		}
		.store(in: &subscriptions)
    }
    
    private func obtainDocuments() {
		dashboardService.obtainDashboardBlocks()
			.receive(on: RunLoop.main)
			.sink(receiveCompletion: { _ in
			}) { value in
				print("\(value)")

		}
		.store(in: &subscriptions)
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
