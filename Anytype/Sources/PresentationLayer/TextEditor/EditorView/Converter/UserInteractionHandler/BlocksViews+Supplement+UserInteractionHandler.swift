//
//  BlocksViews+Supplement+UserInteractionHandler.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 10.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
import Combine
import os
import BlocksModels

fileprivate typealias Namespace = BlocksViews.Supplement

/// TODO:
/// Cleanup signatures of methods.
/// Most of them need only blockId, not full information about block.
///
private extension Logging.Categories {
    static let textEditorUserInteractorHandler: Self = "TextEditor.UserInteractionHandler"
}

extension Namespace {
    class UserInteractionHandler {
        typealias ActionsPayload = BlocksViews.New.Base.ViewModel.ActionsPayload
        typealias ActionsPayloadMarksPane = ActionsPayload.MarksPaneHolder.Action
        typealias ActionsPayloadToolbar = ActionsPayload.Toolbar.Action
        typealias ActionsPayloadTextViewTextView = ActionsPayload.TextBlocksViewsUserInteraction.Action.TextViewUserAction
        typealias ActionsPayloadTextViewButtonView = ActionsPayload.TextBlocksViewsUserInteraction.Action.ButtonViewUserAction
        typealias ActionsPayloadUserAction = ActionsPayload.UserActionHolder.Action
        
        typealias Builder = TopLevel.Builder
        typealias IndexWalker = LinearIndexWalker //TopLevel.AliasesMap.BlockUtilities.IndexWalker
        
        private var indexWalker: IndexWalker?
        
        typealias Model = BlockActiveRecordModelProtocol
        
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

/// MARK: Search
extension Namespace.UserInteractionHandler {
    func model(beforeModel: Model, includeParent: Bool) -> Model? {
        //        TopLevel.AliasesMap.BlockUtilities.IndexWalker.model(beforeModel: beforeModel, includeParent: includeParent)
        self.indexWalker?.renew()
        return self.indexWalker?.model(beforeModel: beforeModel, includeParent: includeParent)
    }
}

extension Namespace.UserInteractionHandler {
    enum Reaction {
        typealias Id = TopLevel.AliasesMap.BlockId
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
    func configured(_ model: EditorModule.Document.ViewController.ViewModel) -> Self {
        self.indexWalker = .init(DocumentModelListProvider.init(model: model))
        return self
    }
}

// MARK: TODO - Move to enum or wrap in another protocol
extension Namespace.UserInteractionHandler {
    func createEmptyBlock(listIsEmpty: Bool, parentModel: Model?) {
        if listIsEmpty {
            if let defaultBlock = BlockBuilder.createDefaultInformation() {
                self.service.addChild(childBlock: defaultBlock, parentBlockId: self.documentId)
            }
        }
        else {
            // Unknown for now.
            // Check that previous ( last block ) is not nil.
            // We must provide a smartblock of page to solve it.
            //
            guard let parentModel = parentModel else {
                // We don't have parentModel, so, we can't proceed.
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.debug, log: logger, "createEmptyBlock.listIsEmpty. We don't have parent model.")
                return
            }
            guard let lastChildId = parentModel.childrenIds().last else {
                // We don't have children, let's do nothing.
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.debug, log: logger, "createEmptyBlock.listIsEmpty. Children are empty.")
                return
            }
            guard let lastChild = parentModel.container?.choose(by: lastChildId) else {
                // No child - nothing to do.
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.debug, log: logger, "createEmptyBlock.listIsEmpty. Last child doesn't exist.")
                return
            }
            
            switch lastChild.blockModel.information.content {
            case let .text(value) where value.attributedText.length == 0:
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.debug, log: logger, "createEmptyBlock.listIsEmpty. Last block is text and it is empty. Skipping..")
                return
            default:
                if let defaultBlock = BlockBuilder.createDefaultInformation() {
                    self.service.addChild(childBlock: defaultBlock, parentBlockId: self.documentId)
                }
            }
        }
    }
}

// MARK: Actions Handling
extension Namespace.UserInteractionHandler {
    func didReceiveAction(action: ActionsPayload) {
        switch action {
        case let .toolbar(value): self.handlingToolbarAction(value.model, value.action)
        case let .marksPane(value): self.handlingMarksPaneAction(value.model, value.action)
        case let .textView(value):
            switch value.action {
            case let .textView(action): self.handlingTextViewAction(value.model, action)
            case let .buttonView(action): self.handlingButtonViewAction(value.model, action)
            }
        case let .userAction(value): self.handlingUserAction(value.model, value.action)
        }
        
    }
}

