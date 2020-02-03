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

// MARK: UserInteraction
protocol TextBlocksViewsUserInteractionProtocol: class {
    func didReceiveAction(block: Block, id: Block.ID, action: TextView.UserAction)
}

extension TextBlocksViews {
    enum Supplement {}
}


extension TextBlocksViews.Supplement {
    
    class Matcher: BlocksViews.Supplement.BaseBlocksSeriazlier {
        
        override func sequenceResolver(block: Block, blocks: [Block]) -> [BlockViewBuilderProtocol] {
            switch block.type {
            case let .text(text):
                switch text.contentType {
                case .text: return blocks.map(TextBlocksViews.Text.BlockViewModel.init)
                case .header: return blocks.map(TextBlocksViews.Header.BlockViewModel.init)
                case .quote: return blocks.map(TextBlocksViews.Quote.BlockViewModel.init)
                case .todo: return blocks.map(TextBlocksViews.Checkbox.BlockViewModel.init)
                case .bulleted: return blocks.map(TextBlocksViews.Bulleted.BlockViewModel.init)
                case .numbered: return [TextBlocksViews.List.BlockViewModel(blocks:
                    zip(blocks, blocks.indices).map{
                        TextBlocksViews.Numbered.BlockViewModel($0.0).update(style: .number($0.1.advanced(by: 1)))
                    }
                    )]
                //                case .toggle: return blocks.map{TextBlocksViews.Toggle.BlockViewModel(block: $0)}}
                case .toggle: return blocks.map{($0, TextBlocksViews.Toggle.BlockViewModel($0))}.map{$0.1.update(blocks: Array(repeating: $0.0, count: 4).map(TextBlocksViews.Text.BlockViewModel.init))}
                case .callout: return blocks.map(TextBlocksViews.Callout.BlockViewModel.init)
                }
            default: return []
            }
        }
    }
}


