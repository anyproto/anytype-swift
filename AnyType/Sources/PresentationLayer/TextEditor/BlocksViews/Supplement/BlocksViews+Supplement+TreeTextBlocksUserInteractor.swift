//
//  BlocksViews+Supplement+TreeTextBlocksUserInteractor.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 25.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import os
import SwiftProtobuf

private extension Logging.Categories {
    static let treeTextBlocksUserInteractor: Self = "textEditor.treeTextBlocksUserInteractor"
}

extension BlocksViews.Supplement {
    class TreeTextBlocksUserInteractor<T: BlocksViewsViewModelHolder> {
        private var documentId: String?
        private var toggleStorage: InMemoryStoreFacade.BlockLocalStore? { InMemoryStoreFacade.shared.blockLocalStore }
        private var finder: BlockModels.Finder<BlockModels.Block.RealBlock>?
        private var subscriptions: [AnyCancellable] = []

        private let service: Service<T>

        typealias Index = BusinessBlock.Index
        typealias Model = BlockModels.Block.RealBlock

        @Published var reaction: Reaction = .unknown

        var updater: TreeUpdater<T>

        init(_ value: T) {
            self.updater = .init(value: value)
            self.service = .init(value)
        }

        init(_ value: TreeUpdater<T>) {
            self.updater = value
            self.service = .init(value)
        }
    }
}

extension BlocksViews.Supplement.TreeTextBlocksUserInteractor {
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
        case unknown, focus(Focus), shouldOpenPage(ShouldOpenPage)
    }
}

// MARK: Configuration
extension BlocksViews.Supplement.TreeTextBlocksUserInteractor {
    func update(documentId: String?) {
        self.documentId = documentId
    }

    func update(finder: BlockModels.Finder<BlockModels.Block.RealBlock>) {
        self.finder = finder
    }

    func configured(documentId: String?) -> Self {
        self.update(documentId: documentId)
        return self
    }

    func configured(finder: BlockModels.Finder<BlockModels.Block.RealBlock>) -> Self {
        self.update(finder: finder)
        return self
    }
}

// MARK: TODO - Move to enum or wrap in another protocol
extension BlocksViews.Supplement.TreeTextBlocksUserInteractor {
    func createEmptyBlock(listIsEmpty: Bool) {
        if listIsEmpty {
            let information: BlockModels.Block.Information = .init(id: "", content: .text(.empty()))
            let newBlock: Model = .init(information: information, true)
            let afterInformation: BlockModels.Block.Information = .init(id: "", content: .text(.empty()))
            let afterBlock: Model = .init(information: afterInformation, false)

            /// You would like to insert object at first position, but this object don't have siblings. It is the only one child. First child.
            /// Ok, you have to configure rootId of a tree. It is an entry point of the model.
            /// Next, you create first index for an object at position at 0.
            /// Final IndexPath would be [1, 0]
            /// Element at first level with position 0.
            ///
            afterBlock.indexPath = BlockModels.Utilities.IndexGenerator.rootID()
            let desiredIndexPath = afterBlock.createIndex(for: 0)
            afterBlock.indexPath = desiredIndexPath
            self.service.add(documentId: self.documentId, newBlock: newBlock, afterBlock: afterBlock, position: .top)
        }
        else {
            // Unknown for now.
        }
    }
}

// MARK: TextBlocksViewsUserInteractionProtocol
extension BlocksViews.Supplement.TreeTextBlocksUserInteractor: TextBlocksViewsUserInteractionProtocol {
    /// Process/Receive actions as TextView.UserAction enumeration.
    ///
    /// This process
    ///
    /// - Parameters:
    ///   - block: A block model that sends event.
    ///   - id: A corresponding identifier of block model.
    ///   - action: An action that user interaction delegate of TextView sends.
    func didReceiveAction(block: Model, id: Index, action: TextView.UserAction) {
        switch action {
        case let .blockAction(action): self.handlingBlockAction(block, id, action)
        case let .keyboardAction(action): self.handlingKeyboardAction(block, id, action)

        case let .marksAction(value):
            let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
            os_log(.debug, log: logger, "Do not forget to implement: %@", String(describing: value))
        case let .inputAction(value):
            let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
            os_log(.debug, log: logger, "Do not forget to implement: %@", String(describing: value))
        
        case let .addBlockAction(value):
            let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
            os_log(.debug, log: logger, "Do not forget to implement: %@", String(describing: value))
        case let .showMultiActionMenuAction(value):
            let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
            os_log(.debug, log: logger, "Do not forget to implement: %@", String(describing: value))

        }
    }

