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
        default: return
        }
    }
}

// MARK: Handling / BlockAction
private extension DocumentViewModel {
    func handlingBlockAction(_ block: Block, _ id: Block.ID, _ action: TextView.UserAction.BlockAction) {
        switch action {
        case let .addBlock(value): return
            // figure out block ids.
//            self.addBlock(content: <#T##BlockType#>, afterBlock: <#T##Int#>)
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
            case .delete: self.index(of: id).flatMap(self.testDelete(at:))
            default: return                
            }
        default: return
        }
    }
}

// MARK: Handling / BlockAction / BlockComparator
//private protocol ComparatorAndConvertor {
//    associatedtype L
//    associatedtype R: Comparable
//    static func convert(_ type: L) -> R
//}
//extension ComparatorAndConvertor {
//    static func equal(_ lhs: L, _ rhs: R) -> Bool {
//        return convert(lhs) == rhs
//    }
//}
private extension DocumentViewModel {
    struct BlockActionComparator {
        private struct ForText {
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
        private struct ForList {
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
        private struct ForMedia {
            static func equal(_ lhs: TextView.UserAction.BlockAction.BlockType.Media, _ rhs: BlockType.Image.ContentType) -> Bool {
                false
            }
        }
        private struct ForTool {
            static func equal(_ lhs: TextView.UserAction.BlockAction.BlockType.Tool, _ rhs: BlockType.Image.ContentType) -> Bool {
                false
            }
        }
        private struct ForOther {
            static func equal(_ lhs: TextView.UserAction.BlockAction.BlockType.Other, _ rhs: BlockType.Image.ContentType) -> Bool {
                switch lhs {
                case .divider: return false
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
