//
//  BlocksViews+Base.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import os

private extension Logging.Categories {
    static let blocksViewsBase: Self = "TextEditor.BlocksViews.Base"
}

// MARK: Options
extension BlocksViews.Base.ViewModel {
    /// Actually, `feature flags`.
    struct Options {
        var shouldAddContextualMenu: Bool = true
    }
}

extension BlocksViews.Base {
    class ViewModel: ObservableObject {
        typealias BlockModel = BlockModels.Block.RealBlock
        typealias BlockModelReal = BlockModels.Block.RealBlock // has type .block
        typealias BlockModelID = BlockModels.Block.RealBlock.Index
        
        // MARK: Variables
        /// our Block
        /// Maybe we should made it Observable?.. Let think a bit about it.
        private var block: BlockModel {
            didSet {
                self.blockUpdatesSubject.send(self.block)
            }
        }
        
        /// Options that handle a behavior of view model.
        private var options: Options = .init()
        
        /// Updates of block.
        /// Necessary to handle
        private var blockUpdatesSubject: PassthroughSubject<BlockModel, Never> = .init()
        lazy var blockUpdatesPublisher: AnyPublisher<BlockModel, Never> = {
            self.blockUpdatesSubject.eraseToAnyPublisher()
        }()
        
        // MARK: Deinitialization
        deinit {
            let logger = Logging.createLogger(category: .blocksViewsBase)
            os_log(.debug, log: logger, "%@ has been deinitialized: %@", "\(String(describing: self))", "-> \(self.block.information.id)")
        }
        
        // MARK: Initialization
        init(_ block: BlockModel) {
            self.block = block
            self.setupPublishers()
            self.setupSubscriptions()
            let logger = Logging.createLogger(category: .blocksViewsBase)
            os_log(.debug, log: logger, "%@ has been initialized: %@", "\(String(describing: self))", "-> \(self.block.information.id)")
        }
        
        static func generateID() -> BlockModelID {
            BlockModels.Utilities.IndexGenerator.generateID()
        }
        
        // MARK: Subclass / Blocks
        func getID() -> BlockModelID { getBlock().indexPath }
        
        /// Discussion
        /// This function should return full index and convert it in two numbers.
        /// Hahaha.
        func getFullIndex() -> BlockModelID {
            let block = getBlock()
            return block.indexPath
        }
        
        // MARK: Block model processing
        func getBlock() -> BlockModel { block }
        func isRealBlock() -> Bool { block.kind == .block }
        func getRealBlock() -> BlockModelReal { block }
        func update(block: (inout BlockModelReal) -> ()) {
            if isRealBlock() {
                self.block = update(getRealBlock(), body: block)
//                self.blockUpdatesSubject.send(self.block)
            }
        }
        
        // MARK: Events
        // MARK: - User Action Publisher
        /// This publisher sends actions to, in most cases, routing.
        /// If you would like to show controllers or action panes, you should listen events from this publisher.
        ///
        private var userActionSubject: PassthroughSubject<BlocksViews.UserAction, Never> = .init()
        public var userActionPublisher: AnyPublisher<BlocksViews.UserAction, Never> = .empty()
        
        // MARK: - Toolbar Action Publisher
        /// This Pair ( Publisher and Subject ) can manipulate with `ActionsPayload.Toolbar.Action`.
        /// For example, if you would like to show AddBlock toolbar, you will do these steps:
        ///
        /// 1. Create an action that will show desired Toolbar ( AddBlock in our case. )
        /// 2. Set Output to `toolbarActionSubject` for this AddBlock Toolbar.
        /// 3. Send `showEvent` to `userActionSubject` with desired configured action ( show(AddBlockToolbar(action(output)))
        /// 4. Listen `toolbarActionPublisher` for incoming events from user.
        ///
        /// If user press something, then AddBlockToolbar will send user action to `PassthroughSubject` ( or `toolbarActionSubject` in our case ).
        ///
        public private(set) var toolbarActionSubject: PassthroughSubject<ActionsPayload.Toolbar.Action, Never> = .init()
        public var toolbarActionPublisher: AnyPublisher<ActionsPayload.Toolbar.Action, Never> = .empty()
        