    /// Process/Receive actions as TextBlocksViews.UserInteraction enumeration.
    ///
    /// You may read about purpose of enum in documentation.
    ///
    /// - Parameters:
    ///   - block: A block model that sends event.
    ///   - id: A corresponding identifier of block model.
    ///   - action: An action that user interaction delegate sends.
    func didReceiveAction(block: Model, id: Index, generalAction action: TextBlocksViews.UserInteraction) {
        switch action {

        /// case When we press button in textView if textView.children.isEmpty
        case .buttonView(.toggle(.insertFirst(_))):
            let firstChildIndex = block.createIndex(for: 0)
            let fullChildIndex = block.getFullIndex() + [firstChildIndex]
            self.updater.insert(block: .init(information: .init(id: BlockBuilder.newBlockId(), content: .text(.empty()))), at: fullChildIndex)
            return // self.updater.insertChild

        /// case When we press toggle button to fold/unfold children.
        case let .buttonView(.toggle(.toggled(value))):
            // TODO: move to someone who could update toggle value(?)
            var store = self.toggleStorage
            store?[.init(blockId: block.information.id)] = .init(toggled: value)
            block.update(forced: true)
            // we should update value in toggle (?)
            return // self.updater.update(block)

        /// case When TextView sends events.
        case .textView(let value): self.didReceiveAction(block: block, id: id, action: value)
        default: return
        }
    }
}

// MARK: Handling / KeyboardAction
private extension BlocksViews.Supplement.TreeTextBlocksUserInteractor {
    func handlingKeyboardAction(_ block: Model, _ id: Index, _ action: TextView.UserAction.KeyboardAction) {
        switch action {
        case let .pressKey(keyAction):
            switch keyAction {
            // .enterWithPayload and .enterAtBeginning should be used with BlockSplit
            case let .enterWithPayload(left, payload):
                if let newBlock = BlockBuilder.createBlock(for: block, id, action, payload ?? "") {
                    if let oldText = left {
                        self.service.split(documentId: self.documentId, block: block, oldText: oldText, newBlock: newBlock) { [weak self] value in
                            let blockId = value.information.id
                            self?.reaction = .focus(.init(payload: .init(blockId: blockId), position: .beginning))
                        }
                    }
                    else {
                        self.service.add(documentId: self.documentId, newBlock: newBlock, afterBlock: block)
                    }
                }
                
            case let .enterAtBeginning(payload): // we should assure ourselves about type of block.
                if let newBlock = BlockBuilder.createBlock(for: block, id, action, payload ?? "") {
                    if let payload = payload {
                        self.service.split(documentId: self.documentId, block: block, oldText: "", newBlock: newBlock) { [weak self] value in
                            let blockId = value.information.id
                            self?.reaction = .focus(.init(payload: .init(blockId: blockId), position: .beginning))
                        }
                    }
                    else {
                        self.service.add(documentId: self.documentId, newBlock: newBlock, afterBlock: block)
                    }
                }
                
            case .enter:
                // BUSINESS LOGIC:
                // We should check that if we are in `list` block and its text is `empty`, we should turn it into `.text`
                switch block.information.content {
                case let .text(value) where [.bulleted, .numbered, .todo, .toggle].contains(value.contentType) && value.text == "":
                    // Turn Into empty text block.
                    if let newContentType = BlockBuilder.createContentType(for: block, id, action, value.text) {
                        block.information.content = newContentType
                        block.update(forced: true)
                    }
                default:
                    if let newBlock = BlockBuilder.createBlock(for: block, id, action, "") {
                        self.service.add(documentId: self.documentId, newBlock: newBlock, afterBlock: block) { [weak self] value in
                            let blockId = value.information.id
                            self?.reaction = .focus(.init(payload: .init(blockId: blockId), position: .beginning))
                        }
                    }
                }
                
            case .deleteWithPayload(_):
                // Add get previous block
                let beforeIndex = BlockModels.IndexWalker().index(beforeModel: block, includeParent: true)
                guard let finder = self.finder else {
                    let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                    os_log(.debug, log: logger, "finder not set")
                    return
                }

                if let beforeBlock = finder.find(beforeIndex) {
                    self.service.merge(documentId: self.documentId, firstBlock: beforeBlock, secondBlock: block) { [weak self] in
                        if let blockId = self?.finder?.find(beforeIndex)?.information.id {
                            self?.reaction = .focus(.init(payload: .init(blockId: blockId), position: .beginning))
                        }
                    }
                }
                else {
                    // TODO: Add simple delete?
                    // Maybe we should just delete?
                    let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                    os_log(.debug, log: logger, "blocksActions.service.delete with payload model at index not found %@", "\(beforeIndex)")
                }
                
            case .delete:
                // We should find previous index of block.
                let beforeIndex = BlockModels.IndexWalker().index(beforeModel: block, includeParent: true)
                guard self.finder != nil else {
                    let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                    os_log(.debug, log: logger, "finder not set")
                    return
                }

                // and next we should set focus on previous element.
                self.service.delete(documentId: self.documentId, block: block) { [weak self] in
                    if let blockId = self?.finder?.find(beforeIndex)?.information.id {
                        self?.reaction = .focus(.init(payload: .init(blockId: blockId), position: .beginning))
                    }
                }
            }
        }
    }
}

