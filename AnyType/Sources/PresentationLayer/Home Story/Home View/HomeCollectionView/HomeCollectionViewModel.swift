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
import os

private extension Logging.Categories {
    static let homeCollectionViewModel: Self = "HomeCollectionViewModel"
}

enum HomeCollectionViewCellType: Hashable {
    case plus
    case document(HomeCollectionViewDocumentCellModel)
}

class HomeCollectionViewModel: ObservableObject {
    private let dashboardService: DashboardServiceProtocol = DashboardService()
    private var middlewareEventsListener: NotificationEventListener<HomeCollectionViewModel>?
    private let middlewareConfigurationService: MiddlewareConfigurationService = .init()
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
    var view: HomeCollectionViewInput?
    
    // MARK: - Lifecycle
    init() {
        self.middlewareEventsListener = NotificationEventListener(handler: self)
        // obtain configuration -> subscribe to middleware notifiaction -> ask dashboard events
        middlewareConfigurationService.obtainConfiguration()
            .first()
            .receive(on: RunLoop.main)
            .sink(
                receiveCompletion: { competion in
                    switch competion {
                    case .finished: break
                    case .failure(_):
                        let logger = Logging.createLogger(category: .homeCollectionViewModel)
                        os_log(.error, log: logger, "obtain configuration error on %”@", "\(self)")
                    }
            },
                receiveValue: { [weak self] configuration in
                    // TODO: rethink it.
                    self?.middlewareEventsListener?.receive(contextId: configuration.homeBlockID)
                    self?.subscribeDashboard()
            })
        .store(in: &subscriptions)
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
}

// MARK: - Private
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
        case .document:
            guard dashboardPages.indices.contains(index.row) else { return }
            let object = dashboardPages[index.row]
            
            // we assume that every page is a link.
            guard case let .link(value) = object.content else { return }
            let blockId = value.targetBlockID
            view?.showPage(with: blockId)            
            break // TODO: open page
            
        case .plus:
            guard let rootId = rootId else { break }
            dashboardService.createPage(contextId: rootId).sink(receiveCompletion: { result in
                print("\(result)")
                // TODO: handle error
            }) { _ in }
                .store(in: &subscriptions)
        }
    }
}
