//
//  DocumentViewModel+New.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import os
import BlocksModels

fileprivate typealias Namespace = EditorModule.Document.ViewController
fileprivate typealias FileNamespace = Namespace.ViewModel

private extension Logging.Categories {
    static let editorDocumentViewModel: Self = "EditorModule.Document.ViewModel"
}

// MARK: State
extension FileNamespace {
    enum State {
        case loading
        case empty
        case ready
    }
    var state: State {
        switch self.internalState {
        case .loading: return .loading
        default: return self.builders.isEmpty ? .empty : .ready
        }
    }
}

// MARK: Events
extension FileNamespace {
    enum UserEvent {
        case pageDetailsViewModelsDidSet
    }
}

// MARK: - Options
extension FileNamespace {
    /// Structure contains `Feature Flags`.
    ///
    struct Options {
        var shouldCreateEmptyBlockOnTapIfListIsEmpty: Bool = false
    }
}

extension Namespace {
    
    class ViewModel: ObservableObject {
        /// Aliases
        typealias RootModel = TopLevelContainerModelProtocol
        typealias BlockId = TopLevel.AliasesMap.BlockId
        typealias ModelInformation = BlockInformationModelProtocol
        
        typealias Transformer = TopLevel.AliasesMap.BlockTools.Transformer.FinalTransformer
        
        typealias UserInteractionHandler = BlocksViews.Supplement.UserInteractionHandler
        typealias ListUserInteractionHandler = BlocksViews.Supplement.ListUserInteractionHandler
        
        typealias BlocksUserAction = BlocksViews.UserAction
        
        typealias BlocksViewsNamespace = BlocksViews.New
                
        /// Service
        private var blockActionsService: ServiceLayerModule.Single.BlockActionsService = .init()
        
        /// Document ViewModel
        private(set) var documentViewModel: BlocksViews.Document.ViewModel = .init()
        
        /// User Interaction Processor
        private var userInteractionHandler: UserInteractionHandler = .init()
        private var listUserInteractionHandler: ListUserInteractionHandler = .init()
        
        /// Combine Subscriptions
        private var subscriptions: Set<AnyCancellable> = .init()
        
        /// Selection Handler
        private(set) var selectionHandler: EditorModuleSelectionHandlerProtocol?
        
        private var listToolbarSubject: PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never> = .init()
        
        private var publicUserActionSubject: PassthroughSubject<BlocksUserAction, Never> = .init()
        lazy var publicUserActionPublisher: AnyPublisher<BlocksUserAction, Never> = { self.publicUserActionSubject.eraseToAnyPublisher() }()
        
        private var publicActionsPayloadSubject: PassthroughSubject<BlocksViewsNamespace.Base.ViewModel.ActionsPayload, Never> = .init()
        lazy var publicActionsPayloadPublisher: AnyPublisher<BlocksViewsNamespace.Base.ViewModel.ActionsPayload, Never> = { self.publicActionsPayloadSubject.eraseToAnyPublisher() }()
        
        private var publicSizeDidChangeSubject: PassthroughSubject<CGSize, Never> = .init()
        lazy private(set) var publicSizeDidChangePublisher: AnyPublisher<CGSize, Never> = { self.publicSizeDidChangeSubject.eraseToAnyPublisher() }()
        
        private var listActionsPayloadSubject: PassthroughSubject<ActionsPayload, Never> = .init()
        lazy private var listActionsPayloadPublisher: AnyPublisher<ActionsPayload, Never> = {
            self.listActionsPayloadSubject.eraseToAnyPublisher()
        }()
        
        /// Options property publisher.
        /// We expect that `ViewController` will listen this property.
        /// `ViewController` should sink on this property after `viewDidLoad`.
        ///
        @Published var options: Options = .init()
        
        @Published var error: String?
                
        // MARK: - Events
        @Published var userEvent: UserEvent?
        
