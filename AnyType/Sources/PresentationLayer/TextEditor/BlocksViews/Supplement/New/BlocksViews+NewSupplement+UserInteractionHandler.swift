//
//  BlocksViews+NewSupplement+UserInteractionHandler.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 10.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import os
import SwiftProtobuf

fileprivate typealias Namespace = BlocksViews.NewSupplement

private extension Logging.Categories {
    static let treeTextBlocksUserInteractor: Self = "textEditor.treeTextBlocksUserInteractor"
}

extension Namespace {
    class UserInteractionHandler {
        typealias ActionsPayload = BlocksViews.New.Base.ViewModel.ActionsPayload
        typealias ActionsPayloadToolbar = ActionsPayload.Toolbar.Action
        typealias ActionsPayloadTextViewTextView = ActionsPayload.TextBlocksViewsUserInteraction.Action.TextViewUserAction
        typealias ActionsPayloadTextViewButtonView = ActionsPayload.TextBlocksViewsUserInteraction.Action.ButtonViewUserAction
        
        typealias Builder = BlocksModels.Block.Builder
        
        typealias Model = BlocksModelsChosenBlockModelProtocol
        
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

extension Namespace.UserInteractionHandler {
    enum Reaction {
        typealias Id = MiddlewareBlockInformationModel.Id
        struct Focus {
            var payload: Payload
            var position: Position = .unknown
            struct Payload {
                var blockId: Id
            }
            enum Position {
                case unknown, beginning, end, at(Int32)
            }
        }
        struct ShouldOpenPage {
            var payload: Payload
            struct Payload {
                var blockId: Id
            }
        }
        struct ShouldHandleEvent {
            var payload: Payload
            struct Payload {
                var events: EventListening.PackOfEvents
            }
        }
        
