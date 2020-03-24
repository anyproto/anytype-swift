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
extension TextBlocksViews {
    /// This is Event wrapper enumeration.
    ///
    /// Consider following scenario.
    ///
    /// You have several delegates that sends events.
    ///
    /// `ADelegate` sends `AEvent` and `BDelegate` sends `BEvent`
    ///
    /// Let us wrap them into one action.
    ///
    /// enum Action {
    ///  .aAction(AEvent)
    ///  .bAction(BEvent)
    /// }
    ///
    /// This `UserInteraction` enumeration wrap `TextView.UserAction` and `ButtonView.UserAction` together
    ///
    enum UserInteraction {
        case textView(TextView.UserAction)
        case buttonView(ButtonView.UserAction)
    }
}
extension TextBlocksViews.UserInteraction {
    enum ButtonView {
        enum UserAction {
            enum Toggle {
                case toggled(Bool)
                case insertFirst(Bool)
            }
            case toggle(Toggle)
            case checkbox(Bool)
        }
    }
}
protocol TextBlocksViewsUserInteractionProtocol: class {
    typealias Index = BusinessBlock.Index
    typealias Model = BlockModels.Block.RealBlock
    func didReceiveAction(block: Model, id: Index, action: TextView.UserAction)
    func didReceiveAction(block: Model, id: Index, generalAction: TextBlocksViews.UserInteraction)
}

protocol TextBlocksViewsUserInteractionProtocolHolder: class {
    func configured(_ delegate: TextBlocksViewsUserInteractionProtocol?) -> Self?
}

extension TextBlocksViews {
    enum Supplement {}
}


extension TextBlocksViews.Supplement {
    class Matcher: BlocksViews.Supplement.BaseBlocksSeriazlier {        
        override func sequenceResolver(block: Model, blocks: [Model]) -> [BlockViewBuilderProtocol] {
            switch block.information.content {
            case let .text(text):
                switch text.contentType {
                case .text: return blocks.map(TextBlocksViews.Text.BlockViewModel.init)
                case .header: return blocks.map(TextBlocksViews.Header.BlockViewModel.init)
                case .header2: return blocks.map(TextBlocksViews.Header.BlockViewModel.init)
                case .header3: return blocks.map(TextBlocksViews.Header.BlockViewModel.init)
                case .header4: return blocks.map(TextBlocksViews.Header.BlockViewModel.init)
                case .quote: return blocks.map(TextBlocksViews.Quote.BlockViewModel.init)
                case .todo: return blocks.map(TextBlocksViews.Checkbox.BlockViewModel.init)
                case .bulleted: return blocks.map(TextBlocksViews.Bulleted.BlockViewModel.init)
                case .numbered: return zip(blocks, blocks.indices).map{
                    // determine style somehow?
                    TextBlocksViews.Numbered.BlockViewModel($0.0).update(style: .number($0.1.advanced(by: 1)))
                    }
                //                case .toggle: return blocks.map{TextBlocksViews.Toggle.BlockViewModel(block: $0)}}
                case .toggle: return blocks.map{($0, TextBlocksViews.Toggle.BlockViewModel($0))}.map{$0.1.update(blocks: Array(repeating: $0.0, count: 4).map(TextBlocksViews.Text.BlockViewModel.init))}
                case .callout: return blocks.map(TextBlocksViews.Callout.BlockViewModel.init)
                }
            default: return []
            }
        }
    }
}