// MARK: ServiceHandler
private extension BlocksViews.Supplement.TreeTextBlocksUserInteractor {
    class Service<T: BlocksViewsViewModelHolder> {
        typealias TreeUpdater = BlocksViews.Supplement.TreeUpdater
        typealias Model = BlockModels.Block.RealBlock

        private let parser: BlockModels.Parser = .init()
        private var subscriptions: [AnyCancellable] = []
        private let service: BlockActionsService = .init()
        private let pageService: SmartBlockActionsService = .init()
        private let updater: TreeUpdater<T>

        init(_ value: T) {
            self.updater = .init(value: value)
        }

        init(_ value: TreeUpdater<T>) {
            self.updater = value
        }
        func add(documentId: String?, newBlock: Model, afterBlock: Model, position: Anytype_Model_Block.Position = .bottom, completion: @escaping (Model) -> () = {_ in}) {

            // insert block after block
            // we could catch events and update model.
            // or we could just update model after sending event.
            // for now we just update model on success.

            // Shit Swift
            let documentID = documentId
            guard let documentId = documentId, let addedBlock = self.parser.convert(information: newBlock.information) else {
                let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                let addedBlock = self.parser.convert(information: newBlock.information)
                os_log(.error, log: logger, "documentId: %@ or addedBlock: %@ are nil? ", "\(String(describing: documentID))", "\(String(describing: addedBlock))")
                return
            }

            let targetId = afterBlock.information.id

            self.service.add.action(contextID: documentId, targetID: targetId, block: addedBlock, position: position).receive(on: RunLoop.main).sink(receiveCompletion: { (value) in
                switch value {
                case .finished: return
                case let .failure(error):
                    let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                    os_log(.error, log: logger, "blocksActions.service.add got error: %@", "\(error)")
                }
            }) { [weak self] (value) in
                let ourNewBlock = newBlock
                ourNewBlock.information.id = value.blockID

                /// Look at this logic.
                /// else clause is obvious. You want to insert an object `after` some position.
                /// For exampe, you would like to insert object `after` 0.
                /// It means that new position will be equal to 1.
                /// [a]
                /// [a, b]
                /// Nice.
                ///
                /// Now look at if clause. You want to insert an object `above` some position.
                /// For example, you would like to insert object `before` 0.
                /// It means that new position will be equal to 0.
                /// [b]
                /// [a, b]
                ///

                if position == .top {
                    self?.updater.insert(block: ourNewBlock, at: afterBlock.getFullIndex())
                    completion(ourNewBlock)
                }
                else {
                    self?.updater.insert(block: ourNewBlock, afterBlock: afterBlock.getFullIndex())
                    completion(ourNewBlock)
                }
            }.store(in: &self.subscriptions)
        }


