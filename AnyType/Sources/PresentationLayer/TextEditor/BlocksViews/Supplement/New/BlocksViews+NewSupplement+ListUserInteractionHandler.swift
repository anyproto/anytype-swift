//
//  BlocksViews+NewSupplement+ListUserInteractionHandler.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 21.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import os
import SwiftProtobuf
import BlocksModels

fileprivate typealias Namespace = BlocksViews.NewSupplement

private extension Logging.Categories {
    static let textEditorListUserInteractorHandler: Self = "TextEditor.ListUserInteractionHandler"
}

extension Namespace {
    class ListUserInteractionHandler {
        typealias ActionsPayload = DocumentModule.DocumentViewModel.ActionsPayload
        typealias ActionsPayloadToolbar = ActionsPayload.Toolbar.Action
                
        typealias BlockId = TopLevel.AliasesMap.BlockId
        typealias ListModel = [BlockId]
        
        private var documentId: String = ""
        private var subscription: AnyCancellable?
                
        private let service: Service = .init(documentId: "")
        
        private var reactionSubject: PassthroughSubject<Reaction?, Never> = .init()
        var reactionPublisher: AnyPublisher<Reaction, Never> = .empty()
        
        init() {
            self.setup()
        }
        
        func setup() {
            self.reactionPublisher = self.reactionSubject.safelyUnwrapOptionals().eraseToAnyPublisher()
            _ = self.service.configured { [weak self] (value) in
                self?.reactionSubject.send(.shouldHandleEvent(.init(payload: .init(events: value))))
            }
        }
    }
}

extension Namespace.ListUserInteractionHandler {
    enum Reaction {
        struct ShouldHandleEvent {
            var payload: Payload
            struct Payload {
                var events: EventListening.PackOfEvents
            }
        }
        
        case shouldHandleEvent(ShouldHandleEvent)
    }
}

// MARK: Configuration
extension Namespace.ListUserInteractionHandler {
    func configured(documentId: String) -> Self {
        self.documentId = documentId
        _ = self.service.configured(documentId: documentId)
        return self
    }
    
    func configured(_ publisher: AnyPublisher<ActionsPayload, Never>) -> Self {
        self.subscription = publisher.sink { [weak self] (value) in
            self?.didReceiveAction(action: value)
        }
        return self
    }
}

// MARK: Actions Handling
extension Namespace.ListUserInteractionHandler {
    func didReceiveAction(action: ActionsPayload) {
        switch action {
        case let .toolbar(value): self.handlingToolbarAction(value.model, value.action)
        }
    }
}

extension Namespace.ListUserInteractionHandler {
    func handlingToolbarAction(_ model: ListModel, _ action: ActionsPayloadToolbar) {
        switch action {
        case let .addBlock(value): break
        case let .turnIntoBlock(value):
            // TODO: Add turn into
            switch value {
            case let .text(value): // Set Text Style
                let type: Service.BlockContent
                switch value {
                case .text: type = .text(.empty())
                case .h1: type = .text(.init(contentType: .header))
                case .h2: type = .text(.init(contentType: .header2))
                case .h3: type = .text(.init(contentType: .header3))
                case .highlighted: type = .text(.init(contentType: .quote))
                }
                self.service.turnInto(blocks: model, type: type)

            case let .list(value): // Set Text Style
                let type: Service.BlockContent
                switch value {
                case .bulleted: type = .text(.init(contentType: .bulleted))
                case .checkbox: type = .text(.init(contentType: .checkbox))
                case .numbered: type = .text(.init(contentType: .numbered))
                case .toggle: type = .text(.init(contentType: .toggle))
                }
                self.service.turnInto(blocks: model, type: type)

            case let .other(value): // Change divider style.
                break
            case .page: // Convert children to pages.
                let type: Service.BlockContent = .smartblock(.init(style: .page))
                self.service.turnInto(blocks: model, type: type)
            default:
                let logger = Logging.createLogger(category: .textEditorListUserInteractorHandler)
                os_log(.debug, log: logger, "TurnInto for that style is not implemented %@", String(describing: action))
            }

        case let .editBlock(value):
            switch value {
            case .delete: self.service.delete(model)
            default: return
            }
        default: return
        }
    }
}

// MARK: ServiceHandler
extension Namespace.ListUserInteractionHandler {