        // MARK: - Marks Pane Publisher
        /// This Pair ( Publisher and Subject ) can manipuate with `MarksPane.Main.Action`.
        /// If you would like to show `MarksPane`, you will need to configure specific action.
        ///
        /// These steps are necessary.
        ///
        /// 1. Create and action that will show desired MarksPane ( our MarksPane ).
        /// 2. Set Output to `marksPaneActionSubject` for this MarksPane.
        /// 3. Send `showEvent` to `userActionSubject` with desired configured action ( show(MarksPaneToolbar(action(output))) )
        /// 4. Also, if you would like configuration, you could set input as init-parameters. Look at apropriate `Input`.
        /// 5. Listen `marksPaneActionPublisher` for incoming events from user.
        ///
        /// If user press something, then MarksPane will send user action to `PassthroughSubject` ( or `marksPaneActionSubject` in our case )
        ///
        public private(set) var marksPaneActionSubject: PassthroughSubject<MarksPane.Main.Action, Never> = .init()
        public var marksPaneActionPublisher: AnyPublisher<MarksPane.Main.Action, Never> = .empty()

        
        // MARK: - Actions Payload Publisher
        /// This solo Publisher `actionsPayloadPublisher` merges all actions into meta `ActionsPayload` action.
        /// If you need to process whole user input for specific BlocksViewModel, you need to listen this publisher.
        ///
        public var actionsPayloadPublisher: AnyPublisher<ActionsPayload, Never> = .empty()
        
        // MARK: - Handle events
        func handle(toolbarAction: BlocksViews.Toolbar.UnderlyingAction) {
            // Do nothing? Just let somebody else to do stuff for you?
        }
        
        func handle(marksPaneAction: MarksPane.Main.Action) {
            // Do nothing? We need external custom processors?
            switch marksPaneAction {
            case let .style(range, action): return
            case let .textColor(range, action): return
            case let .backgroundColor(range, action): return // set background color of view and send sets background color.
            }
        }
        
        // MARK: - Setup / Publishers
        private func setupPublishers() {
            self.userActionPublisher = self.userActionSubject.eraseToAnyPublisher()
            self.toolbarActionPublisher = self.toolbarActionSubject.eraseToAnyPublisher()
            self.marksPaneActionPublisher = self.marksPaneActionSubject.eraseToAnyPublisher()
            
            self.actionsPayloadPublisher = self.toolbarActionPublisher.map({ActionsPayload.toolbar(.init(model: self.block, action: $0))}).eraseToAnyPublisher()
        }
        
        // MARK: - Setup / Subscriptions
        private func setupSubscriptions() {
            self.contextualMenuInteractor.provider = self
            self.contextualMenuInteractor.actionSubject.sink { [weak self] (value) in
                self?.handle(contextualMenuAction: value)
            }.store(in: &self.subscriptions)
        }
        
        // MARK: Contextual Menu
        private var subscriptions: Set<AnyCancellable> = []
        private var contextualMenuInteractor: ContextualMenuInteractor = .init()
        weak var contextualMenuDelegate: UIContextMenuInteractionDelegate? { self.contextualMenuInteractor }
                        
        // MARK: Indentation
        func indentationLevel() -> UInt {
            self.getBlock().indentationLevel()
            //getID().section > 0 ? UInt(getID().section) : 0
        }
        
        // MARK: Subclass / Information
        var information: MiddlewareBlockInformationModel { block.information }
        
        // MARK: Subclass / Views
        func makeSwiftUIView() -> AnyView { .init(EmptyView()) }
        func makeUIView() -> UIView { .init() }
        