// MARK: Actions Handling / User Actions
private extension Namespace.UserInteractionHandler {
    func handlingUserAction(_ block: Model, _ action: ActionsPayloadUserAction) {
        switch action {
        case let .specific(.file(.file(.shouldUploadFile(value)))):
            self.service.upload(block: block.blockModel.information, filePath: value.filePath)
        case let .specific(.file(.image(.shouldUploadImage(value)))):
            self.service.upload(block: block.blockModel.information, filePath: value.filePath)
        default: return
        }
    }
}

// MARK: Actions Handling / MarksPane
private extension Namespace.UserInteractionHandler {
    func handlingMarksPaneAction(_ block: Model, _ action: ActionsPayloadMarksPane) {
        switch action {
        case let .backgroundColor(_, action):
            switch action {
            case let .setColor(value):
                /// Do stuff..
                self.service.setBackgroundColor(block: block.blockModel.information, color: value)
            }
        default: return
        }
    }
}

// MARK: Actions Handling / TextView / ButtonView
private extension Namespace.UserInteractionHandler {
    func handlingButtonViewAction(_ block: Model, _ action: ActionsPayloadTextViewButtonView) {
        switch action {
        case let .toggle(.toggled(value)):
            var block = block
            block.isToggled = value
        /// TODO:
        /// Configure event and send it.
        /// And send event that we need to recalculate all blocks below.
        /// Maybe it is "Toggle" event?
        case .toggle(.insertFirst):
            if let defaultBlock = BlockBuilder.createDefaultInformation(block: block) {
                self.service.addChild(childBlock: defaultBlock, parentBlockId: block.blockModel.information.id)
            }
        default: return
        }
    }
}

// MARK: Actions Handling / TextView / TextView
private extension Namespace.UserInteractionHandler {
    func handlingTextViewAction(_ block: Model, _ action: ActionsPayloadTextViewTextView) {
        switch action {
        case let .keyboardAction(value): self.handlingKeyboardAction(block, value)
        default:
            let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
            os_log(.debug, log: logger, "Unexpected: %@", String(describing: action))
        }
    }
}

