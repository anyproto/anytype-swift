//
//  BlockActionsService+Text.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 15.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import UIKit
import BlocksModels

// MARK: - Actions Protocols
/// Protocol for `Set Text and Marks` for text block.
/// NOTE: It has two methods. One of them accept high-level storage `NSAttributedString`
/// It is necessary for us to have third part of communication between middleware.
/// We consume middleware marks and convert them to NSAttributedString.
/// Later, TextView update NSAttributedString and send updates back.
///
protocol ServiceLayerModule_BlockActionsServiceTextProtocolSetText {
    typealias BlockId = TopLevel.AliasesMap.BlockId
    func action(contextID: BlockId, blockID: BlockId, attributedString: NSAttributedString) -> AnyPublisher<Void, Error>
}

/// Protocol for `SetStyle` for text block.
/// It is used in `TurnInto` actions in UI.
/// When you would like to update style of block ( or turn into this block to another block ),
/// you will use this method.
protocol ServiceLayerModule_BlockActionsServiceTextProtocolSetStyle {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    typealias Style = TopLevel.AliasesMap.BlockContent.Text.ContentType
    func action(contextID: BlockId, blockID: BlockId, style: Style) -> AnyPublisher<Success, Error>
}

/// Protocol for `SetTextColor` for text block.
/// It is renamed intentionally.
/// `SetForegroundColor` is something that you would expect from text.
/// Lets describe how it would be done on top-level in UI updates.
/// If you would like to apply `SetForegroundColor`, you would first create `attributedString` with content.
/// And only after that, you would apply whole markup.
/// It is easy to write in following:
/// `precedencegroup` of SetForegroundColor is higher, than `precedencegroup` of `Set Text and Markup`
/// But
/// We also could do it via typing attributes.
///
/// NOTE:
/// This protocol requires two methods to be implemented. One of them uses UIColor as Color representation.
/// It is essential for us to use `high-level` color.
/// In that way we are distancing from low-level API and low-level colors.
protocol ServiceLayerModule_BlockActionsServiceTextProtocolSetForegroundColor {
    typealias BlockId = TopLevel.AliasesMap.BlockId
    func action(contextID: BlockId, blockID: BlockId, color: UIColor) -> AnyPublisher<Void, Error>
}

/// Protocol for `SetAlignment` for text block. Actually, not only for text block.
/// When you would like to set alignment of a block ( text block or not text block ), you should call method of this protocol.
protocol ServiceLayerModule_BlockActionsServiceTextProtocolSetAlignment {
    typealias BlockId = TopLevel.AliasesMap.BlockId
    func action(contextID: BlockId, blockIds: [BlockId], alignment: NSTextAlignment) -> AnyPublisher<Void, Error>
}

protocol ServiceLayerModule_BlockActionsServiceTextProtocolSplit {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    typealias Style = TopLevel.AliasesMap.BlockContent.Text.ContentType
    func action(contextID: BlockId, blockID: BlockId, range: NSRange, style: Style) -> AnyPublisher<Success, Error>
}

protocol ServiceLayerModule_BlockActionsServiceTextProtocolMerge {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    func action(contextID: BlockId, firstBlockID: BlockId, secondBlockID: BlockId) -> AnyPublisher<Success, Error>
}

/// Protocol for TextBlockActions service.
protocol ServiceLayerModule_BlockActionsServiceTextProtocol {
    associatedtype SetText: ServiceLayerModule_BlockActionsServiceTextProtocolSetText
    associatedtype SetStyle: ServiceLayerModule_BlockActionsServiceTextProtocolSetStyle
    associatedtype SetForegroundColor: ServiceLayerModule_BlockActionsServiceTextProtocolSetForegroundColor
    associatedtype SetAlignment: ServiceLayerModule_BlockActionsServiceTextProtocolSetAlignment
    associatedtype Split: ServiceLayerModule_BlockActionsServiceTextProtocolSplit
    associatedtype Merge: ServiceLayerModule_BlockActionsServiceTextProtocolMerge
    
    var setText: SetText {get}
    var setStyle: SetStyle {get}
    var setForegroundColor: SetForegroundColor {get}
    var setAlignment: SetAlignment {get}
    var split: Split {get}
    var merge: Merge {get}
}