        func split(documentId: String?, block: Model, oldText: String, newBlock: Model, completion: @escaping (Model) -> () = {_ in}) {
            let improve = Logging.createLogger(category: .todo(.improve("Markup")))
            os_log(.debug, log: improve, "You should update parameter `oldText`. It shouldn't be a plain `String`. It should be either `Int32` to reflect cursor position or it should be `NSAttributedString`." )

            let refactor = Logging.createLogger(category: .todo(.refactor("NewBlock")))
            os_log(.debug, log: refactor, "You should not pass `newBlock` parameter in this method. However, our middleware doesn't send information about new block in callback except ID. That is so bad.")

            let documentID = documentId
            guard let documentId = documentId, let splittedBlockInformation = self.parser.convert(information: block.information) else {
                let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                let splittedBlock = self.parser.convert(information: block.information)
                os_log(.error, log: logger, "documentId: %@ or deletedBlock: %@ are nil? ", "\(String(describing: documentID))", "\(String(describing: splittedBlock))")
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

            self.service.split.action(contextID: documentId, blockID: splittedBlockInformation.id, cursorPosition: position, style: type.style).receive(on: RunLoop.main).sink(receiveCompletion: { (value) in
                switch value {
                case .finished: return
                case let .failure(error):
                    let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                    os_log(.error, log: logger, "blocksActions.service.split without payload got error: %@", "\(error)")
                }
            }, receiveValue: { [weak self] (value) in
                let ourNewBlock = newBlock
                ourNewBlock.information.id = value.blockID
                self?.updater.insert(block: ourNewBlock, afterBlock: block.getFullIndex())
                completion(ourNewBlock)

            }).store(in: &self.subscriptions)
        }
        
        func duplicate(documentId: String?, block: Model) {
            let documentID = documentId
            guard let documentId = documentId else {
                let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                os_log(.error, log: logger, "documentId: %@ is nil? ", "\(String(describing: documentID))")
                return
            }
            
            let targetId = block.information.id
            let blockIds: [String] = [targetId]
            let position: Anytype_Model_Block.Position = .bottom
            self.service.duplicate.action(contextID: documentId, targetID: targetId, blockIds: blockIds, position: position).sink(receiveCompletion: { (value) in
                switch value {
                case .finished: return
                case let .failure(error):
                    let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                    os_log(.error, log: logger, "blocksActions.service.duplicate got error: %@", "\(error)")
                }
            }) { [weak self] (value) in
                let blockIds = value.blockIds
                guard !blockIds.isEmpty else {
                    let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                    os_log(.error, log: logger, "blocksActions.service.duplicate empty block ids!")
                    return
                }
                // TODO: Add processing for many blocks.
                // Not reachable for UI for now.
                
                let ourNewBlock: Model = .init(information: .init(information: block.information))
                let id = blockIds[0]
                ourNewBlock.information.id = id
                
                let afterBlock = block
                
                self?.updater.insert(block: ourNewBlock, afterBlock: afterBlock.getFullIndex())                
            }.store(in: &self.subscriptions)
        }

        func delete(documentId: String?, block: Model, completion: @escaping () -> () = { }) {
            // Shit Swift
            let documentID = documentId
            guard let documentId = documentId, let deletedBlock = self.parser.convert(information: block.information) else {
                let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                let deletedBlock = self.parser.convert(information: block.information)
                os_log(.error, log: logger, "documentId: %@ or deletedBlock: %@ are nil? ", "\(String(describing: documentID))", "\(String(describing: deletedBlock))")
                return
            }

            self.service.delete.action(contextID: documentId, blockIds: [deletedBlock.id]).receive(on: RunLoop.main).sink(receiveCompletion: { [weak self] (value) in
                switch value {
                case .finished:
                    self?.updater.delete(at: block.getFullIndex())
                    completion()
                case let .failure(error):
                    let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                    os_log(.error, log: logger, "blocksActions.service.delete without payload got error: %@", "\(error)")
                }
                }, receiveValue: {_ in }).store(in: &self.subscriptions)
        }

        func merge(documentId: String?, firstBlock: Model, secondBlock: Model, completion: @escaping () -> () = { }) {
            let documentID = documentId
            let firstBlockInformation = self.parser.convert(information: firstBlock.information)
            let secondBlockInformation = self.parser.convert(information: secondBlock.information)

            guard let documentId = documentId, let firstBlockId = firstBlockInformation?.id, let secondBlockId = secondBlockInformation?.id else {
                let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                os_log(.error, log: logger, "documentId: %@ or firstBlock: %@ or secondBlock: %@ are nil? ", "\(String(describing: documentID))", "\(String(describing: firstBlockInformation))", "\(String(describing: secondBlockInformation))")
                return
            }

            //                    if case let (.text(first), .text(second)) = (beforeBlock.information.content, block.information.content) {
            //                        // we should tell our model that our block is updated.
            //                    }
            //                    switch block.information.content, beforeBlock.information {
            //                    case let .text(value):
            //                    default: return
            //                    }
            //                    var ourNewBlock = beforeBlock
            //                    ourNewBlock.text = firstBlock.text.text + secondBlock.text.text
            self.service.merge.action(contextID: documentId, firstBlockID: firstBlockId, secondBlockID: secondBlockId).receive(on: RunLoop.main).sink(receiveCompletion: { [weak self] value in
                switch value {
                case .finished:
                    self?.updater.delete(at: secondBlock.getFullIndex())
                    completion()
                    // we need to set cursor on correct position?...
                // Or we just need to set cursor on position of previous block and than we need to append text of deleted block?
                case let .failure(error):
                    let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                    os_log(.error, log: logger, "blocksActions.service.merge with payload got error: %@", "\(error)")
                }
                }, receiveValue: {_ in}).store(in: &self.subscriptions)
        }

        func createPage(documentId: String?, newBlock: Model, afterBlock: Model, position: Anytype_Model_Block.Position = .bottom, completion: @escaping (Model) -> () = {_ in}) {

            let documentID = documentId

            guard let documentId = documentId else {
                let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                os_log(.error, log: logger, "documentId: %@ is nil? ", "\(String(describing: documentID))")
                return
            }

            let targetId = ""
            let details: Google_Protobuf_Struct = .init()

            self.pageService.createPage.action(contextID: documentId, targetID: targetId, details: details, position: position).receive(on: RunLoop.main).sink(receiveCompletion: { (value) in
                switch value {
                case .finished: return // move to this page
                case let .failure(error):
                    let logger = Logging.createLogger(category: .treeTextBlocksUserInteractor)
                    os_log(.error, log: logger, "blocksActions.service.createPage with payload got error: %@", "\(error)")
                }
            }) { [weak self] (value) in
                // we must listen blockShow?
                let ourNewBlock: Model = .init(information: .init(id: value.blockId, content: .link(.init(targetBlockID: value.targetId, style: .page, fields: [:]))))
                if position == .top {
                    self?.updater.insert(block: ourNewBlock, at: afterBlock.getFullIndex())
                    completion(ourNewBlock)
                }
                else {
                    self?.updater.insert(block: ourNewBlock, afterBlock: afterBlock.getFullIndex())
                    completion(ourNewBlock)
                }

            }.store(in: &self.subscriptions)
        }
    }
}

// MARK: BlockBuilder
private extension BlocksViews.Supplement.TreeTextBlocksUserInteractor {
    struct BlockBuilder {
        static func newBlockId() -> Block.ID { UUID().uuidString }
        static func createBlock(for outerBlock: Model, _ id: Index, _ action: TextView.UserAction.KeyboardAction, _ textPayload: String) -> Model? {
            switch outerBlock.information.content {
            case .text:
                return self.createContentType(for: outerBlock, id, action, textPayload).flatMap({(newBlockId(), $0)}).map(BlockModels.Block.Information.init).flatMap({Model.init(information: $0)})
            default: return nil
            }
        }