// MARK: Actions Handling / TextView / Keyboard
private extension Namespace.UserInteractionHandler {
    private typealias DetailsInspector = TopLevel.AliasesMap.BlockUtilities.DetailsInspector
    func handlingKeyboardAction(_ block: Model, _ action: TextView.UserAction.KeyboardAction) {
        switch action {
        case let .pressKey(keyAction):
            if DetailsInspector.kind(of: block.blockModel.information.id) == .title {
                switch keyAction {
                case .enter, .enterWithPayload, .enterAtBeginning:
                    let id = block.blockModel.information.id
                    let (blockId, _) = TopLevel.AliasesMap.InformationUtilitiesDetailsBlockConverter.IdentifierBuilder.asDetails(id)
                    let block = block.container?.choose(by: blockId)
                    let parentId = block?.blockModel.information.id
                    
                    if let information = BlockBuilder.createDefaultInformation(), let parentId = parentId {
                        if block?.childrenIds().isEmpty == true {
                            self.service.addChild(childBlock: information, parentBlockId: parentId)
                        }
                        else {
                            let first = block?.childrenIds().first
                            self.service.add(newBlock: information, afterBlockId: first ?? "", position: .top, shouldSetFocusOnUpdate: true)
                        }
                    }
                    
                default: return
                }
                return
            }
            switch keyAction {
            // .enterWithPayload and .enterAtBeginning should be used with BlockSplit
            case let .enterWithPayload(left, payload):
                if let newBlock = BlockBuilder.createInformation(block: block, action: action, textPayload: payload ?? "") {
                    if let oldText = left {
                        self.service.split(block: block.blockModel.information, oldText: oldText, shouldSetFocusOnUpdate: true)
                    }
                    else {
                        self.service.add(newBlock: newBlock, afterBlockId: block.blockModel.information.id, shouldSetFocusOnUpdate: true)
                    }
                }
                
            case let .enterAtBeginning(payload): // we should assure ourselves about type of block.
                /// TODO: Fix it in TextView API.
                /// If payload is empty, so, handle it as .enter ( or .enter at the end )
                if payload?.isEmpty == true {
                    self.handlingKeyboardAction(block, .pressKey(.enter))
                    return
                }
                if let newBlock = BlockBuilder.createInformation(block: block, action: action, textPayload: payload ?? "") {
                    if payload != nil {
                        self.service.split(block: block.blockModel.information, oldText: "", shouldSetFocusOnUpdate: true)
                    }
                    else {
                        self.service.add(newBlock: newBlock, afterBlockId: block.blockModel.information.id, shouldSetFocusOnUpdate: true)
                    }
                }
                
            case .enter:
                // BUSINESS LOGIC:
                // We should check that if we are in `list` block and its text is `empty`, we should turn it into `.text`
                switch block.blockModel.information.content {
                case let .text(value) where [.bulleted, .numbered, .checkbox, .toggle].contains(value.contentType) && value.attributedText.string == "":
                    // Turn Into empty text block.
                    if let newContentType = BlockBuilder.createContentType(block: block, action: action, textPayload: value.attributedText.string) {
                        /// TODO: Add focus on this block.
                        self.service.turnInto(block: block.blockModel.information, type: newContentType, shouldSetFocusOnUpdate: true)
                    }
                default:
                    if let newBlock = BlockBuilder.createInformation(block: block, action: action, textPayload: "") {
                        /// TODO:
                        /// Uncomment when you are ready.
                        //                        self.service.add(newBlock: newBlock, afterBlockId: block.blockModel.information.id, shouldSetFocusOnUpdate: true)
                        let logger = Logging.createLogger(category: .todo(.remove("Remove after refactoring of set focus.")))
                        os_log(.debug, log: logger, "We should not use self.service.split here. Instead, we should self.service.add block. It is possible to swap them only after set focus total cleanup. Redo it.")
                        
                        switch block.blockModel.information.content {
                        case let .text(payload): let oldText = payload.attributedText.string
                            self.service.split(block: block.blockModel.information, oldText: oldText, shouldSetFocusOnUpdate: true)
                        default: return
                        }
                        
                    }
                }
                
            case .deleteWithPayload(_):
                // TODO: Add Index Walker
                // Add get previous block
                
                guard let previousModel = self.model(beforeModel: block, includeParent: true) else {
                    let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                    os_log(.debug, log: logger, "We can't find previous block to focus on at command .deleteWithPayload for block %@. Moving to .delete command.", block.blockModel.information.id)
                    self.handlingKeyboardAction(block, .pressKey(.delete))
                    return
                }
                
                let previousBlockId = previousModel.blockModel.information.id
                
                let position: EventListening.PackOfEvents.OurEvent.Focus.Payload.Position
                switch previousModel.blockModel.information.content {
                case let .text(value):
                    let length = value.attributedText.length
                    position = .at(length)
                default: position = .end
                }
                
                //                var newAttributedString: NSMutableAttributedString?
                //                switch (previousModel.blockModel.information.content, block.blockModel.information.content) {
                //                case let (.text(lhs), .text(rhs)):
                //                    let left = lhs.attributedText
                //                    newAttributedString = .init(attributedString: left)
                //                    let right = rhs.attributedText
                //                    newAttributedString?.append(right)
                //                default: break
                //                }
                
                //                let attributedString = newAttributedString
                
                self.service.merge(firstBlock: previousModel.blockModel.information, secondBlock: block.blockModel.information) { value in
                    .init(contextId: value.contextID, events: value.messages, ourEvents: [
                        //                        .setText(.init(payload: .init(blockId: previousBlockId, attributedString: attributedString))),
                        .setTextMerge(.init(payload: .init(blockId: previousBlockId))),
                        .setFocus(.init(payload: .init(blockId: previousBlockId, position: position)))
                    ])
                }
                break
                
            case .delete:
                self.service.delete(block: block.blockModel.information) { value in
                    guard let previousModel = self.model(beforeModel: block, includeParent: true) else {
                        let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                        os_log(.debug, log: logger, "We can't find previous block to focus on at command .delete for block %@", block.blockModel.information.id)
                        return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
                    }
                    let previousBlockId = previousModel.blockModel.information.id
                    return .init(contextId: value.contextID, events: value.messages, ourEvents: [
                        .setFocus(.init(payload: .init(blockId: previousBlockId, position: .end)))
                    ])
                }
            }
        }
    }
}
private extension Namespace.UserInteractionHandler {
    func handlingToolbarAction(_ block: Model, _ action: ActionsPayloadToolbar) {
        switch action {
        case let .addBlock(value):
            switch value {
            case .objects(.page):
                self.service.createPage(afterBlock: block.blockModel.information)
            default:
                if let newBlock = BlockBuilder.createInformation(block: block, action: action) {
                    /// Business logic.
                    /// If we create block that can capture focus ( text block in our case )
                    /// Do it!
                    var shouldSetFocusOnUpdate = false
                    if case .text = newBlock.content {
                        shouldSetFocusOnUpdate = true
                    }
                    self.service.add(newBlock: newBlock, afterBlockId: block.blockModel.information.id, shouldSetFocusOnUpdate: shouldSetFocusOnUpdate)
                }
            }
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
                self.service.turnInto(block: block.blockModel.information, type: type, shouldSetFocusOnUpdate: false)
                
            case let .list(value): // Set Text Style
                let type: Service.BlockContent
                switch value {
                case .bulleted: type = .text(.init(contentType: .bulleted))
                case .checkbox: type = .text(.init(contentType: .checkbox))
                case .numbered: type = .text(.init(contentType: .numbered))
                case .toggle: type = .text(.init(contentType: .toggle))
                }
                self.service.turnInto(block: block.blockModel.information, type: type, shouldSetFocusOnUpdate: false)
                
            case let .other(value): // Change divider style.
                let type: Service.BlockContent
                switch value {
                case .lineDivider: type = .divider(.init(style: .line))
                case .dotsDivider: type = .divider(.init(style: .dots))
                case .code: return
                }
                self.service.turnInto(block: block.blockModel.information, type: type, shouldSetFocusOnUpdate: false)
                
            case .objects(.page):
                let type: Service.BlockContent = .smartblock(.init(style: .page))
                self.service.turnInto(block: block.blockModel.information, type: type, shouldSetFocusOnUpdate: false)
                
            default:
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.debug, log: logger, "TurnInto for that style is not implemented %@", String(describing: action))
            }
            
