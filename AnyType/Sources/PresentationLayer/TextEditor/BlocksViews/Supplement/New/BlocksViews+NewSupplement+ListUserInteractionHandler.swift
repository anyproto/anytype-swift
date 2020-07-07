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

fileprivate typealias Namespace = BlocksViews.NewSupplement

private extension Logging.Categories {
    static let textEditorListUserInteractorHandler: Self = "TextEditor.ListUserInteractionHandler"
}

extension Namespace {
    class ListUserInteractionHandler {
        typealias ActionsPayload = DocumentModule.DocumentViewModel.ActionsPayload
        typealias ActionsPayloadToolbar = ActionsPayload.Toolbar.Action
        
        typealias Builder = BlocksModels.Block.Builder
        
        typealias Model = BlocksModelsChosenBlockModelProtocol
        typealias BlockId = BlocksModels.Aliases.BlockId
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

// MARK: BlockBuilder
/// This class should be moved to Middleware.
/// We don't care about business logic on THIS level.
extension Namespace.ListUserInteractionHandler {
    struct BlockBuilder {
        typealias BlockId = BlocksModels.Aliases.BlockId
        typealias Content = BlocksModels.Aliases.BlockContent
        typealias Information = BlocksModels.Aliases.Information.InformationModel

        typealias ToolbarAction = ActionsPayloadToolbar

        static func newBlockId() -> BlockId { "" }

        static func createInformation(block: Model, action: ToolbarAction, textPayload: String = "") -> Information? {
            switch action {
            case .addBlock: return self.createContentType(block: block, action: action, textPayload: textPayload).flatMap({(newBlockId(), $0)}).map(Information.init)
            default: return nil
            }
        }

        static func createDefaultInformation(block: Model? = nil) -> Information? {
            guard let block = block else {
                return .init(id: newBlockId(), content: .text(.empty()))
            }
            switch block.blockModel.information.content {
            case let .text(value):
                switch value.contentType {
                case .toggle: return .init(id: newBlockId(), content: .text(.empty()))
                default: return nil
                }
            case .smartblock: return .init(id: newBlockId(), content: .text(.empty()))
            default: return nil
            }
        }

        static func createContentType(block: Model, action: ToolbarAction, textPayload: String = "") -> Content? {
            switch action {
            case let .addBlock(blockType):
                switch blockType {
                case let .text(value):
                    switch value {
                    case .text: return .text(.init(contentType: .text))
                    case .h1: return .text(.init(contentType: .header))
                    case .h2: return .text(.init(contentType: .header2))
                    case .h3: return .text(.init(contentType: .header3))
                    case .highlighted: return .text(.init(contentType: .quote))
                    }
                case let .list(value):
                    switch value {
                    case .bulleted: return .text(.init(contentType: .bulleted))
                    case .checkbox: return .text(.init(contentType: .checkbox))
                    case .numbered: return .text(.init(contentType: .numbered))
                    case .toggle: return .text(.init(contentType: .toggle))
                    }
                case let .media(mediaType):
                    switch mediaType {
                    case .picture: return .file(.init(name: "", hash: "", state: .empty, contentType: .image))
                    case .bookmark: return nil
                    case .code: return nil
                    case .file: return nil
                    case .video: return nil
                    }
                case let .page(value):
                    switch value {
                    case .page: return .link(.init(targetBlockID: "", style: .page, fields: [:]))
                    default: return nil
                    }
                default: return nil
                }
            default: return nil
            }
        }
    }
}

// MARK: ServiceHandler
extension Namespace.ListUserInteractionHandler {

    /// Each method should return no a block, but a response.
    /// Next, this response would be proceed by event handler.
    class Service {
        typealias BlockId = BlocksModels.Aliases.BlockId
        typealias ListIds = [BlockId]

        private var documentId: String

        private let parser: BlocksModels.Parser = .init()
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
    typealias BlockContent = BlocksModels.Aliases.BlockContent
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