    /// Each method should return no a block, but a response.
    /// Next, this response would be proceed by event handler.
    class Service {
        typealias BlockId = TopLevel.AliasesMap.BlockId
        typealias ListIds = [BlockId]

        private var documentId: String

        private let parser: BlocksModelsModule.Parser = .init()
        private var subscriptions: [AnyCancellable] = []
        private let pageService: ServiceLayerModule.SmartBlockActionsService = .init()
        private let listService: ServiceLayerModule.BlockListActionsService = .init()

        private var didReceiveEvent: (EventListening.PackOfEvents) -> () = { _ in }

        init(documentId: String) {
            self.documentId = documentId
        }

        func configured(documentId: String) -> Self {
            self.documentId = documentId
            return self
        }

        func configured(didReceiveEvent: @escaping (EventListening.PackOfEvents) -> ()) -> Self {
            self.didReceiveEvent = didReceiveEvent
            return self
        }
    }
}

// MARK: ServiceHandler / Actions / Add
extension Namespace.ListUserInteractionHandler.Service {
}

// MARK: ServiceHandler / Actions / Delete
extension Namespace.ListUserInteractionHandler.Service {
    func delete(_ blocks: ListIds) {
        // Shit Swift
        let blocksIds = blocks
        // TODO: Add Delete List
        self.listService.delete.action(contextID: self.documentId, blocksIds: blocksIds).receive(on: RunLoop.main).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .textEditorListUserInteractorHandler)
                os_log(.error, log: logger, "blocksActions.service.delete without payload got error: %@", "\(error)")
            }
        }, receiveValue: { [weak self] value in
            self?.didReceiveEvent(.init(contextId: value.contextID, events: value.messages))
        }).store(in: &self.subscriptions)
    }
}

// MARK: ServiceHandler / Actions / Turn Into
/// TODO: Add Div and ConvertChildrenToPages
extension Namespace.ListUserInteractionHandler.Service {
    typealias BlockContent = TopLevel.AliasesMap.BlockContent
    
    func turnInto(blocks: ListIds, type: BlockContent) {
        switch type {
        case .text: self.setTextStyle(blocks: blocks, type: type)
        case let .smartblock(value): self.setPageStyle(blocks: blocks, type: type)
        case let .div(value): break
        default: return
        }
    }
    
    private func setPageStyle(blocks: ListIds, type: BlockContent) {
        
        guard let middlewareContent = self.parser.convert(content: type) else {
            let logger = Logging.createLogger(category: .textEditorListUserInteractorHandler)
            os_log(.error, log: logger, "Set Page style cannot convert type: %@", "\(String(describing: type))")
            return
        }
        
        guard case .smartblock = middlewareContent else {
            let logger = Logging.createLogger(category: .textEditorListUserInteractorHandler)
            os_log(.error, log: logger, "Set Page style content is not text style: %@", "\(String(describing: middlewareContent))")
            return
        }
        
        let blocksIds = blocks
        
        self.pageService.convertChildrenToPages.action(contextID: self.documentId, blocksIds: blocksIds).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .textEditorListUserInteractorHandler)
                os_log(.error, log: logger, "blocksActions.service.turnInto.convertChildrenToPages got error: %@", "\(error)")
            }
        }, receiveValue: { _ in }).store(in: &self.subscriptions)
    }

    private func setTextStyle(blocks: ListIds, type: BlockContent) {
        let blocksIds = blocks

        guard let middlewareContent = self.parser.convert(content: type) else {
            let logger = Logging.createLogger(category: .textEditorListUserInteractorHandler)
            os_log(.error, log: logger, "Set Text style cannot convert type: %@", "\(String(describing: type))")
            return
        }

        guard case let .text(middlewareTextStyle) = middlewareContent else {
            let logger = Logging.createLogger(category: .textEditorListUserInteractorHandler)
            os_log(.error, log: logger, "Set Text style content is not text style: %@", "\(String(describing: middlewareContent))")
            return
        }
        
        self.listService.setTextStyle.action(contextID: self.documentId, blockIds: blocksIds, style: middlewareTextStyle.style).receive(on: RunLoop.main).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .textEditorListUserInteractorHandler)
                os_log(.error, log: logger, "blocksActions.service.turnInto.setTextStyle with payload got error: %@", "\(error)")
            }
        }) { [weak self] (value) in
            self?.didReceiveEvent(.init(contextId: value.contextID, events: value.messages))
        }.store(in: &self.subscriptions)
    }
}
