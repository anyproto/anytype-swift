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

extension HomeCollectionViewModel {
    struct DashboardPage {
        var id: String
        var targetBlockId: String
        var title: String?
        func publicTitle() -> String {
            if self.style?.style == .archive {
                return "Archive"
            }
            return self.title ?? ""
        }
        var iconEmoji: String?
        var style: Anytype_Model_Block.Content.Link?
    }
}

class HomeCollectionViewModel: ObservableObject {
    
    /// Typealiases
    typealias RootModel = TopLevelContainerModelProtocol
    typealias Transformer = TopLevel.AliasesMap.BlockTools.Transformer.FinalTransformer
    
    typealias DetailsAccessor = TopLevel.AliasesMap.DetailsUtilities.InformationAccessor
    
    typealias CellUserAction = HomeCollectionViewDocumentCellModel.UserActionPayload
    
    /// Variables
    private let dashboardService: DashboardServiceProtocol = DashboardService()
    private let blockActionsService: ServiceLayerModule.Single.BlockActionsService = .init()
    private let middlewareConfigurationService: MiddlewareConfigurationService = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    private let eventProcessor: DocumentModule.Document.ViewController.ViewModel.EventProcessor = .init()
    private var rootModel: RootModel? {
        didSet {
            self.handleNewRootModel(self.rootModel)
        }
    }
    private let transformer: Transformer = .defaultValue
    private let flattener: BlocksViews.Supplement.BaseFlattener = .defaultValue
        
    @Published var documentsViewModels: [HomeCollectionViewCellType] = []
    var pageDetailsViewModel: DocumentModule.Document.ViewController.ViewModel.PageDetailsViewModel = .init()
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
    /// Update @Published $builders.
    private func syncBuilders(_ completion: @escaping () -> () = { }) {
        DispatchQueue.main.async {
            self.rootModel.flatMap(self.toList(_:)).flatMap(self.update(builders:))
            completion()
        }
    }
    
    // TODO: Add caching?
    private func update(builders: [BlockViewBuilderProtocol]) {
        /// We should add caching, otherwise, we will miss updates from long-playing views as file uploading or downloading views.
//        let difference = builders.difference(from: self.builders) {$0.diffable == $1.diffable}
//        if let result = self.builders.applying(difference) {
//            self.builders = result
//        }
//        else {
//            // We should set all builders, because our collection is empty?
//            self.builders = builders
//        }
//        self.dashboardPages
//        self.builders = builders
        let newBuilders = builders.compactMap({$0 as? BlocksViews.New.Tools.PageLink.ViewModel})
        self.createViewModels(from: newBuilders)
    }
    
    /// Convert tree model to list view model.
    /// - Parameter model: a tree model that we want to convert.
    /// - Returns: a list of view models. ( builders )
    private func toList(_ model: RootModel) -> [BlockViewBuilderProtocol] {
        guard let rootId = model.rootId, let rootModel = model.blocksContainer.choose(by: rootId) else { return [] }
        let result = self.flattener.toList(rootModel)
        return result
    }

    func handleNewRootModel(_ model: RootModel?) {
        if let model = self.rootModel {
            self.eventProcessor.didProcessEventsPublisher.sink(receiveValue: { [weak self] (value) in
                switch value {
                case .update(.empty): return
                default: break
                }

                self?.syncBuilders({ [weak self, value] in
                    switch value {
                    case let .update(value):
                        if !value.addedIds.isEmpty, let id = value.addedIds.first {
                            /// open page.
                            self?.openPage(with: id)
                        }
                    default: return
                    }
                })
            }).store(in: &self.subscriptions)
            _ = self.eventProcessor.configured(model)
        }
        _ = self.flattener.configured(self.rootModel)
        self.syncBuilders()
        self.configurePageDetails(for: self.rootModel)
    }
}

