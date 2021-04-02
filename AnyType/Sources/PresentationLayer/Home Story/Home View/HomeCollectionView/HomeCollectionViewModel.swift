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
import BlocksModels

private extension Logging.Categories {
    static let homeCollectionViewModel: Self = "HomeCollectionViewModel"
}

enum HomeCollectionViewCellType: Hashable {
    case plus
    case document(HomeCollectionViewDocumentCellModel)
}

class HomeCollectionViewModel: ObservableObject {
    
    /// Typealiases
    typealias RootModel = TopLevelContainerModelProtocol
    typealias Transformer = TopLevel.AliasesMap.BlockTools.Transformer.FinalTransformer
    
    typealias DetailsAccessor = InformationAccessor
    
    typealias CellUserAction = HomeCollectionViewDocumentCellModel.UserActionPayload
    
    /// Variables
    private let dashboardService: DashboardServiceProtocol = DashboardService()
    private let blockActionsService: BlockActionsServiceSingle = .init()
    private let middlewareConfigurationService: MiddlewareConfigurationService = .init()
    private var subscriptions: Set<AnyCancellable> = []
    private var testSubscriptions: Set<AnyCancellable> = []
            
    @Published var documentsViewModels: [HomeCollectionViewCellType] = []
    private var documentViewModel: BlocksViews.DocumentViewModel = .init()
    
    @Published var error: String = ""
    
    // TODO: Revise this later. Just in case, save rootId - used for filtering events from middle for main dashboard
//    var rootId: String?
    var userActionsPublisher: AnyPublisher<UserAction, Never> = .empty()
    private var userActionsSubject: PassthroughSubject<UserAction, Never> = .init()
    
    private var cellUserActionSubject: PassthroughSubject<CellUserAction, Never> = .init()
    
    // MARK: - Setup
    func setupDashboard() {
        self.dashboardService.openDashboard().receive(on: RunLoop.main)
        .sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .homeCollectionViewModel)
                os_log(.error, log: logger, "Subscribe dashboard events error %@", String(describing: error))
            }
        }) { [weak self] value in
            self?.handleOpenDashboard(value)
        }.store(in: &self.subscriptions)
    }
    
    func setupSubscribers() {
        self.userActionsPublisher = self.userActionsSubject.eraseToAnyPublisher()
        
        self.cellUserActionSubject.map({ value -> UserEvent in
            switch value.action {
            case .remove: return .contextualMenu(.init(model: value.model, action: .editBlock(.delete)))
            }
        }).sink { [weak self] (value) in
            self?.receive(value)
        }.store(in: &self.subscriptions)
    }
    
    func setup() {
        self.setupSubscribers()
        self.setupDashboard()
    }
    
    // MARK: - Lifecycle
    init() {
        self.setup()
    }
}

// MARK: - React on root model
private extension HomeCollectionViewModel {
    // TODO: Add caching?
    private func update(builders: [BlockViewBuilderProtocol]) {
        /// We should add caching, otherwise, we will miss updates from long-playing views as file uploading or downloading views.
        let newBuilders = builders.compactMap({$0 as? BlocksViews.New.Tools.PageLink.ViewModel})
        self.createViewModels(from: newBuilders)
    }
}

// MARK: - Handle Open Action
private extension HomeCollectionViewModel {
    func handleOpenDashboard(_ value: ServiceSuccess) {
        /// TODO:
        /// Decide how we should handle block opening.
        ///
        self.documentViewModel.updatePublisher().sink { [weak self] (value) in
            switch value.updates {
                case .update(.empty): return
                default: break
            }
            
            DispatchQueue.main.async {
                self?.update(builders: value.models)
                switch value.updates {
                case let .update(value):
                    if !value.addedIds.isEmpty, let id = value.addedIds.first {
                        /// open page.
                        self?.openPage(with: id)
                    }
                default: return
                }
            }
        }.store(in: &self.subscriptions)
        self.documentViewModel.open(value)
    }
}

// MARK: - Private
extension HomeCollectionViewModel {
        