        case let .editBlock(value):
            switch value {
            case .delete: self.handlingKeyboardAction(block, .pressKey(.delete))
            case .duplicate: self.service.duplicate(block: block.blockModel.information)
            }
        case let .bookmark(value):
            switch value {
            case let .fetch(value): self.service.bookmarkFetch(block: block.blockModel.information, url: value.absoluteString)
            }
        default: return
        }
    }
}

// MARK: BlockBuilder
/// This class should be moved to Middleware.
/// We don't care about business logic on THIS level.
private extension Namespace.UserInteractionHandler {
    struct BlockBuilder {
        typealias BlockId = TopLevel.AliasesMap.BlockId
        typealias Content = TopLevel.AliasesMap.BlockContent
        typealias Information = BlockInformationModelProtocol
        
        typealias Builder = TopLevel.Builder
        
        typealias KeyboardAction = ActionsPayloadTextViewTextView.KeyboardAction
        typealias ToolbarAction = ActionsPayloadToolbar
        
        static func newBlockId() -> BlockId { "" }
        
        static func createInformation(block: Model, action: KeyboardAction, textPayload: String) -> Information? {
            switch block.blockModel.information.content {
            case .text:
                return self.createContentType(block: block, action: action, textPayload: textPayload).flatMap({(newBlockId(), $0)}).map(Builder.blockBuilder.informationBuilder.build)
            default: return nil
            }
        }
        
        static func createInformation(block: Model, action: ToolbarAction, textPayload: String = "") -> Information? {
            switch action {
            case .addBlock: return self.createContentType(block: block, action: action, textPayload: textPayload).flatMap({(newBlockId(), $0)}).map(Builder.blockBuilder.informationBuilder.build)
            default: return nil
            }
        }
        
        static func createDefaultInformation(block: Model? = nil) -> Information? {
            guard let block = block else {
                return Builder.blockBuilder.informationBuilder.build(id: newBlockId(), content: .text(.empty()))
            }
            switch block.blockModel.information.content {
            case let .text(value):
                switch value.contentType {
                case .toggle: return Builder.blockBuilder.informationBuilder.build(id: newBlockId(), content: .text(.empty()))
                default: return nil
                }
            case .smartblock: return Builder.blockBuilder.informationBuilder.build(id: newBlockId(), content: .text(.empty()))
            default: return nil
            }
        }
        
        static func createContentType(block: Model, action: KeyboardAction, textPayload: String) -> Content? {
            switch block.blockModel.information.content {
            case let .text(blockType):
                switch blockType.contentType {
                case .bulleted where blockType.attributedText.string != "": return .text(.init(contentType: .bulleted))
                case .checkbox where blockType.attributedText.string != "": return .text(.init(contentType: .checkbox))
                case .numbered where blockType.attributedText.string != "": return .text(.init(contentType: .numbered))
                case .toggle where blockType.attributedText.string != "": return .text(.init(contentType: .toggle))
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
                case let .objects(mediaType):
                    switch mediaType {
                    case .page: return .link(.init(style: .page))
                    case .picture: return .file(.init(contentType: .image))
                    case .bookmark: return .bookmark(.empty())
                    case .file: return .file(.init(contentType: .file))
                    case .video: return .file(.init(contentType: .video))
                    case .linkToObject: return nil
                    }
                case let .other(value):
                    switch value {
                    case .lineDivider: return .divider(.init(style: .line))
                    case .dotsDivider: return .divider(.init(style: .dots))
                    case .code: return nil
                    }
                default: return nil
                }
            default: return nil
            }
        }
    }
}