// MARK: - Configure Page Details
private extension HomeCollectionViewModel {
    func configurePageDetails(for rootModel: RootModel?) {
        guard let model = rootModel else { return }
        guard let rootId = model.rootId, let ourModel = model.detailsContainer.choose(by: rootId) else { return }
        let detailsPublisher = ourModel.didChangeInformationPublisher()
        self.pageDetailsViewModel.configured(publisher: detailsPublisher)
    }
}

// MARK: - Handle Open Action
private extension HomeCollectionViewModel {
    func handleOpenDashboard(_ value: ServiceLayerModule.Success) {
        let blocks = self.eventProcessor.handleBlockShow(events: .init(contextId: value.contextID, events: value.messages, ourEvents: []))
        guard let event = blocks.first else { return }
        
        /// Now transform and create new container.
        ///
        /// And then, sync builders...

        let rootId = value.contextID
        
        let blocksContainer = self.transformer.transform(event.blocks, rootId: rootId)
        let parsedDetails = event.details.map(TopLevel.Builder.detailsBuilder.build(information:))
        let detailsContainer = TopLevel.Builder.detailsBuilder.build(list: parsedDetails)
        
        /// Add details models to process.
        self.rootModel = TopLevel.Builder.build(rootId: rootId, blockContainer: blocksContainer, detailsContainer: detailsContainer)
    }
}

// MARK: - Private
extension HomeCollectionViewModel {
        
    private func createViewModels(from pages: [BlocksViews.New.Tools.PageLink.ViewModel]) {
        let links = pages.compactMap({ value -> HomeCollectionViewDocumentCellModel? in
            let model: HomeCollectionViewDocumentCellModel = .init(id: value.blockId, title: "", image: nil, emoji: nil)
            let detailsModel = value.getDetailsViewModel()
            let accessor = detailsModel.wholeDetailsPublisher.map(DetailsAccessor.init)
            
            let title = accessor.map(\.title).map({$0?.value}).eraseToAnyPublisher()
            let emoji = accessor.map(\.iconEmoji).map({$0?.value}).eraseToAnyPublisher()
            let iconImage = accessor.map(\.iconImage).map({$0?.value}).eraseToAnyPublisher()
            
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
    func removePage(with id: BlockId) {
        guard let rootId = self.rootModel?.rootId else { return }
        guard let targetModel = self.rootModel?.blocksContainer.choose(by: id) else { return }
        let blockId = targetModel.blockModel.information.id
        self.blockActionsService.delete.action(contextID: rootId, blockIds: [blockId]).sink { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .homeCollectionViewModel)
                os_log(.error, log: logger, "Remove page error %@", String(describing: error))
            }
        } receiveValue: { [weak self] value in
            /// TODO: Add interactor as a part of rootModel.
            self?.eventProcessor.handle(events: .init(contextId: value.contextID, events: value.messages, ourEvents: []))
        }.store(in: &self.subscriptions)
    }
    
    func openPage(with id: BlockId) {
        guard let targetModel = self.rootModel?.blocksContainer.choose(by: id) else { return }
        guard case let .link(link) = targetModel.blockModel.information.content else { return }
        
        let blockId = link.targetBlockID
        self.send(.showPage(blockId))
    }
    func didSelectPage(with index: IndexPath) {        
        switch self.documentsViewModels[index.row] {
        case let .document(value):
            self.openPage(with: value.id)
            
        case .plus:
            guard let rootId = self.rootModel?.rootId else { return }
            self.dashboardService.createNewPage(contextId: rootId).sink(receiveCompletion: { result in
                switch result {
                case .finished: return
                case let .failure(error):
                    let logger = Logging.createLogger(category: .homeCollectionViewModel)
                    os_log(.error, log: logger, "Create page error %@", String(describing: error))
                }
            }) { [weak self] value in
                self?.eventProcessor.handle(events: .init(contextId: value.contextID, events: value.messages))
            }.store(in: &self.subscriptions)
        }
    }
}

// MARK: - Contextual menu Interaction

