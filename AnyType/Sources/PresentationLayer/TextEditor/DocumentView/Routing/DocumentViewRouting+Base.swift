//
//  DocumentViewRouting+Base.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 17.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine
import os

private extension Logging.Categories {
    static let documentViewRoutingBase: Self = "TextEditor.DocumentViewRouting.BaseRouter"
}

enum DocumentViewRouting {
    /// Base Router.
    /// It is base interface for all routers.
    /// It adopts necessary protocols and provide API for communication from outer world.
    /// If you would like to add router, it is the first place where you would like to start.
    /// Do not forget to subclass following methods:
    /// - `receive(action:)`
    ///
    class BaseRouter {
        // MARK: UserActions
        private var userActionsStreamSubscription: AnyCancellable?

        // MARK: Initialization
        init() {
            self.setupPublishers()
        }

        // MARK: Events
        @Published private var outputEvent: OutputEvent?
        public var outputEventsPublisher: AnyPublisher<OutputEvent, Never> = .empty()
        private func setupPublishers() {
            self.outputEventsPublisher = self.$outputEvent.safelyUnwrapOptionals().eraseToAnyPublisher()
        }

        // MARK: Subclassing
        /// This is the method that is called from `userActionsStream`.
        /// - Parameter action: An action of BlocksViews.UserAction events that is coming from outer world.
        ///
        func receive(action: BlocksViews.UserAction) {}

        // MARK: Configured
        func configured(userActionsStream: AnyPublisher<BlocksViews.UserAction, Never>) -> Self {
            self.userActionsStreamSubscription = userActionsStream.sink { [weak self] (value) in
                self?.receive(action: value)
            }
            return self
        }
    }
}

/// Requirement: `DocumentViewRoutingOutputProtocol` is necessary for sending events to outer world.
/// We use this protocol to gather events from routing in our view controller.
///
extension DocumentViewRouting.BaseRouter: DocumentViewRoutingOutputProtocol {}

/// Requirement: `DocumentViewRoutingSendingOutputProtocol` is necessary for sending events to outer world.
/// However, we use it `internally`. Do not call these methods from outer world.
///
extension DocumentViewRouting.BaseRouter: DocumentViewRoutingSendingOutputProtocol {
    func send(event: DocumentViewRouting.OutputEvent) {
        self.outputEvent = event
        // TODO: Redone on top of PassthroughSubject instead.
        let logger = Logging.createLogger(category: .documentViewRoutingBase)
        os_log(.debug, log: logger, "Do not forget to done it right. We shouldn't use this hack by setting nil to @Published variable. Use PassthroughSubject instead.")
        self.outputEvent = nil
    }
}

// MARK: BaseCompoundRouting
extension DocumentViewRouting {
    /// It is a collection of routers which captures all events from stored routers into its own `Publishers.MergeMany` publishers.
    /// It is necessary to subclass from this router if you would like to gather routers into a cluster.
    /// For example, if you have text routers, maybe you want to make them via cluster.
    /// So, the first place where you would start is this class.
    /// Do not forget to subclass following methods:
    /// - `.defaultRouters`
    /// - `match(action:)`
    ///
    class BaseCompoundRouter: BaseRouter {
        // MARK: Variables
        @Published private var routers: [BaseRouter] = []

        // MARK: Find
        /// Find router of concrete type which is subclass of our `BaseRouter`.
        /// - Parameter type: A subclass type of our `BaseRouter`.
        /// - Returns: A concrete router object which is stored in `.routers` collection.
        func router<T>(of type: T.Type) -> T? where T: BaseRouter {
            self.routers.filter({$0 is T}).first as? T
        }

        // MARK: Initialization
        override init() {
            super.init()
            _ = self.configured(routers: self.defaultRouters())
        }

        // MARK: Setup
        /// Setup routers by merging their `outputEventsPublisher` properties into one publisher.
        /// - Parameter routers: Routers which publishers will be merged into one publisher.
        private func setup(routers: [BaseRouter]) {
            self.outputEventsPublisher = Publishers.MergeMany(routers.map(\.outputEventsPublisher)).eraseToAnyPublisher()
        }

        // MARK: Subclassing

        /// Provide default routers.
        /// - Returns: Routers that will be stored in local collection.
        func defaultRouters() -> [BaseRouter] {
            []
        }

        /// Find correct custom router for a specific action.
        /// - Parameter action: Action for which we would like to find router.
        /// - Returns: Router that could handle specific action.
        func match(action: BlocksViews.UserAction) -> BaseRouter? { nil }

        // MARK: Configuration
        func configured(routers: [BaseRouter]) -> Self {
            self.routers = routers
            self.setup(routers: routers)
            return self
        }

        // MARK: Receive
        override func receive(action: BlocksViews.UserAction) {
            self.match(action: action).flatMap({$0.receive(action: action)})
        }
    }
}

// MARK: CompoundRouting
extension DocumentViewRouting {
    /// Compound router which you need to changed
    class CompoundRouter: BaseCompoundRouter {

        // MARK: Subclassing
        override func match(action: BlocksViews.UserAction) -> BaseRouter? {
            switch action {
            case let .specific(value):
                switch value {
                case .tool: return self.router(of: ToolsBlocksViewsRouter.self)
                case .file: return self.router(of: FileBlocksViewsRouter.self)
                default: return nil
                }
            case .toolbars: return self.router(of: ToolbarsRouter.self)
            default: return nil
            }
        }

        override func defaultRouters() -> [DocumentViewRouting.BaseRouter] {
            [ToolsBlocksViewsRouter(), FileBlocksViewsRouter(), ToolbarsRouter()]
        }
    }
}