// MARK: ServiceHandler
private extension Namespace.UserInteractionHandler {
    
    /// Each method should return no a block, but a response.
    /// Next, this response would be proceed by event handler.
    class Service {
        typealias Information = BlockInformationModelProtocol
        typealias BlockId = TopLevel.AliasesMap.BlockId
        typealias Conversion = (ServiceLayerModule.Success) -> (EventListening.PackOfEvents)
        
        struct Converter {
            struct Default {
                func callAsFunction(_ value: ServiceLayerModule.Success) -> EventListening.PackOfEvents {
                    .init(contextId: value.contextID, events: value.messages, ourEvents: [])
                }
                static let `default`: Self = .init()
                static func convert(_ value: ServiceLayerModule.Success) -> EventListening.PackOfEvents {
                    self.default(value)
                }
            }
            struct Add {
                func callAsFunction(_ value: ServiceLayerModule.Success) -> EventListening.PackOfEvents {
                    let addEntryMessage = value.messages.first { $0.value == .blockAdd($0.blockAdd) }
                    
                    guard let addedBlock = addEntryMessage?.blockAdd.blocks.first else {
                        return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
                    }
                    
                    let nextBlockId = addedBlock.id
                    
                    return .init(contextId: value.contextID, events: value.messages, ourEvents: [
                        .setFocus(.init(payload: .init(blockId: nextBlockId, position: .beginning)))
                    ])
                }
                static let `default`: Self = .init()
                static func convert(_ value: ServiceLayerModule.Success) -> EventListening.PackOfEvents {
                    self.default(value)
                }
            }
            struct Split {
                /// TODO: Remove it later.
                /// We don't need to navigate through middleware messages.
                /// Instead, we need to check a result of a invocation.
                /// Middleware should send us back two blocks.
                ///
                func callAsFunction(_ value: ServiceLayerModule.Success) -> EventListening.PackOfEvents {
                    /// Find added block.
                    let addEntryMessage = value.messages.first { $0.value == .blockAdd($0.blockAdd) }
                    guard let addedBlock = addEntryMessage?.blockAdd.blocks.first else {
                        let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                        os_log(.debug, log: logger, "blocks.split.afterUpdate can't find added block")
                        return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
                    }
                    
                    /// Find set children ids.
                    let setChildrenMessage = value.messages.first { $0.value == .blockSetChildrenIds($0.blockSetChildrenIds)}
                    guard let setChildrenEvent = setChildrenMessage?.blockSetChildrenIds else {
                        let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                        os_log(.debug, log: logger, "blocks.split.afterUpdate can't find set children event")
                        return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
                    }
                    
                    let addedBlockId = addedBlock.id
                    
                    /// Find a block after added block, because we insert previous block.
                    guard let addedBlockIndex = setChildrenEvent.childrenIds.firstIndex(where: { $0 == addedBlockId }) else {
                        let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                        os_log(.debug, log: logger, "blocks.split.afterUpdate can't find index of added block in children ids.")
                        return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
                    }
                    
                    /// If we are adding as bottom, we don't need to find block after added block.
                    /// Our addedBlockIndex is focused index.
                    let focusedIndex = addedBlockIndex
                    //setChildrenEvent.childrenIds.index(after: addedBlockIndex)
                    
                    /// Check that our childrenIds collection indices contains index.
                    guard setChildrenEvent.childrenIds.indices.contains(focusedIndex) else {
                        let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                        os_log(.debug, log: logger, "blocks.split.afterUpdate children ids doesn't contain index of focused block.")
                        return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
                    }
                    
                    let focusedBlockId = setChildrenEvent.childrenIds[focusedIndex]
                    
                    return .init(contextId: value.contextID, events: value.messages, ourEvents: [
                        .setFocus(.init(payload: .init(blockId: focusedBlockId, position: .beginning)))
                    ])
                }
                static let `default`: Self = .init()
                static func convert(_ value: ServiceLayerModule.Success) -> EventListening.PackOfEvents {
                    self.default(value)
                }
            }
            struct TurnInto {
                struct Text {
                    func callAsFunction(_ value: ServiceLayerModule.Success) -> EventListening.PackOfEvents {
                        let textMessage = value.messages.first { $0.value == .blockSetText($0.blockSetText) }
                        
                        guard let changedBlock = textMessage?.blockSetText else {
                            return .init(contextId: value.contextID, events: value.messages, ourEvents: [])
                        }
                        
                        let focusedBlockId = changedBlock.id
                        
                        return .init(contextId: value.contextID, events: value.messages, ourEvents: [
                            .setFocus(.init(payload: .init(blockId: focusedBlockId, position: .beginning)))
                        ])
                    }
                    static let `default`: Self = .init()
                    static func convert(_ value: ServiceLayerModule.Success) -> EventListening.PackOfEvents {
                        self.default(value)
                    }
                }
            }
            
