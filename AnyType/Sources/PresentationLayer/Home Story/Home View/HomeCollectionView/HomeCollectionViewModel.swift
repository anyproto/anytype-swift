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

    
    /// Variables
    private let dashboardService: DashboardServiceProtocol = DashboardService()
    private let middlewareConfigurationService: MiddlewareConfigurationService = .init()
    private var subscriptions: Set<AnyCancellable> = []
    
    private let eventProcessor: DocumentModule.DocumentViewModel.EventProcessor = .init()
    private var rootModel: RootModel? {
        didSet {
            self.handleNewRootModel(self.rootModel)
        }
    }
    private let transformer: Transformer = .defaultValue
    private let flattener: BlocksViews.NewSupplement.BaseFlattener = BlocksViews.NewSupplement.CompoundFlattener.init()
        
    @Published var documentsViewModels: [HomeCollectionViewCellType] = []
    var pageDetailsViewModel: DocumentModule.DocumentViewModel.PageDetailsViewModel = .init()
    @Published var error: String = ""
    var dashboardPages: [DashboardPage] = []
    
    // TODO: Revise this later. Just in case, save rootId - used for filtering events from middle for main dashboard
    var rootId: String?
//    var view: HomeCollectionViewInput?
    var userActionsPublisher: AnyPublisher<UserAction, Never> = .empty()
    private var userActionsSubject: PassthroughSubject<UserAction, Never> = .init()
    
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
            let model: HomeCollectionViewDocumentCellModel = .init(id: value.blockId, title: "", image: nil, emojiImage: nil)
            let detailsModel = value.getDetailsViewModel()
            let accessor = detailsModel.wholeDetailsPublisher.map(DetailsAccessor.init)
            
            let title = accessor.map(\.title).map({$0?.value}).eraseToAnyPublisher()
            let emojiImage = accessor.map(\.iconEmoji).map({$0?.value}).eraseToAnyPublisher()
            
            model.configured(titlePublisher: title)
            model.configured(emojiImagePublisher: emojiImage)
            return model
        }).map(HomeCollectionViewCellType.document)
        self.documentsViewModels = links + [.plus]
    }
    
    private func createViewModels(from pages: [DashboardPage]) {
        let links = pages.map({ value -> HomeCollectionViewDocumentCellModel in
            .init(id: UUID().uuidString, title: value.publicTitle(), image: nil, emojiImage: value.iconEmoji)
        }).map(HomeCollectionViewCellType.document)
        self.documentsViewModels = links + [.plus]
    }
}

// MARK: Events
extension HomeCollectionViewModel {
    enum UserAction {
        case showPage(BlockId)
    }
    
    private func send(_ action: UserAction) {
        self.userActionsSubject.send(action)
    }
}

// MARK: - view events
extension HomeCollectionViewModel {
    typealias BlockId = TopLevel.AliasesMap.BlockId
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
            }.store(in: &subscriptions)
        }
    }
}