    private func createViewModels(from pages: [BlocksViews.New.Tools.PageLink.ViewModel]) {
        self.testSubscriptions = []
        let links = pages.compactMap({ value -> HomeCollectionViewDocumentCellModel? in
            let model: HomeCollectionViewDocumentCellModel
            let detailsModel = value.getDetailsViewModel()

            let details = detailsModel.currentDetails
            let detailsAcccessor = DetailsAccessor.init(value: details)
            let targetBlockId: String
            if case let .link(link) = value.getBlock().blockModel.information.content {
                targetBlockId = link.targetBlockID
            }
            else {
                targetBlockId = ""
            }
            model = .init(page: .init(id: value.blockId, targetBlockId: targetBlockId), title: detailsAcccessor.title?.value ?? "", image: nil, emoji: detailsAcccessor.iconEmoji?.value)

            let accessorPublisher = detailsModel.wholeDetailsPublisher.map(DetailsAccessor.init)
            
            let title = accessorPublisher.map(\.title).map({$0?.value}).eraseToAnyPublisher()
            let emoji = accessorPublisher.map(\.iconEmoji).map({$0?.value}).eraseToAnyPublisher()
            let iconImage = accessorPublisher.map(\.iconImage).map({$0?.value}).eraseToAnyPublisher()
                        
            model.configured(titlePublisher: title)
            model.configured(emojiImagePublisher: emoji)
            model.configured(imagePublisher: iconImage)
            model.configured(userActionSubject: self.cellUserActionSubject)
            return model
        }).map(HomeCollectionViewCellType.document)
        self.documentsViewModels = links + [.plus]
    }
}

// MARK: Events
extension HomeCollectionViewModel {
    typealias Input = UserEvent
    typealias Output = UserAction
    enum UserAction {
        case showPage(BlockId)
        
    }
    
    private func send(_ action: UserAction) {
        self.userActionsSubject.send(action)
    }
    
    enum UserEvent {
        struct ContextualMenuAction {
            typealias Model = BlockId
            typealias Action = BlocksViews.Toolbar.UnderlyingAction
            var model: Model
            var action: Action
        }
        case contextualMenu(ContextualMenuAction)
    }
    func receive(_ event: UserEvent) {
        switch event {
        case let .contextualMenu(event):
            switch event.action {
            case .editBlock(.delete): self.removePage(with: event.model)
            default:
                let logger = Logging.createLogger(category: .homeCollectionViewModel)
                os_log(.debug, log: logger, "Skipping event: %@. We are only handling actions above. Do not forget to process all actions.", String(describing: event))
            }
        }
    }
}

// MARK: - view events
extension HomeCollectionViewModel {
    typealias BlockId = TopLevel.AliasesMap.BlockId
    
    /// TODO: Add
    /// Add interaction handlers?
    ///
    func removePage(with id: BlockId) {
        guard let rootId = self.documentViewModel.documentId else { return }
//        guard let targetModel = self.rootModel?.blocksContainer.choose(by: id) else { return }
//        let blockId = targetModel.blockModel.information.id
        let blockId = id
        self.blockActionsService.delete(contextID: rootId, blockIds: [blockId]).sink { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .homeCollectionViewModel)
                os_log(.error, log: logger, "Remove page error %@", String(describing: error))
            }
        } receiveValue: { [weak self] value in
            self?.documentViewModel.handle(events: .init(contextId: value.contextID, events: value.messages))
        }.store(in: &self.subscriptions)
    }
    
    func openPage(with id: BlockId) {
//        guard let targetModel = self.rootModel?.blocksContainer.choose(by: id) else { return }
//        guard case let .link(link) = targetModel.blockModel.information.content else { return }

//        let blockId = link.targetBlockID
        self.send(.showPage(id))
    }
    func didSelectPage(with index: IndexPath) {        
        switch self.documentsViewModels[index.row] {
        case let .document(value):
            self.openPage(with: value.page.targetBlockId)
        case .plus:
            guard let rootId = self.documentViewModel.documentId else { return }
            self.dashboardService.createNewPage(contextId: rootId).sink(receiveCompletion: { result in
                switch result {
                case .finished: return
                case let .failure(error):
                    let logger = Logging.createLogger(category: .homeCollectionViewModel)
                    os_log(.error, log: logger, "Create page error %@", String(describing: error))
                }
            }) { [weak self] value in
                self?.documentViewModel.handle(events: .init(contextId: value.contextID, events: value.messages))
            }.store(in: &self.subscriptions)
        }
    }
}

// MARK: - Contextual menu Interaction