        static func createContentType(for outerBlock: Model, _ id: Index, _ action: TextView.UserAction.KeyboardAction, _ textPayload: String) -> BlockType? {
            switch outerBlock.information.content {
            case let .text(blockType):
                switch blockType.contentType {
                case .bulleted where blockType.text != "": return .text(.init(text: textPayload, contentType: .bulleted))
                case .todo where blockType.text != "": return .text(.init(text: textPayload, contentType: .todo))
                case .numbered where blockType.text != "": return .text(.init(text: textPayload, contentType: .numbered))
                case .toggle where blockType.text != "": return .text(.init(text: textPayload, contentType: .toggle))
                default: return .text(.init(text: textPayload, contentType: .text))
                }
            default: return nil
            }
        }

        static func createContentType(for outerBlock: Model, _ id: Index, _ action: TextView.UserAction.BlockAction, _ textPayload: String = "") -> BlockType? {
            switch action {
            case let .addBlock(blockType):
                switch blockType {
                case let .text(value):
                    switch value {
                    case .text: return .text(.init(text: textPayload, contentType: .text))
                    case .h1: return .text(.init(text: textPayload, contentType: .header))
                    case .h2: return .text(.init(text: textPayload, contentType: .header2))
                    case .h3: return .text(.init(text: textPayload, contentType: .header3))
                    case .highlighted: return .text(.init(text: textPayload, contentType: .quote))
                    }
                case let .list(value):
                    switch value {
                    case .bulleted: return .text(.init(text: textPayload, contentType: .bulleted))
                    case .checkbox: return .text(.init(text: textPayload, contentType: .todo))
                    case .numbered: return .text(.init(text: textPayload, contentType: .numbered))
                    case .toggle: return .text(.init(text: textPayload, contentType: .toggle))
                    }
                case let .media(mediaType):
                    switch mediaType {
                    case .picture: return .file(.init(name: "", hash: "", state: .empty, contentType: .image))
                    case .bookmark: return nil
                    case .code: return nil
                    case .file: return nil
                    case .video: return nil
                    }
                case let .tool(value):
                    switch value {
                    case .page: return .link(.init(targetBlockID: "", style: .page, fields: [:]))
                    default: return nil
                    }
                default: return nil
                }
            default: return nil
            }
        }