            struct Delete {
                func callAsFunction(_ value: ServiceLayerModule.Success) -> EventListening.PackOfEvents {
                    .init(contextId: value.contextID, events: value.messages, ourEvents: [])
                }
                static let `default`: Self = .init()
                static func convert(_ value: ServiceLayerModule.Success) -> EventListening.PackOfEvents {
                    self.default(value)
                }
            }
        }
        
        private var documentId: String
        
        private var subscriptions: [AnyCancellable] = []
        private let service: ServiceLayerModule.Single.BlockActionsService = .init()
        private let pageService: ServiceLayerModule.SmartBlockActionsService = .init()
        private let textService: ServiceLayerModule.Text.BlockActionsService = .init()
        private let listService: ServiceLayerModule.List.BlockActionsService = .init()
        private let bookmarkService: ServiceLayerModule.Bookmark.BlockActionsService = .init()
        private let fileService: ServiceLayerModule.File.BlockActionsService = .init()
        
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
    }
}

// MARK: ServiceHandler / Actions / Add / Private
private extension Namespace.UserInteractionHandler.Service {
    func _add(newBlock: Information, afterBlockId: BlockId, position: BlocksModelsModule.Parser.Common.Position.Position = .bottom, _ completion: @escaping Conversion) {
        
        // insert block after block
        // we could catch events and update model.
        // or we could just update model after sending event.
        // for now we just update model on success.
        
        let targetId = afterBlockId
        
        self.service.add.action(contextID: self.documentId, targetID: targetId, block: newBlock, position: position).receive(on: RunLoop.main).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.error, log: logger, "blocksActions.service.add got error: %@", "\(error)")
            }
        }) { [weak self] (value) in
            let value = completion(value)
            self?.didReceiveEvent(value)
        }.store(in: &self.subscriptions)
    }
    
    
    func _split(block: Information, oldText: String, _ completion: @escaping Conversion) {
        let improve = Logging.createLogger(category: .todo(.improve("Markup")))
        os_log(.debug, log: improve, "You should update parameter `oldText`. It shouldn't be a plain `String`. It should be either `Int32` to reflect cursor position or it should be `NSAttributedString`." )
        
        // We are using old text as a cursor position.
        let blockId = block.id
        let position = oldText.count
        
        let content = block.content
        guard case let .text(type) = content else {
            let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
            os_log(.error, log: logger, "We have unsupported content type: %@", "\(String(describing: content))")
            return
        }
        
        let range: NSRange = .init(location: position, length: 0)
        
        self.textService.split.action(contextID: self.documentId, blockID: blockId, range: range, style: type.contentType).receive(on: RunLoop.main).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.error, log: logger, "blocksActions.service.split without payload got error: %@", "\(error)")
            }
        }, receiveValue: { [weak self] (value) in
            let value = completion(value)
            self?.didReceiveEvent(value)
        }).store(in: &self.subscriptions)
    }
    
    func _setTextAndSplit(block: Information, oldText: String, _ completion: @escaping Conversion) {
        let improve = Logging.createLogger(category: .todo(.improve("Markup")))
        os_log(.debug, log: improve, "You should update parameter `oldText`. It shouldn't be a plain `String`. It should be either `Int32` to reflect cursor position or it should be `NSAttributedString`." )
        
        let blockId = block.id
        // We are using old text as a cursor position.
        let position = oldText.count
        
        let content = block.content
        guard case let .text(type) = content else {
            let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
            os_log(.error, log: logger, "We have unsupported content type: %@", "\(String(describing: content))")
            return
        }
        
        let range: NSRange = .init(location: position, length: 0)
        
        let documentId = self.documentId
        
        self.textService.setText.action(contextID: documentId, blockID: blockId, attributedString: type.attributedText).flatMap({ [weak self] value in
            self?.textService.split.action(contextID: documentId, blockID: blockId, range: range, style: type.contentType) ?? .empty()
        }).sink { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.error, log: logger, "blocksActions.service.setTextAndSplit got error: %@", "\(error)")
            }
        } receiveValue: { [weak self] (value) in
            let value = completion(value)
            var theValue = value
            theValue.ourEvents = [.setTextMerge(.init(payload: .init(blockId: blockId)))] + theValue.ourEvents
            self?.didReceiveEvent(theValue)
        }.store(in: &self.subscriptions)        
    }
}

// MARK: ServiceHandler / Actions / Add
private extension Namespace.UserInteractionHandler.Service {
    func addChild(childBlock: Information, parentBlockId: BlockId) {
        // insert block as child to parent.
        self.add(newBlock: childBlock, afterBlockId: parentBlockId, position: .inner, shouldSetFocusOnUpdate: true)
    }
    