        // MARK: Subclass / Events
        func handle(event: BlocksViews.UserEvent) {}
        
        // MARK: Subclass / ContextualMenu
        func makeContextualMenu() -> BlocksViews.ContextualMenu { .init() }
        func handle(contextualMenuAction: BlocksViews.ContextualMenu.MenuAction.Action) {
            switch contextualMenuAction {
            case let .general(value):
                switch value {
                case .delete: self.toolbarActionSubject.send(.editBlock(.delete))
                case .duplicate: self.toolbarActionSubject.send(.editBlock(.duplicate))
                case .moveTo: break
                }
            case let .specific(value):
                switch value {
                case .turnInto: self.send(userAction: .toolbars(.turnIntoBlock(.init(output: self.toolbarActionSubject))))
                case .style: self.send(userAction: .toolbars(.marksPane(.mainPane(.init(output: self.marksPaneActionSubject, input: nil)))))
                case .color: self.send(userAction: .toolbars(.marksPane(.mainPane(.init(output: self.marksPaneActionSubject, input: nil)))))
                case .backgroundColor: self.send(userAction: .toolbars(.marksPane(.mainPane(.init(output: self.marksPaneActionSubject, input: nil)))))
                default: return
                }
            default: return
            }
        }
    }
}

// MARK: OuterWorld Publishers and Subjects
extension BlocksViews.Base.ViewModel {
    /// This AactionsPayload describes all actions that user can do with BlocksViewsModels.
    /// For example, user can press long-tap and active toolbar.
    /// Or user could interact with text view.
    /// Possibly, that we need to separate text view actions.
    ///
    enum ActionsPayload {
        struct Toolbar {
            typealias Model = BlockModel
            typealias Action = BlocksViews.Toolbar.UnderlyingAction
            var model: Model
            var action: Action
        }
        
        /// For backward compatibility.
        struct TextBlocksViewsUserInteraction {
            typealias Model = BlockModel
            typealias Action = TextBlocksViews.UserInteraction
            var model: Model
            var action: TextBlocksViews.UserInteraction
        }
        
        case toolbar(Toolbar)
        case textView(TextBlocksViewsUserInteraction)
    }
}

// MARK: Options
extension BlocksViews.Base.ViewModel {
    func configured(_ options: Options) -> Self {
        self.options = options
        return self
    }
}

// MARK: Contextual Menu
extension BlocksViews.Base.ViewModel {
    func buildContextualMenu() -> BlocksViews.ContextualMenu {
        self.makeContextualMenu()
    }
}

// MARK: Contextual Menu Delegate
private extension BlocksViews.Base.ViewModel {
    class ContextualMenuInteractor: NSObject, UIContextMenuInteractionDelegate {
        // MARK: Conversion BlocksViews.ContextualMenu.MenuAction <-> UIAction.Identifier
        enum IdentifierConverter {
            static func action(for menuAction: BlocksViews.ContextualMenu.MenuAction) -> UIAction.Identifier? {
                menuAction.identifier.flatMap({UIAction.Identifier.init($0)})
            }
            static func menuAction(for identifier: UIAction.Identifier?) -> BlocksViews.ContextualMenu.MenuAction.Action? {
                identifier.flatMap({BlocksViews.ContextualMenu.MenuAction.Resources.IdentifierBuilder.action(for: $0.rawValue)})
            }
        }
        
        // MARK: Provider
        /// Actually, Self
        typealias Provider = BlocksViews.Base.ViewModel
        weak var provider: Provider?
        
        // MARK: Subject ( Subsribe on it ).
        var actionSubject: PassthroughSubject<BlocksViews.ContextualMenu.MenuAction.Action, Never> = .init()
        
        // MARK: Conversion BlocksViews.ContextualMenu and BlocksViews.ContextualMenu.MenuAction
        static func menu(from: BlocksViews.ContextualMenu?) -> UIMenu? {
            from.flatMap{ .init(title: $0.title, image: nil, identifier: nil, options: .init(), children: []) }
        }
        