        // MARK: - Page View Models
        /// We need this model to be Published cause need handle actions from IconEmojiBlock
        typealias PageDetailsViewModelsDictionary = [DocumentModule.Document.BaseDocument.DetailsContentKind : BlockViewBuilderProtocol]
        @available(iOS, introduced: 13.0, deprecated: 14.0, message: "This property make sense only before real model was presented. Remove it.")
        lazy private(set) var detailsViewModels: PageDetailsViewModelsDictionary = [:] {
            didSet {
                self.enhanceDetails(self.detailsViewModels)
                self.userEvent = .pageDetailsViewModelsDidSet
            }
        }
        
        // MARK: - Builders
        @Published var builders: [BlockViewBuilderProtocol] = []
        private var internalState: State = .loading
        
        @Published var buildersRows: [Row] = [] {
            didSet {
                /// Disable selection mode.
                if self.buildersRows.isEmpty {
                    self.set(selectionEnabled: false)
                }
            }
        }
        
        /// We should update some items in place.
        /// For that, we use this subject which send events that some items are just updated, not removed or deleted.
        /// Its `Output` is a `List<BlockId>`
        private var anyStyleSubject: PassthroughSubject<[BlockId], Never> = .init()
        var anyStylePublisher: AnyPublisher<[BlockId], Never> = .empty()
        
        // put into protocol?
        // var userActionsPublisher: AnyPublisher<UserAction>
        
        func setupSubscriptions() {
            self.publicActionsPayloadPublisher.sink { [weak self] (value) in
                self?.process(actionsPayload: value)
            }.store(in: &self.subscriptions)
            
            _ = self.userInteractionHandler.configured(self.publicActionsPayloadPublisher)
            
            self.listToolbarSubject.sink { [weak self] (value) in
                self?.process(toolbarAction: value)
            }.store(in: &self.subscriptions)
            
            _ = self.listUserInteractionHandler.configured(self.listActionsPayloadPublisher)
            
            self.userInteractionHandler.reactionPublisher.sink { [weak self] (value) in
                self?.process(reaction: value)
            }.store(in: &self.subscriptions)
            
            self.listUserInteractionHandler.reactionPublisher.sink { [weak self] (value) in
                self?.process(reaction: value)
            }.store(in: &self.subscriptions)
            
            self.$builders.sink { [weak self] value in
                self?.buildersRows = value.compactMap(Row.init).map({ (value) in
                    var value = value
                    return value.configured(selectionHandler: self?.selectionHandler)
                })
                self?.enhanceUserActionsAndPayloads(value)
            }.store(in: &self.subscriptions)
        }
        
        // MARK: Initialization
        init(documentId: String?, options: Options) {
            // TODO: Add failable init.
            let logger = Logging.createLogger(category: .editorDocumentViewModel)
            os_log(.debug, log: logger, "Don't forget to change to failable init?()")
            
            guard let documentId = documentId else {
                let logger = Logging.createLogger(category: .editorDocumentViewModel)
                os_log(.debug, log: logger, "Don't pass nil documentId to DocumentViewModel.init()")
                return
            }
            
            self.options = options
            self.setupSubscriptions()
            
            // TODO: Deprecated.
            // We should rename it.
            // Our case would be the following
            // We should expose one publisher that will publish different updates (delete/update/add) to outer world.
            // Or to our view controller.
            // Maybe it will publish only resulted collection of elements.
            self.anyStylePublisher = self.anyStyleSubject.eraseToAnyPublisher()
            
            self.obtainDocument(documentId: documentId)
        }
        
        // TODO: Add caching?
        private func update(builders: [BlockViewBuilderProtocol]) {
            /// We should add caching, otherwise, we will miss updates from long-playing views as file uploading or downloading views.
            let difference = builders.difference(from: self.builders) {$0.diffable == $1.diffable}
            if let result = self.builders.applying(difference) {
                self.builders = result
            }
            else {
                // We should set all builders, because our collection is empty?
                self.builders = builders
            }
            //            self.builders = builders
        }
        