        case focus(Focus)
        case shouldOpenPage(ShouldOpenPage)
        case shouldHandleEvent(ShouldHandleEvent)
    }
}

// MARK: Configuration
extension Namespace.UserInteractionHandler {
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

// MARK: TODO - Move to enum or wrap in another protocol
extension Namespace.UserInteractionHandler {
    func createEmptyBlock(listIsEmpty: Bool) {
        if listIsEmpty {
            if let defaultBlock = BlockBuilder.createDefaultInformation() {
                self.service.addChild(childBlock: defaultBlock, parentBlockId: self.documentId)
            }
        }
        else {
            // Unknown for now.
        }
    }
}

// MARK: Actions Handling
extension Namespace.UserInteractionHandler {
    func didReceiveAction(action: ActionsPayload) {
        switch action {
        case let .toolbar(value): self.handlingToolbarAction(value.model, value.action)
        case let .textView(value):
            switch value.action {
            case let .textView(action): self.handlingTextViewAction(value.model, action)
            case let .buttonView(action): self.handlingButtonViewAction(value.model, action)
            }
        }
    }
}

// MARK: Actions Handling / TextView / ButtonView
private extension BlocksViews.NewSupplement.UserInteractionHandler {
    func handlingButtonViewAction(_ block: Model, _ action: ActionsPayloadTextViewButtonView) {
        switch action {
        case let .toggle(.toggled(value)):
            var block = block
            block.isToggled = value
        case .toggle(.insertFirst):
            if let defaultBlock = BlockBuilder.createDefaultInformation(block: block) {
                self.service.addChild(childBlock: defaultBlock, parentBlockId: block.blockModel.information.id)
            }
        default: return
        }
    }
}

// MARK: Actions Handling / TextView / TextView
private extension BlocksViews.NewSupplement.UserInteractionHandler {
    func handlingTextViewAction(_ block: Model, _ action: ActionsPayloadTextViewTextView) {
        switch action {
        case let .keyboardAction(value): self.handlingKeyboardAction(block, value)
        default:
            let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
            os_log(.debug, log: logger, "Unexpected: %@", String(describing: action))
        }
    }
}

// MARK: Actions Handling / TextView / Keyboard
private extension BlocksViews.NewSupplement.UserInteractionHandler {
    func handlingKeyboardAction(_ block: Model, _ action: TextView.UserAction.KeyboardAction) {
        switch action {
        case let .pressKey(keyAction):
            switch keyAction {
            // .enterWithPayload and .enterAtBeginning should be used with BlockSplit
            case let .enterWithPayload(left, payload):
                if let newBlock = BlockBuilder.createInformation(block: block, action: action, textPayload: payload ?? "") {
                    if let oldText = left {
                        self.service.split(block: block.blockModel.information, oldText: oldText)
                    }
                    else {
                        self.service.add(newBlock: newBlock, afterBlockId: block.blockModel.information.id)
                    }
                }

            case let .enterAtBeginning(payload): // we should assure ourselves about type of block.
                if let newBlock = BlockBuilder.createInformation(block: block, action: action, textPayload: payload ?? "") {
                    if payload != nil {
                        self.service.split(block: block.blockModel.information, oldText: "")
                    }
                    else {
                        self.service.add(newBlock: newBlock, afterBlockId: block.blockModel.information.id)
                    }
                }

            case .enter:
                // BUSINESS LOGIC:
                // We should check that if we are in `list` block and its text is `empty`, we should turn it into `.text`
                switch block.blockModel.information.content {
                case let .text(value) where [.bulleted, .numbered, .checkbox, .toggle].contains(value.contentType) && value.text == "":
                    // Turn Into empty text block.
                    // TODO: Add turn into
//                    if let newContentType = BlockBuilder.createContentType(for: block, id, action, value.text) {
//                        block.information.content = newContentType
//                        block.update(forced: true)
//                    }
                    break
                default:
                    if let newBlock = BlockBuilder.createInformation(block: block, action: action, textPayload: "") {
                        self.service.add(newBlock: newBlock, afterBlockId: block.blockModel.information.id)
                    }
                }

            case .deleteWithPayload(_):
                // TODO: Add Index Walker
                // Add get previous block
//                let beforeIndex = BlockModels.IndexWalker().index(beforeModel: block, includeParent: true)
//                guard let finder = self.finder else {
//                    let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
//                    os_log(.debug, log: logger, "finder not set")
//                    return
//                }
//
//                if let beforeBlock = finder.find(beforeIndex) {
//                    self.service.merge(documentId: self.documentId, firstBlock: beforeBlock, secondBlock: block) { [weak self] in
//                        if let blockId = self?.finder?.find(beforeIndex)?.information.id {
//                            self?.reaction = .focus(.init(payload: .init(blockId: blockId), position: .beginning))
//                        }
//                    }
//                }
//                else {
//                    // TODO: Add simple delete?
//                    // Maybe we should just delete?
//                    let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
//                    os_log(.debug, log: logger, "blocksActions.service.delete with payload model at index not found %@", "\(beforeIndex)")
//                }
                break

            case .delete:
                                
                self.service.delete(block: block.blockModel.information)
                // We should find previous index of block.
//                let beforeIndex = BlockModels.IndexWalker().index(beforeModel: block, includeParent: true)
//                guard self.finder != nil else {
//                    let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
//                    os_log(.debug, log: logger, "finder not set")
//                    return
//                }
//
//                // and next we should set focus on previous element.
//                self.service.delete(documentId: self.documentId, block: block) { [weak self] in
//                    if let blockId = self?.finder?.find(beforeIndex)?.information.id {
//                        self?.reaction = .focus(.init(payload: .init(blockId: blockId), position: .beginning))
//                    }
//                }
                break
            }
        }
    }
}
private extension BlocksViews.NewSupplement.UserInteractionHandler {
    func handlingToolbarAction(_ block: Model, _ action: ActionsPayloadToolbar) {
        switch action {
        case let .addBlock(value):
            switch value {
            case .page(.page):
                self.service.createPage(afterBlock: block.blockModel.information)
            default:
                if let newBlock = BlockBuilder.createInformation(block: block, action: action) {
                    self.service.add(newBlock: newBlock, afterBlockId: block.blockModel.information.id)
                }
            }
        case let .turnIntoBlock(value):
            // TODO: Add turn into
            break
        case let .editBlock(value):
            switch value {
            case .delete: self.handlingKeyboardAction(block, .pressKey(.delete))
            case .duplicate: self.service.duplicate(block: block.blockModel.information)
            }
        default: return
        }
    }
}

// MARK: BlockBuilder
/// This class should be moved to Middleware.
/// We don't care about business logic on THIS level.
private extension BlocksViews.NewSupplement.UserInteractionHandler {
    struct BlockBuilder {
        typealias BlockId = BlocksModels.Aliases.BlockId
        typealias Content = BlocksModels.Aliases.BlockContent
        typealias Information = BlocksModels.Aliases.Information.InformationModel
        
