//
//  TextBlocksViews.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 18.11.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
enum TextBlocksViews {
    enum Text {} // -> Text.ContentType.text
    enum Header {} // -> Text.ContentType.header
    enum Quote {} // -> Text.ContentType.quote
    enum Checkbox {} // -> Text.ContentType.todo
    enum Bulleted {} // -> Text.ContentType.bulleted
    enum Numbered {} // -> Text.ContentType.numbered
    enum Toggle {} // -> Text.ContentType.toggle
    enum Callout {} // -> Text.ContentType.callout
    
    enum List {} // -> No content type. It is group or list of items.
}

extension TextBlocksViews {
    enum Supplement {}
}

extension TextBlocksViews.Supplement {
    class Matcher {
        private static func sameBlock(lhs: Block, rhs: Block) -> Bool {
            switch (lhs.type, rhs.type) {
            case let (.text(left), .text(right)):
                return left.contentType == right.contentType
//                switch (left.contentType, right.contentType) {
//                case ()
//                }
            default: return false
            }
        }
//        static func resolver2(blocks: [Block]) -> [BlockViewRowBuilderProtocol] {
//
//            // 1. first step - group together views which have "same"
//            let remains = blocks.dropFirst()
//            let prefix = blocks.prefix(1)
//            let result = Array(prefix)
//
//            for element in blocks.dropFirst() {
//
//            }
//
//            return []
//        }
        
        //
        // TODO: Add sequence resolver for each block type.
        // each block type should have its own sequence resolver.
        private static func sequenceResolver(block: Block, blocks: [Block]) -> [BlockViewRowBuilderProtocol] {
            switch block.type {
            case let .text(text):
                switch text.contentType {
                case .text: return blocks.map{TextBlocksViews.Text.BlockViewModel(block: $0)}
                case .header: return blocks.map{TextBlocksViews.Header.BlockViewModel(block: $0)}
                case .quote: return blocks.map{TextBlocksViews.Quote.BlockViewModel(block: $0)}
                case .todo: return blocks.map{TextBlocksViews.Checkbox.BlockViewModel(block: $0)}
                case .bulleted: return blocks.map{TextBlocksViews.Bulleted.BlockViewModel(block: $0)}
                case .numbered: return [TextBlocksViews.List.BlockViewModel(blocks:
                    zip(blocks, blocks.indices).map{
                        TextBlocksViews.Numbered.BlockViewModel(block: $0.0).update(style: .number($0.1.advanced(by: 1)))
                    }
                    )]
//                case .toggle: return blocks.map{TextBlocksViews.Toggle.BlockViewModel(block: $0)}}
                case .toggle: return blocks.map{($0, TextBlocksViews.Toggle.BlockViewModel(block: $0))}.map{$0.1.update(blocks: Array(repeating: $0.0, count: 4).map{TextBlocksViews.Text.BlockViewModel(block: $0)})}
                case .callout: return blocks.map{TextBlocksViews.Callout.BlockViewModel(block: $0)}
                }
            default: return []
            }
        }
        
        private static func sequencesResolver(blocks: [Block]) -> [BlockViewRowBuilderProtocol] {
            guard let first = blocks.first else { return [] }
            return self.sequenceResolver(block: first, blocks: blocks)
        }
        
        static func resolver(blocks: [Block]) -> [BlockViewRowBuilderProtocol] {
            if blocks.isEmpty {
                return []
            }
            
            // 1. first step - group together views which have "same"
            let remains = blocks.dropFirst()
            let prefix = blocks.prefix(1)
            let firstElements = Array(prefix)
            
            let grouped = remains.reduce([firstElements]) { (result, block) in
                var result = result
                if let lastGroup = result.last, let firstObject = lastGroup.first, sameBlock(lhs: firstObject, rhs: block) {
                    result = result.dropLast() + [(lastGroup + [block])]
                }
                else {
                    result.append([block])
                }
                return result
            }
                                                
            // 2. Next, we have to choose which group has which ViewModel
            let result = grouped.flatMap { (blocks) in
                self.sequencesResolver(blocks: blocks)
            }
            return result
        }
    }
}


