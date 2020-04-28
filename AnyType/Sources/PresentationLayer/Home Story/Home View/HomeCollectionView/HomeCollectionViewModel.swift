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
    private let middlewareConfigurationService: MiddlewareConfigurationService = .init()
    private var eventListener: NotificationEventListener<HomeCollectionViewModel>?
    private var subscriptions: Set<AnyCancellable> = []

    @Published var documentsCell: [HomeCollectionViewCellType] = []
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
        self.eventListener = NotificationEventListener(handler: self)
        
        /// NOTE: Look at it carefully.
        /// We obtain configuration and setup eventListener to `.receive` values from all events with `(contextID: configuration.homeBlockID)`
        ///
        self.middlewareConfigurationService.obtainConfiguration().sink(receiveCompletion: { (value) in
            switch value {
            case .finished: break
            case let .failure(error):
                let logger = Logging.createLogger(category: .homeCollectionViewModel)
                os_log(.error, log: logger, "Obtain configuration error %@", String(describing: error))
            }
        }, receiveValue: { [weak self] value in
            self?.eventListener?.receive(contextId: value.homeBlockID)
        }).store(in: &self.subscriptions)
        
        let listener = NotificationEventListener(handler: self)
        self.dashboardService.subscribeDashboardEvents().receive(on: RunLoop.main)
            .map(listener.process(messages:))
            .sink(receiveCompletion: { (value) in
                switch value {
                case .finished: return
                case let .failure(error):
                    let logger = Logging.createLogger(category: .homeCollectionViewModel)
                    os_log(.error, log: logger, "Subscribe dashboard events error %@", String(describing: error))
                }
            }) { }.store(in: &self.subscriptions)
    }
}

// MARK: - Private
extension HomeCollectionViewModel {
    
    private func createPagesViewModels(pages: [Anytype_Model_Block]) {
        documentsCell.removeAll()
        
        let links = pages.filter({
            switch $0.content {
            case .link: return true
            default: return false
            }})
            
            // Only title for now.
            .map({ value -> String in
                if value.link.style == .archive {
                    return "Archive"
                }
                else {
                    return value.link.fields.fields["name"]?.stringValue ?? ""
                }
            })
            .map({HomeCollectionViewDocumentCellModel.init(title:$0)})
            .map(HomeCollectionViewCellType.document)
        
        documentsCell.append(contentsOf: links)
        
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
            let listener = NotificationEventListener(handler: self)
            dashboardService.createPage(contextId: rootId).map(listener.process(messages:)).sink(receiveCompletion: { result in
                switch result {
                case .finished: return
                case let .failure(error):
                    let logger = Logging.createLogger(category: .homeCollectionViewModel)
                    os_log(.error, log: logger, "Create page error %@", String(describing: error))
                }
            }) { _ in }
                .store(in: &subscriptions)
        }
    }
}