        static func action(from action: BlocksViews.ContextualMenu.MenuAction, handler: @escaping (UIAction) -> ()) -> UIAction {
            .init(title: action.payload.title, image: action.payload.currentImage, identifier: IdentifierConverter.action(for: action), discoverabilityTitle: nil, attributes: [], state: .off, handler: handler)
        }
        
        // MARK: UIContextMenuInteractionDelegate
        func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
            .init(identifier: "" as NSCopying, previewProvider: nil) { [weak self] (value) -> UIMenu? in
                let menu = self?.provider?.buildContextualMenu()
                return menu.flatMap{
                    .init(title: $0.title, image: nil, identifier: nil, options: .init(), children: $0.children.map { [weak self] child in
                        ContextualMenuInteractor.action(from: child) { [weak self] (action) in
                            IdentifierConverter.menuAction(for: action.identifier).flatMap({self?.actionSubject.send($0)})
                        }
                    })
                }
            }
        }
    }
}

// MARK: Updates ( could be proposed in further releases ).
extension BlocksViews.Base.ViewModel {
    /// Update structure in natural `.with` way.
    /// - Parameters:
    ///   - value: a struct that you want to update
    ///   - body: block with updates.
    /// - Returns: new updated structure.
    private func update<T>(_ value: T, body: (inout T) -> ()) -> T {
        var value = value
        body(&value)
        return value
    }
}

/// Requirement: `Identifiable` is necessary for view model.
/// We use these models in plain way in `SwiftUI`.
extension BlocksViews.Base.ViewModel: Identifiable {}

/// Requirement: `BlockViewBuilderProtocol` is necessary for view model.
/// We use these models in wrapped (Row contains viewModel) way in `UIKit`.
extension BlocksViews.Base.ViewModel: BlockViewBuilderProtocol {
    var blockId: BlockID { getRealBlock().information.id }
    
    var id: IndexID { getID() }
    
    func buildView() -> AnyView { makeSwiftUIView() }
    func buildUIView() -> UIView {
        let view = makeUIView()
        if let delegate = self.contextualMenuDelegate, self.options.shouldAddContextualMenu {
            let interaction = UIContextMenuInteraction.init(delegate: delegate)
            view.addInteraction(interaction)
        }
        return view
    }
    
    var diffable: AnyHashable { .init("") }
}

/// Requirement: `BlocksViewsUserActionsEmittingProtocol` is necessary to subclasses of view model.
/// We could send events to `userActionPublisher`.
///
extension BlocksViews.Base.ViewModel: BlocksViewsUserActionsEmittingProtocol {
    func send(userAction: BlocksViews.UserAction) {
        self.userActionSubject.send(userAction)
    }
}

/// Requirement: `BlocksViewsUserActionsSubscribingProtocol` is necessary for routing and outer world.
/// We could subscribe on `userActionPublisher` and react on changes.
/// 
extension BlocksViews.Base.ViewModel: BlocksViewsUserActionsSubscribingProtocol {}

/// Requirement: `BlocksViewsUserActionsReceivingProtocol` is necessary for communication from outer space.
/// We could send events to blocks views to perform actions and get reactions.
///
extension BlocksViews.Base.ViewModel: BlocksViewsUserActionsReceivingProtocol {
    func receive(event: BlocksViews.UserEvent) {
        self.handle(event: event)
    }
}

// MARK: Holder
// This protocol may be deprecated.
// It is required for now to enable communication between updater and text user interactor and view model.
protocol BlocksViewsViewModelHolder {
    typealias ViewModel = BlocksViews.Base.ViewModel
    var ourViewModel: BlocksViews.Base.ViewModel { get }
}

// MARK: Legacy
extension BlocksViews.Base {
    /// Contains legacy entities.
    enum Utilities {}
}