        private func obtainDocument(documentId: String?) {
            guard let documentId = documentId else { return }
            self.internalState = .loading
                        
            self.blockActionsService.open.action(contextID: documentId, blockID: documentId)
                //                .print()
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { [weak self] (value) in
                    switch value {
                    case .finished: break
                    case let .failure(error):
                        self?.internalState = .empty
                        self?.error = error.localizedDescription
                    }
                }, receiveValue: { [weak self] value in
                    self?.handleOpenDocument(value)
                }).store(in: &self.subscriptions)
        }
        
        private func handleOpenDocument(_ value: ServiceLayerModule.Success) {
            self.documentViewModel.updatePublisher().sink { [weak self] (value) in
                /// Process values.
                DispatchQueue.main.async {
                    self?.update(builders: value.models)
                    switch value.updates {
                    case .general: break
                    case let .update(value):
                        /// We should calculate updates correctly.
                        /// For example, we should remove items if they appear in detetedIds.
                        /// That means that even if they appear in updatedIds, we still need to remove them.
                        if !value.updatedIds.isEmpty {
                            self?.anyStyleSubject.send(value.updatedIds)
                        }
                        if !value.deletedIds.isEmpty {
                            self?.deselect(ids: Set(value.deletedIds))
                        }
                    }
                }
            }.store(in: &self.subscriptions)
            self.documentViewModel.open(value)
            self.configureDetails()
            self.configureInteractions(self.documentViewModel.documentId)
        }
        
        private func configureInteractions(_ documentId: BlockId?) {
            guard let documentId = documentId else {
                let logger = Logging.createLogger(category: .editorDocumentViewModel)
                os_log(.debug, log: logger, "configureInteractions(_:). DocumentId is not configured.")
                return
            }
            _ = self.userInteractionHandler.configured(documentId: documentId).configured(self)
            _ = self.listUserInteractionHandler.configured(documentId: documentId)
        }
        
        private func configureDetails() {
            let detailsViewModels = self.documentViewModel.defaultDetailsViewModels()
            var dictionary: PageDetailsViewModelsDictionary = [:]
            /// TODO:
            /// Refactor when you are ready.
            /// It is tough stuff.
            ///
            if let title = detailsViewModels.first(where: {$0 as? BlocksViewsNamespace.Page.Title.ViewModel != nil}) {
                dictionary[.title] = title
            }
            if let iconEmoji = detailsViewModels.first(where: {$0 as? BlocksViewsNamespace.Page.IconEmoji.ViewModel != nil}) {
                dictionary[.iconEmoji] = iconEmoji
            }
            self.detailsViewModels = dictionary
        }
    }
}

// MARK: Reactions
private extension FileNamespace {
    func process(reaction: UserInteractionHandler.Reaction) {
        switch reaction {
        case let .shouldHandleEvent(value):
            let events = value.payload.events
            self.documentViewModel.handle(events: events)
            
        default: return
        }
    }
    func process(reaction: ListUserInteractionHandler.Reaction) {
        switch reaction {
        case let .shouldHandleEvent(value):
            let events = value.payload.events
            self.documentViewModel.handle(events: events)
        }
    }
}

// MARK: - On Tap Gesture
extension FileNamespace {
    func handlingTapIfEmpty() {
        self.userInteractionHandler.createEmptyBlock(listIsEmpty: self.state == .empty, parentModel: self.documentViewModel.getRootActiveModel())
    }
}

// MARK: didSelectItem
extension FileNamespace {
    func didSelectBlock(at index: IndexPath) {
        // dispatch event
        
        if self.selectionEnabled() {
            self.didSelect(atIndex: index)
            return
        }
        
        if let builder = element(at: index).builder as? BlocksViewsNamespace.Base.ViewModel {
            builder.receive(event: .didSelectRowInTableView)
        }
    }
    
}

