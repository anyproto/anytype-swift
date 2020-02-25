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

    @Published var documentsCell = [HomeCollectionViewCellType]()
    @Published var error: String = ""
    var dashboardPages = [Anytype_Model_Block]() {
        didSet {
            createPagesViewModels(pages: dashboardPages)
        }
    }
    // TODO: Revise this later. Just in case, save rootId - used for filtering events from middle for main dashboard
    var rootId: String?
    
    init() {
        self.receivePages()
        self.subscribeDashboard()
    }
    
    private func subscribeDashboard() {
		dashboardService.subscribeDashboardEvents()
			.receive(on: RunLoop.main)
			.sink(receiveCompletion: { _ in
			})
			{ value in
				print("\(value)")
		}
		.store(in: &subscriptions)
    }
    
    private func receivePages() {
        dashboardService.obtainDashboardBlocks()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in }) { [weak self] value in
                self?.rootId = value.rootID
                self?.dashboardPages = value.blocks
        }
        .store(in: &subscriptions)
    }
}

extension HomeCollectionViewModel {
    
    private func createPagesViewModels(pages: [Anytype_Model_Block]) {
        documentsCell.removeAll()
        
        for page in pages {
            guard case .link(_) = page.content else { continue }
            
            // TODO: think about it, fucking protobuf
            var name = page.link.fields.fields["name"]?.stringValue ?? ""
            if page.link.style == .archive {
                name = "Archive"
            }
            var documentCellModel = HomeCollectionViewDocumentCellModel(title: name)
//            documentCellModel.emojiImage = document.icon
            documentsCell.append(.document(documentCellModel))
        }
        documentsCell.append(.plus)
    }
}

// MARK: - view events

extension HomeCollectionViewModel {
    
    func didSelectPage(with index: IndexPath) {
        switch documentsCell[index.row] {
        case .document(let cellModel):
        break // TODO: open page
        case .plus:
            guard let rootId = rootId else { break }
            dashboardService.createPage(contextId: rootId)
                .flatMap { _ -> AnyPublisher<Never, Error> in // TODO: retain cycle?
                    self.dashboardService.subscribeDashboardEvents()
            }
            .sink(receiveCompletion: { result in
                print("\(result)")
                // TODO: handle error
            }) { _ in }
                .store(in: &subscriptions)
        }
    }
}
