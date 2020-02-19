//
//  BlocksViews+Base+Utilities+TextBlocksUserInteractor.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 18.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

extension BlocksViews.Base.Utilities {
    // Add AnyUpdater (?) // Do we really need it?
    class TextBlocksUserInteractor<T: BlockViewBuildersProtocolHolder> {
        typealias Index = BusinessBlock.Index
        typealias Model = BlockModels.Block.RealBlock
        var updater: SequenceUpdater<T>
        init(_ value: T) {
            self.updater = SequenceUpdater.init(value: value)
        }
//        init(_ value: SequenceUpdater<T>) {
//            self.updater = value as AnyUpdater<Index, Model>
//            self.updater = value
//        }
    }
}

// MARK: TextBlocksViewsUserInteractionProtocol
extension BlocksViews.Base.Utilities.TextBlocksUserInteractor: TextBlocksViewsUserInteractionProtocol {
    func didReceiveAction(block: Model, id: Index, action: TextView.UserAction) {
        switch action {
        case let .blockAction(action): self.handlingBlockAction(block, id, action)
        case let .keyboardAction(action): self.handlingKeyboardAction(block, id, action)
        
        case let .marksAction(action): return
        case let .inputAction(action): return
        }
    }
}

// MARK: Handling / KeyboardAction
private extension BlocksViews.Base.Utilities.TextBlocksUserInteractor {
    func handlingKeyboardAction(_ block: Model, _ id: Index, _ action: TextView.UserAction.KeyboardAction) {
        switch action {
        case let .pressKey(keyAction):
            switch keyAction {
            case let .enterWithPayload(payload):
                BlockBuilder.createBlock(for: block, id, action, payload ?? "").flatMap{($0, id)}.flatMap(self.updater.insert(block:afterBlock:))
            case .enterAtBeginning: // we should assure ourselves about type of block.
                switch block.information.content {
                case let .text(blockType): // nice.
                    BlockBuilder.createBlock(for: block, id, action, blockType.text).flatMap{($0, id)}.flatMap(self.updater.insert(block:afterBlock:))
                default: return // do nothing! but it is too strange.
                }
            case .enter:
                BlockBuilder.createBlock(for: block, id, action, "").flatMap{($0, id)}.flatMap{self.updater.insert(block: $0.0, afterBlock: $0.1)}
            case .deleteWithPayload(_): return
            case .delete: self.updater.delete(at: id)
            }
        }
    }
}

// MARK: BlockBuilder
private extension BlocksViews.Base.Utilities.TextBlocksUserInteractor {
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
                default: return .text(.init(text: textPayload, contentType: .text))
                }
            default: return nil
            }
        }
        
        static func createContentType(for outerBlock: Model, _ id: Index, _ action: TextView.UserAction.BlockAction, _ textPayload: String = "") -> BlockType? {
            switch action {
            case let .addBlock(blockType):
                switch blockType {
                case let .text(textType):
                    switch textType {
                    case .text: return .text(.init(text: textPayload, contentType: .text))
                    case .h1: return .text(.init(text: textPayload, contentType: .header))
                    case .h2: return nil
                    case .h3: return nil
                    case .highlighted: return .text(.init(text: textPayload, contentType: .quote))
                    }
                case let .list(listType):
                    switch listType {
                    case .bulleted: return .text(.init(text: textPayload, contentType: .bulleted))
                    case .checkbox: return .text(.init(text: textPayload, contentType: .todo))
                    case .numbered: return .text(.init(text: textPayload, contentType: .numbered))
                    case .toggle: return .text(.init(text: textPayload, contentType: .toggle))
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
private extension BlocksViews.Base.Utilities.TextBlocksUserInteractor {
    func handlingBlockAction(_ block: Model, _ id: Index, _ action: TextView.UserAction.BlockAction) {
        switch action {
        case .addBlock(_):
            // we just create a block next to our block.
            // but for list blocks it is not the same as create block, it is create new entry.
            if let newBlock = BlockBuilder.createBlock(for: block, id, action) {
                // insert block after block
                self.updater.insert(block: newBlock, afterBlock: id)
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
                self.updater.update(at: id, by: turnIntoBlock)
            }
        case let .editBlock(value):
            switch value {
            case .delete: self.updater.delete(at: id)
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

private extension BlocksViews.Base.Utilities.TextBlocksUserInteractor {
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
            static func equal(_ lhs: TextView.UserAction.BlockAction.BlockType.Tool, _ rhs: BlockType.Image.ContentType) -> Bool {
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

