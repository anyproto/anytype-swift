//
//  DocumentModule+ContainerViewController+ViewModel.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 01.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine

fileprivate typealias Namespace = DocumentModule
fileprivate typealias FileNamespace = Namespace.ContainerViewController

// MARK: Actions
extension FileNamespace.ViewModel {
    enum Action {
        typealias Document = DocumentModule.ContainerViewBuilder.UIKitBuilder.ChildComponent
        case show(UIViewController)
        case child(UIViewController)
        case showDocument(Document)
        case childDocument(Document)
        case pop
    }
}

// MARK: RouterProcessor
extension FileNamespace.ViewModel {
    private class RoutingProcessor {
        /// Aliases
        typealias IncomingEvent = DocumentViewRouting.OutputEvent
        typealias UserAction = Action
        typealias DocumentRequest = DocumentModule.ContainerViewBuilder.Request
        
        /// Variables
        private var subscription: AnyCancellable?
        private var userActionSubject: PassthroughSubject<UserAction, Never> = .init()
        fileprivate var userAction: AnyPublisher<UserAction, Never> = .empty()
        
        /// TODO: Maybe extract to some entity
        func build(_ request: DocumentRequest) -> DocumentModule.ContainerViewBuilder.UIKitBuilder.ChildComponent {
            let component = DocumentModule.ContainerViewBuilder.UIKitBuilder.childComponent(by: request)
            /// Next, we should configure router and, well, we should configure navigation item, of course...
            /// But we don't know anything about navigation item here...
            /// We could ask ViewModel to configure and then send this event to view controller.
            return component
        }
        
        /// Processing
        func process(_ value: IncomingEvent) {
            switch value {
            case let .general(value):
                switch value {
                case let .show(value): self.userActionSubject.send(.show(value))
                case let .child(value): self.userActionSubject.send(.child(value))
                }
            case let .document(value):
                switch value {
                case let .show(value):
                    let viewController = self.build(.init(id: value.documentRequest.id))
                    self.userActionSubject.send(.showDocument(viewController))
                case let .child(value):
                    let viewController = self.build(.init(id: value.documentRequest.id))
                    self.userActionSubject.send(.childDocument(viewController))
                }
            }
        }
        
        /// Initialization
        init() {
            self.userAction = self.userActionSubject.eraseToAnyPublisher()
        }
        
        /// Configurations
        func configured(_ eventsPublisher: AnyPublisher<IncomingEvent, Never>?) {
            self.subscription = eventsPublisher?.sink(receiveValue: { [weak self] (value) in
                self?.process(value)
            })
        }
    }
}

// MARK: ViewModel
extension FileNamespace {
    class ViewModel {
        /// Keep router and routing processor in one place.
        private var router: DocumentViewRoutingOutputProtocol?
        private var routingProcessor: RoutingProcessor = .init()
        
        private var subscription: AnyCancellable?
        /// And publish on actions that associated controller will handle.
        func actionPublisher() -> AnyPublisher<Action, Never> {
            self.routingProcessor.userAction.map { [weak self] value -> Action in
                switch value {
                case let .childDocument(value):
                    let viewModel = value.2.1
//                    _ = self?.configured(userActionsStream: viewModel.soloUserActionPublisher)
                    return .childDocument(value)
                case let .showDocument(value):
                    let viewModel = value.2.1
//                    _ = self?.configured(userActionsStream: viewModel.soloUserActionPublisher)
                    return .showDocument(value)
                default: return value
                }
            }.eraseToAnyPublisher()
        }        
    }
}

// MARK: Configurations
extension FileNamespace.ViewModel {
    func configured(router: DocumentViewRoutingOutputProtocol?) -> Self {
        self.router = router
        self.routingProcessor.configured(self.router?.outputEventsPublisher)
        return self
    }
    
    func configured(userActionsStream: DocumentViewRouting.BaseRouter.UserActionPublisher) -> Self {
        let router = (self.router as? DocumentViewRouting.BaseRouter)
        _ = router?.configured(userActionsStream: userActionsStream)
        return self
    }
    
    func configured(userActionsStreamStream: DocumentViewRouting.BaseRouter.UserActionPublisherPublisher) -> Self {
        let router = (self.router as? DocumentViewRouting.BaseRouter)
        _ = router?.configured(userActionsStreamStream: userActionsStreamStream)
        return self
    }
    
    func forcedConfigured(userActionsStream: DocumentViewRouting.BaseRouter.UserActionPublisher) {
        let router: DocumentViewRouting.CompoundRouter = .init()
        _ = self.configured(router: router)
        _ = router.configured(userActionsStream: userActionsStream)
    }
}