    func add(newBlock: Information, afterBlockId: BlockId, position: BlocksModelsModule.Parser.Common.Position.Position = .bottom, shouldSetFocusOnUpdate: Bool) {
        let conversion: Conversion = shouldSetFocusOnUpdate ? Converter.Add.convert : Converter.Default.convert
        _add(newBlock: newBlock, afterBlockId: afterBlockId, position: position, conversion)
    }
    
    func split(block: Information, oldText: String, shouldSetFocusOnUpdate: Bool) {
        let conversion: Conversion = shouldSetFocusOnUpdate ? Converter.Split.convert : Converter.Default.convert
        _setTextAndSplit(block: block, oldText: oldText, conversion)
    }
    
    func duplicate(block: Information) {
        let targetId = block.id
        let blockIds: [String] = [targetId]
        let position: BlocksModelsModule.Parser.Common.Position.Position = .bottom
        self.service.duplicate.action(contextID: self.documentId, targetID: targetId, blockIds: blockIds, position: position).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.error, log: logger, "blocksActions.service.duplicate got error: %@", "\(error)")
            }
        }) { [weak self] (value) in
            self?.didReceiveEvent(.init(contextId: value.contextID, events: value.messages))
        }.store(in: &self.subscriptions)
    }
    
    func createPage(afterBlock: Information, position: BlocksModelsModule.Parser.Common.Position.Position = .bottom) {
        
        let targetId = ""
        let details: DetailsInformationModelProtocol = TopLevel.Builder.detailsBuilder.informationBuilder.build(list: [
            .title(.init()),
            .iconEmoji(.init())
        ])
        
        self.pageService.createPage.action(contextID: self.documentId, targetID: targetId, details: details, position: position).receive(on: RunLoop.main).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return // move to this page
            case let .failure(error):
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.error, log: logger, "blocksActions.service.createPage with payload got error: %@", "\(error)")
            }
        }) { [weak self] (value) in
            self?.didReceiveEvent(.init(contextId: value.contextID, events: value.messages))
        }.store(in: &self.subscriptions)
    }
}

// MARK: ServiceHandler / Actions / Delete / Private
private extension Namespace.UserInteractionHandler.Service {
    func _delete(block: Information, _ completion: @escaping Conversion) {
        let blockIds = [block.id]
        self.service.delete.action(contextID: self.documentId, blockIds: blockIds).receive(on: RunLoop.main).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.error, log: logger, "blocksActions.service.delete without payload got error: %@", "\(error)")
            }
        }, receiveValue: { [weak self] value in
            let value = completion(value)
            self?.didReceiveEvent(value)
        }).store(in: &self.subscriptions)
    }
}

// MARK: ServiceHandler / Actions / Delete
private extension Namespace.UserInteractionHandler.Service {
    func delete(block: Information, completion: @escaping Conversion) {
        _delete(block: block, completion)
    }
    
    func merge(firstBlock: Information, secondBlock: Information, _ completion: @escaping Conversion = Converter.Default.convert) {
        let firstBlockId = firstBlock.id
        let secondBlockId = secondBlock.id
        
        self.textService.merge.action(contextID: self.documentId, firstBlockID: firstBlockId, secondBlockID: secondBlockId).receive(on: RunLoop.main).sink(receiveCompletion: { value in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.error, log: logger, "blocksActions.service.merge with payload got error: %@", "\(error)")
            }
        }, receiveValue: { [weak self] value in
            let value = completion(value)
            self?.didReceiveEvent(value)
        }).store(in: &self.subscriptions)
    }
}

// MARK: ServiceHandler / Actions / Turn Into / Private
/// TODO: Add Div and ConvertChildrenToPages
private extension Namespace.UserInteractionHandler.Service {
    typealias BlockContent = TopLevel.AliasesMap.BlockContent
    func _turnInto(block: Information, type: BlockContent, _ completion: @escaping Conversion = Converter.Default.convert) {
        switch type {
        case .text: self.setTextStyle(block: block, type: type, completion)
        case .smartblock: self.setPageStyle(block: block, type: type)
        case .divider: self.setDividerStyle(block: block, type: type, completion)
        default: return
        }
    }
    