        typealias KeyboardAction = ActionsPayloadTextViewTextView.KeyboardAction
        typealias ToolbarAction = ActionsPayloadToolbar
        
        static func newBlockId() -> BlockId { "" }

        static func createInformation(block: Model, action: KeyboardAction, textPayload: String) -> Information? {
            switch block.blockModel.information.content {
            case .text:
                return self.createContentType(block: block, action: action, textPayload: textPayload).flatMap({(newBlockId(), $0)}).map(Information.init)
            default: return nil
            }
        }
            
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
        
        static func createContentType(block: Model, action: KeyboardAction, textPayload: String) -> Content? {
            switch block.blockModel.information.content {
            case let .text(blockType):
                switch blockType.contentType {
                case .bulleted where blockType.text != "": return .text(.init(contentType: .bulleted))
                case .checkbox where blockType.text != "": return .text(.init(contentType: .checkbox))
                case .numbered where blockType.text != "": return .text(.init(contentType: .numbered))
                case .toggle where blockType.text != "": return .text(.init(contentType: .toggle))
                default: return .text(.init(contentType: .text))
                }
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
private extension BlocksViews.NewSupplement.UserInteractionHandler {
    
    /// Each method should return no a block, but a response.
    /// Next, this response would be proceed by event handler.
    class Service {
        typealias Information = BlocksModelsInformationModelProtocol
        typealias BlockId = BlocksModels.Aliases.BlockId

        private var documentId: String
        
        private let parser: BlocksModels.Parser = .init()
        private var subscriptions: [AnyCancellable] = []
        private let service: ServiceLayerNewModel.BlockActionsService = .init()
        private let pageService: ServiceLayerNewModel.SmartBlockActionsService = .init()
        
        private var didReceiveEvent: (EventListening.PackOfEvents) -> () = { _ in }
        
        // We also need a handler of events.
        private let eventHandling: String = ""
        
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
        
        // MARK: Actions
        func addChild(childBlock: Information, parentBlockId: BlockId, position: Anytype_Model_Block.Position = .inner) {
            // insert block as child to parent.
            self.add(newBlock: childBlock, afterBlockId: parentBlockId, position: .inner)
        }
        
        func add(newBlock: Information, afterBlockId: BlockId, position: Anytype_Model_Block.Position = .bottom) {

            // insert block after block
            // we could catch events and update model.
            // or we could just update model after sending event.
            // for now we just update model on success.

            // Shit Swift
            guard let addedBlock = self.parser.convert(information: newBlock) else {
                let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                let addedBlock = self.parser.convert(information: newBlock)
                os_log(.error, log: logger, "addedBlock: %@ is nil? ", "\(String(describing: addedBlock))")
                return
            }

            let targetId = afterBlockId

            self.service.add.action(contextID: self.documentId, targetID: targetId, block: addedBlock, position: position).receive(on: RunLoop.main).sink(receiveCompletion: { (value) in
                switch value {
                case .finished: return
                case let .failure(error):
                    let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                    os_log(.error, log: logger, "blocksActions.service.add got error: %@", "\(error)")
                }
            }) { [weak self] (value) in
                self?.didReceiveEvent(.init(contextId: value.contextID, events: value.messages))
            }.store(in: &self.subscriptions)
        }


        func split(block: Information, oldText: String) {
            let improve = Logging.createLogger(category: .todo(.improve("Markup")))
            os_log(.debug, log: improve, "You should update parameter `oldText`. It shouldn't be a plain `String`. It should be either `Int32` to reflect cursor position or it should be `NSAttributedString`." )

            guard let splittedBlockInformation = self.parser.convert(information: block) else {
                let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                let splittedBlock = self.parser.convert(information: block)
                os_log(.error, log: logger, "deletedBlock: %@ is nil? ", "\(String(describing: splittedBlock))")
                return
            }

            // We are using old text as a cursor position.
            let position = Int32(oldText.count)

            let content = splittedBlockInformation.content
            guard case let .text(type) = content else {
                let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                os_log(.error, log: logger, "We have unsupported content type: %@", "\(String(describing: content))")
                return
            }

            self.service.split.action(contextID: self.documentId, blockID: splittedBlockInformation.id, cursorPosition: position, style: type.style).receive(on: RunLoop.main).sink(receiveCompletion: { (value) in                
                switch value {
                case .finished: return
                case let .failure(error):
                    let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                    os_log(.error, log: logger, "blocksActions.service.split without payload got error: %@", "\(error)")
                }
            }, receiveValue: { [weak self] (value) in
                self?.didReceiveEvent(.init(contextId: value.contextID, events: value.messages))
            }).store(in: &self.subscriptions)
        }
        
        func duplicate(block: Information) {
            let targetId = block.id
            let blockIds: [String] = [targetId]
            let position: Anytype_Model_Block.Position = .bottom
            self.service.duplicate.action(contextID: self.documentId, targetID: targetId, blockIds: blockIds, position: position).sink(receiveCompletion: { (value) in
                switch value {
                case .finished: return
                case let .failure(error):
                    let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                    os_log(.error, log: logger, "blocksActions.service.duplicate got error: %@", "\(error)")
                }
            }) { [weak self] (value) in
                self?.didReceiveEvent(.init(contextId: value.contextID, events: value.messages))
            }.store(in: &self.subscriptions)
        }

        func delete(block: Information) {
            // Shit Swift
            guard let deletedBlock = self.parser.convert(information: block) else {
                let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                let deletedBlock = self.parser.convert(information: block)
                os_log(.error, log: logger, "deletedBlock: %@ is nil? ", "\(String(describing: deletedBlock))")
                return
            }

            self.service.delete.action(contextID: self.documentId, blockIds: [deletedBlock.id]).receive(on: RunLoop.main).sink(receiveCompletion: { (value) in
                switch value {
                case .finished: return
                case let .failure(error):
                    let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                    os_log(.error, log: logger, "blocksActions.service.delete without payload got error: %@", "\(error)")
                }
            }, receiveValue: { [weak self] value in
                self?.didReceiveEvent(.init(contextId: value.contextID, events: value.messages))
            }).store(in: &self.subscriptions)
        }

        func merge(firstBlock: Information, secondBlock: Information) {
            let firstInformation = self.parser.convert(information: firstBlock)
            let secondInformation = self.parser.convert(information: secondBlock)

            guard let firstBlockId = firstInformation?.id, let secondBlockId = secondInformation?.id else {
                let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                os_log(.error, log: logger, "firstBlock: %@ or secondBlock: %@ are nil? ", "\(String(describing: firstInformation))", "\(String(describing: secondInformation))")
                return
            }

            self.service.merge.action(contextID: self.documentId, firstBlockID: firstBlockId, secondBlockID: secondBlockId).receive(on: RunLoop.main).sink(receiveCompletion: { value in
                switch value {
                case .finished: return
                case let .failure(error):
                    let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                    os_log(.error, log: logger, "blocksActions.service.merge with payload got error: %@", "\(error)")
                }
            }, receiveValue: { [weak self] value in
                self?.didReceiveEvent(.init(contextId: value.contextID, events: value.messages))
            }).store(in: &self.subscriptions)
        }

        func createPage(afterBlock: Information, position: Anytype_Model_Block.Position = .bottom) {

            let targetId = ""
            let details: Google_Protobuf_Struct = .init()

            self.pageService.createPage.action(contextID: self.documentId, targetID: targetId, details: details, position: position).receive(on: RunLoop.main).sink(receiveCompletion: { (value) in
                switch value {
                case .finished: return // move to this page
                case let .failure(error):
                    let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                    os_log(.error, log: logger, "blocksActions.service.createPage with payload got error: %@", "\(error)")
                }
            }) { [weak self] (value) in
                self?.didReceiveEvent(.init(contextId: value.contextID, events: value.messages))
            }.store(in: &self.subscriptions)
        }
    }
}
