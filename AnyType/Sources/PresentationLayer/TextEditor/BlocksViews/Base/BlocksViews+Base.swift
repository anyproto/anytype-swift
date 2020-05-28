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

extension BlocksViews.Base {
    class ViewModel: ObservableObject {
        typealias BlockModel = BlockModels.Block.RealBlock
        typealias BlockModelReal = BlockModels.Block.RealBlock // has type .block
        typealias BlockModelID = BlockModels.Block.RealBlock.Index
        
        private var block: BlockModel
        
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
            }
        }
        
        // MARK: Events
        private var userActionSubject: PassthroughSubject<BlocksViews.UserAction, Never> = .init()
        // TODO: Rethink.
        // Do we need to store this publisher or we could rather return it from getter?
        public var userActionPublisher: AnyPublisher<BlocksViews.UserAction, Never> = .empty()
        private func setupPublishers() {
            self.userActionPublisher = self.userActionSubject.eraseToAnyPublisher()
            self.userActionPublisher.sink { (value) in
                print("I send value! \(value)")
            }.store(in: &self.subscriptions)
        }
        
        // MARK: Contextual Menu
        private var subscriptions: Set<AnyCancellable> = []
        private var contextualMenuInteractor: ContextualMenuInteractor = .init()
        weak var contextualMenuDelegate: UIContextMenuInteractionDelegate? { self.contextualMenuInteractor }
        
        private func setupSubscriptions() {
            self.contextualMenuInteractor.provider = self
            self.contextualMenuInteractor.actionSubject.sink { [weak self] (value) in
                self?.handle(contextualMenuAction: value)
            }.store(in: &self.subscriptions)
        }
        
        // MARK: Indentation
        func indentationLevel() -> UInt {
            self.getBlock().indentationLevel()
            //getID().section > 0 ? UInt(getID().section) : 0
        }
        
        // MARK: Subclass / Information
        var information: MiddlewareBlockInformationModel { block.information }
        
        // MARK: Subclass / Views
        func makeSwiftUIView() -> AnyView { .init(Text("")) }
        func makeUIView() -> UIView { .init() }
        
        // MARK: Subclass / Events
        func handle(event: BlocksViews.UserEvent) {}
        
        // MARK: Subclass / ContextualMenu
        func makeContextualMenu() -> BlocksViews.ContextualMenu { .init() }
        func handle(contextualMenuAction: BlocksViews.ContextualMenu.MenuAction.Action) {}
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
        if let delegate = self.contextualMenuDelegate {
            let interaction = UIContextMenuInteraction.init(delegate: delegate)
            view.addInteraction(interaction)
        }
        return view
    }
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