        static func createBlock(for outerBlock: Model, _ id: Index, _ action: TextView.UserAction.BlockAction) -> Model? {
            switch action {
            case .addBlock: return self.createContentType(for: outerBlock, id, action).flatMap({(newBlockId(), $0)}).map(BlockModels.Block.Information.init).flatMap({Model.init(information: $0)})
            default: return nil
            }
        }
    }
}

// MARK: Handling / BlockAction
private extension BlocksViews.Supplement.TreeTextBlocksUserInteractor {
    func handlingBlockAction(_ block: Model, _ id: Index, _ action: TextView.UserAction.BlockAction) {
        switch action {
        case let .addBlock(value):
            switch value {
            case .tool(.page):
                if let newBlock = BlockBuilder.createBlock(for: block, id, action) {
                    self.service.createPage(documentId: self.documentId, newBlock: newBlock, afterBlock: block) { [weak self] value in
                        let blockId = value.information.id
                        self?.reaction = .shouldOpenPage(.init(payload: .init(blockId: blockId)))
                    }
                }
            default:
                if let newBlock = BlockBuilder.createBlock(for: block, id, action) {
                    self.service.add(documentId: self.documentId, newBlock: newBlock, afterBlock: block)
                }

            }

            // very-very-very complex action.
        // rethink it.
        case let .turnIntoBlock(value):
            guard !BlockActionComparator.equal(value, block.information.content) else { return }
            // change type now.
            var newBlock: Model?
            switch value {
            case let .text(value):
                switch BlockActionComparator.text(value) {
                case .quote:
                    newBlock = block
                    newBlock?.information.content = .text(.init(text: "New!", contentType: .quote))
                default: return
                }
            default: return
            }

            if let turnIntoBlock = newBlock {
                self.updater.update(at: block.getFullIndex(), by: turnIntoBlock)
            }
        case let .editBlock(value):
            switch value {
            case .delete: self.didReceiveAction(block: block, id: id, action: .keyboardAction(.pressKey(.delete)))
            case .duplicate: self.service.duplicate(documentId: self.documentId, block: block)
            default: return
            }
        default: return
        }
    }
}

// MARK: Handling / BlockAction / BlockComparator
private protocol ComparatorAndConvertor {
    associatedtype L
    associatedtype R: Equatable
    static func convert(_ type: L) -> R
}

extension ComparatorAndConvertor {
    static func equal(_ lhs: L, _ rhs: R) -> Bool {
        return convert(lhs) == rhs
    }
}

private extension BlocksViews.Supplement.TreeTextBlocksUserInteractor {
    struct BlockActionComparator {
        private struct ForText: ComparatorAndConvertor {
            static func convert(_ type: TextView.UserAction.BlockAction.BlockType.Text) -> BlockType.Text.ContentType {
                switch type {
                case .text: return .text
                case .h1: return .header
                case .h2: return .header
                case .h3: return .header
                case .highlighted: return .quote
                }
            }
            static func equal(_ lhs: TextView.UserAction.BlockAction.BlockType.Text, _ rhs: BlockType.Text.ContentType) -> Bool {
                return convert(lhs) == rhs
            }
        }
        private struct ForList: ComparatorAndConvertor {
            static func convert(_ type: TextView.UserAction.BlockAction.BlockType.List) -> BlockType.Text.ContentType {
                switch type {
                case .bulleted: return .bulleted
                case .checkbox: return .todo // checkbox
                case .numbered: return .numbered
                case .toggle: return .toggle
                }
            }
            static func equal(_ lhs: TextView.UserAction.BlockAction.BlockType.List, _ rhs: BlockType.Text.ContentType) -> Bool {
                return convert(lhs) == rhs
            }
        }
        private struct ForMedia: ComparatorAndConvertor {
            static func convert(_ type: TextView.UserAction.BlockAction.BlockType.Media) -> String {
                switch type {
                case .bookmark: return ""
                case .code: return ""
                case .file: return ""
                case .picture: return "BlockType.Image.ContentType.image"
                case .video: return "BlockType.Video.ContentType.video"
                }
            }
        }
        private struct ForTool: ComparatorAndConvertor {
            static func convert(_ type: TextView.UserAction.BlockAction.BlockType.Tool) -> String {
                switch type {
                case .contact: return "Contact"
                case .database: return "BlockType.DataView"
                case .existingTool: return "ExistingTool" // special type.
                case .set: return "Set" // special type.
                case .page: return "BlockType.Page.self"
                case .task: return "BlockType.Task.self"
                }
            }
            static func equal(_ lhs: TextView.UserAction.BlockAction.BlockType.Tool, _ rhs: BlockType.File.ContentType) -> Bool {
                false
            }
        }
        private struct ForOther: ComparatorAndConvertor {
            static func convert(_ type: TextView.UserAction.BlockAction.BlockType.Other) -> String {
                switch type {
                case .divider: return "BlockType.Div"
                }
            }
        }

        // Maybe it is better to create real text BlockType.Text
        static func text(_ type: TextView.UserAction.BlockAction.BlockType.Text) -> BlockType.Text.ContentType {
            ForText.convert(type)
        }

        static func equal(_ lhs: TextView.UserAction.BlockAction.BlockType, _ rhs: BlockType) -> Bool {
            switch (lhs, rhs) {
            case let (.text(left), .text(right)): return ForText.equal(left, right.contentType)
            case let (.list(left), .text(right)): return ForList.equal(left, right.contentType)
            default: return false
            }
        }
    }
}