// MARK: Selection Handling
private extension FileNamespace {
    func process(actionsPayload: BlocksViewsNamespace.Base.ViewModel.ActionsPayload) {
        switch actionsPayload {
        case let .textView(value):
            switch value.action {
            case .textView(.showMultiActionMenuAction(.showMultiActionMenu)):
                self.set(selectionEnabled: true)
            default: return
            }
        default: return
        }
    }
    func didSelect(atIndex: IndexPath) {
        let item = element(at: atIndex)
        // so, we have to toggle item at index.
        let newValue = !item.isSelected
        if let key = item.getSelectionKey() {
            self.set(selected: newValue, id: key)
            // TODO: We should subscribe on updates in our cells and update them.
            /// For now we use `reloadData`
            //            self.syncBuilders()
        }
    }
    func process(_ value: EditorModule.Selection.ToolbarPresenter.SelectionAction) {
        switch value {
        case let .selection(value):
            switch value {
            case let .selectAll(value):
                switch value {
                case .selectAll: self.selectAll()
                case .deselectAll: self.deselectAll()
                }
            case .done(.done): self.set(selectionEnabled: false)
            }
        case let .toolbar(value):
            let selectedIds = self.list()
            switch value {
            case .turnInto: self.publicUserActionSubject.send(.toolbars(.turnIntoBlock(.init(output: self.listToolbarSubject))))
            case .delete: self.listActionsPayloadSubject.send(.toolbar(.init(model: selectedIds, action: .editBlock(.delete))))
            case .copy: break
            }
        }
    }
    func process(toolbarAction: BlocksViews.Toolbar.UnderlyingAction) {
        let selectedIds = self.list()
        self.listActionsPayloadSubject.send(.toolbar(.init(model: selectedIds, action: toolbarAction)))
    }
}

extension FileNamespace {
    enum ActionsPayload {
        typealias BlockId = TopLevel.AliasesMap.BlockId
        typealias ListModel = [BlockId]
        struct Toolbar {
            typealias Model = ListModel
            typealias Action = BlocksViews.Toolbar.UnderlyingAction
            var model: Model
            var action: Action
        }
        
        case toolbar(Toolbar)
    }
}

extension FileNamespace {
    func configured(multiSelectionUserActionPublisher: AnyPublisher<EditorModule.Selection.ToolbarPresenter.SelectionAction, Never>) -> Self {
        multiSelectionUserActionPublisher.sink { [weak self] (value) in
            self?.process(value)
        }.store(in: &self.subscriptions)
        return self
    }
    func configured(selectionHandler: EditorModuleSelectionHandlerProtocol?) -> Self {
        self.selectionHandler = selectionHandler
        return self
    }
}

// MARK: Debug
extension FileNamespace: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(String(reflecting: Self.self)) -> \(String(describing: self.documentViewModel.documentId))"
    }
}

// MARK: Enhance UserActions and Payloads
/// These methods work in opposite way as `Merging`.
/// Instead, we just set a "delegate" ( no, our Subject ) to all viewModels in a List.
/// So, we have different approach.
///
/// 1. We have one Subject that we give to all ViewModels.
///
extension FileNamespace {
    func enhanceUserActionsAndPayloads(_ builders: [BlockViewBuilderProtocol]) {
        let ourViewModels = builders.compactMap({$0 as? BlocksViewsNamespace.Base.ViewModel})
        ourViewModels.forEach { (value) in
            _ = value.configured(userActionSubject: self.publicUserActionSubject)
            _ = value.configured(actionsPayloadSubject: self.publicActionsPayloadSubject)
            _ = value.configured(sizeDidChangeSubject: self.publicSizeDidChangeSubject)
        }
    }
    
    func enhanceDetails(_ value: PageDetailsViewModelsDictionary) {
        let ourValues = value.values.compactMap({$0 as? BlocksViewsNamespace.Base.ViewModel})
        ourValues.forEach { (value) in
            _ = value.configured(userActionSubject: self.publicUserActionSubject)
            _ = value.configured(actionsPayloadSubject: self.publicActionsPayloadSubject)
        }
    }
}