    private func setDividerStyle(block: Information, type: BlockContent, _ completion: @escaping Conversion = Converter.Default.convert) {
        let blockId = block.id
        guard case let .divider(value) = type else {
            let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
            os_log(.error, log: logger, "SetDividerStyle content is not divider: %@", "\(String(describing: type))")
            return
        }
        
        let blocksIds = [blockId]
        
        self.listService.setDivStyle.action(contextID: self.documentId, blockIds: blocksIds, style: value.style).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.error, log: logger, "blocksActions.service.turnInto.setDivStyle got error: %@", "\(error)")
            }
        }) { [weak self] (value) in
            let value = completion(value)
            self?.didReceiveEvent(value)
        }.store(in: &self.subscriptions)
    }
    
    private func setPageStyle(block: Information, type: BlockContent) {
        let blockId = block.id
        
        guard case .smartblock = type else {
            let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
            os_log(.error, log: logger, "Set Page style cannot convert type: %@", "\(String(describing: type))")
            return
        }
                
        let blocksIds = [blockId]
        
        self.pageService.convertChildrenToPages.action(contextID: self.documentId, blocksIds: blocksIds).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.error, log: logger, "blocksActions.service.turnInto.convertChildrenToPages got error: %@", "\(error)")
            }
        }, receiveValue: { _ in }).store(in: &self.subscriptions)
    }
    
    private func setTextStyle(block: Information, type: BlockContent, _ completion: @escaping Conversion = Converter.Default.convert) {
        let blockId = block.id
        
        guard case let .text(text) = type else {
            let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
            os_log(.error, log: logger, "Set Text style content is not text style: %@", "\(String(describing: type))")
            return
        }
        
        self.textService.setStyle.action(contextID: self.documentId, blockID: blockId, style: text.contentType).receive(on: RunLoop.main).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.error, log: logger, "blocksActions.service.turnInto.setTextStyle got error: %@", "\(error)")
            }
        }) { [weak self] (value) in
            let value = completion(value)
            self?.didReceiveEvent(value)
        }.store(in: &self.subscriptions)
    }
}

// MARK: ServiceHandler / Actions / Turn Into
private extension Namespace.UserInteractionHandler.Service {
    func turnInto(block: Information, type: BlockContent, shouldSetFocusOnUpdate: Bool) {
        /// Also check for style later.
        let conversion: Conversion = shouldSetFocusOnUpdate ? Converter.TurnInto.Text.convert : Converter.Default.convert
        _turnInto(block: block, type: type, conversion)
    }
}

// MARK: ServiceHandler / Actions / BookmarkFetch
private extension Namespace.UserInteractionHandler.Service {
    private func _bookmarkFetch(block: Information, url: String, _ completion: @escaping Conversion = Converter.Default.convert) {
        let blockId = block.id
        self.bookmarkService.fetchBookmark.action(contextID: self.documentId, blockID: blockId, url: url).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.error, log: logger, "blocksActions.service.bookmarkFetch got error: %@", "\(error)")
            }
        }) { [weak self] (value) in
            let value = completion(value)
            self?.didReceiveEvent(value)
        }.store(in: &self.subscriptions)
    }
    
    func bookmarkFetch(block: Information, url: String) {
        self._bookmarkFetch(block: block, url: url)
    }
}

// MARK: ServiceHandler / Actions / SetBackgroundColor
private extension Namespace.UserInteractionHandler.Service {
    private func _setBackgroundColor(block: Information, color: UIColor?, _ completion: @escaping Conversion = Converter.Default.convert) {
        let blockId = block.id
        let blockIds = [blockId]
        let backgroundColor = color
        
        self.listService.setBackgroundColor.action(contextID: self.documentId, blockIds: blockIds, color: backgroundColor).sink(receiveCompletion: { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.error, log: logger, "listService.setBackgroundColor got error: %@", "\(error)")
            }
        }) { [weak self] (value) in
            let value = completion(value)
            self?.didReceiveEvent(value)
        }.store(in: &self.subscriptions)
    }
    
    func setBackgroundColor(block: Information, color: UIColor?) {
        self._setBackgroundColor(block: block, color: color)
    }
}

// MARK: ServiceHandler / Actions / UploadFile
private extension Namespace.UserInteractionHandler.Service {
    private func _upload(block: Information, filePath: String, _ completion: @escaping Conversion = Converter.Default.convert) {
        let blockId = block.id
        self.fileService.uploadDataAtFilePath.action(contextID: self.documentId, blockID: blockId, filePath: filePath).sink { (value) in
            switch value {
            case .finished: return
            case let .failure(error):
                let logger = Logging.createLogger(category: .textEditorUserInteractorHandler)
                os_log(.error, log: logger, "fileService.uploadDataAtFilePath got error: %@", "\(error)")
            }
        } receiveValue: { [weak self] (value) in
            let value = completion(value)
            self?.didReceiveEvent(value)
        }.store(in: &self.subscriptions)
    }
    func upload(block: Information, filePath: String) {
        self._upload(block: block, filePath: filePath)
    }
}
