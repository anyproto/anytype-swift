//
//  DocumentViewModel+UserInteraction.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 01.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

// MARK: Indices
extension DocumentViewModel {
    func index(of id: Block.ID) -> Int? {
        return self.indexDictionary[id]
    }
}

// MARK: TextBlocksViewsUserInteractionProtocol
extension DocumentViewModel: TextBlocksViewsUserInteractionProtocol {
    func didReceiveAction(block: Block, id: Block.ID, action: TextView.UserAction) {
        switch action {
        case let .blockAction(action): self.handlingBlockAction(block, id, action)
        case let .keyboardAction(action): self.handlingKeyboardAction(block, id, action)
        
        case let .marksAction(action): return
        case let .inputAction(action): return
        }
    }
}

// MARK: Handling / KeyboardAction
private extension DocumentViewModel {
    func handlingKeyboardAction(_ block: Block, _ id: Block.ID, _ action: TextView.UserAction.KeyboardAction) {
        switch action {
        case let .pressKey(keyAction):
            switch keyAction {
            case let .enterWithPayload(payload):
                BlockBuilder.createBlock(for: block, id, action, payload ?? "").flatMap{($0, id)}.flatMap(self.testInsertAfter)
            case .enterAtBeginning: // we should assure ourselves about type of block.
                switch block.type {
                case let .text(blockType): // nice.
                    BlockBuilder.createBlock(for: block, id, action, blockType.text).flatMap{($0, id)}.flatMap(self.testInsertAfter)//{self.testInsert(block: $0.0, afterBlock: $0.1)}
                default: return // do nothing! but it is too strange.
                }
            case .enter:
                BlockBuilder.createBlock(for: block, id, action, "").flatMap{($0, id)}.flatMap{self.testInsert(block: $0.0, afterBlock: $0.1)}
            case .deleteWithPayload(_): return
            case .delete: self.testDelete(block: id)
            }
        }
    }
}

// MARK: BlockBuilder
private extension DocumentViewModel {
    struct BlockBuilder {
        static func newBlockId() -> Block.ID { UUID().uuidString }
        static func createBlock(for outerBlock: Block, _ id: Block.ID, _ action: TextView.UserAction.KeyboardAction, _ textPayload: String) -> Block? {
            switch outerBlock.type {
            case let .text(blockType):
                switch blockType.contentType {
                case .bulleted: return Block(id: newBlockId(), childrensIDs: [], type: .text(BlockType.Text.init(text: textPayload, contentType: .bulleted)))
                case .todo: return Block(id: newBlockId(), childrensIDs: [], type: .text(BlockType.Text.init(text: textPayload, contentType: .todo)))
                case .numbered: return Block(id: newBlockId(), childrensIDs: [], type: .text(BlockType.Text.init(text: textPayload, contentType: .numbered)))
                default: return Block(id: newBlockId(), childrensIDs: [], type: .text(BlockType.Text.init(text: textPayload, contentType: .text)))
                }
            default: return nil
            }
        }
        static func createBlock(for outerBlock: Block, _ id: Block.ID, _ action: TextView.UserAction.BlockAction) -> Block? {
//            .init()
            switch action {
            case let .addBlock(blockType):
                switch blockType {
                case let .text(textType):
                    switch textType {
                    case .text: return Block(id: newBlockId(), childrensIDs: [], type: .text(BlockType.Text.init(text: "", contentType: .text)))
                    case .h1: return Block(id: newBlockId(), childrensIDs: [], type: .text(BlockType.Text.init(text: "", contentType: .header)))
                    case .h2: return nil
                    case .h3: return nil
                    case .highlighted: return Block(id: newBlockId(), childrensIDs: [], type: .text(BlockType.Text.init(text: "", contentType: .quote)))
                    }
                case let .list(listType):
                    switch listType {
                    case .bulleted: return Block(id: newBlockId(), childrensIDs: [], type: .text(BlockType.Text.init(text: "", contentType: .bulleted)))
                    case .checkbox: return Block(id: newBlockId(), childrensIDs: [], type: .text(BlockType.Text.init(text: "", contentType: .todo)))
                    case .numbered: return Block(id: newBlockId(), childrensIDs: [], type: .text(BlockType.Text.init(text: "", contentType: .numbered)))
                    case .toggle: return Block(id: newBlockId(), childrensIDs: [], type: .text(BlockType.Text.init(text: "", contentType: .toggle)))
                    }
                default: return nil
                }
            default: return nil
            }
        }
    }
}

// MARK: Handling / BlockAction
private extension DocumentViewModel {
    func handlingBlockAction(_ block: Block, _ id: Block.ID, _ action: TextView.UserAction.BlockAction) {
        switch action {
        case .addBlock(_):
            // we just create a block next to our block.
            // but for list blocks it is not the same as create block, it is create new entry.
            if let newBlock = BlockBuilder.createBlock(for: block, id, action) {
                // insert block after block
                self.testInsert(block: newBlock, afterBlock: id)
            }
            
        // very-very-very complex action.
        // rethink it.
        case let .turnIntoBlock(value):
            guard !BlockActionComparator.equal(value, block.type) else { return }
            // change type now.
            var newBlock: Block?
            switch value {
            case let .text(value):
                switch BlockActionComparator.text(value) {
                case .quote:
                    newBlock = block
                    newBlock?.type = .text(.init(text: "New!", contentType: .quote))
                default: return
                }
            default: return
            }
            
            if let turnIntoBlock = newBlock {
                self.testUpdate(at: id, by: turnIntoBlock)
            }
        case let .editBlock(value):
            switch value {
            case .delete: self.testDelete(block: id)
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
private extension DocumentViewModel {
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
