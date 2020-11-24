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

fileprivate typealias Namespace = ServiceLayerModule.Text

// MARK: - Actions Protocols
/// Protocol for `Set Text and Marks` for text block.
/// NOTE: It has two methods. One of them accept high-level storage `NSAttributedString`
/// It is necessary for us to have third part of communication between middleware.
/// We consume middleware marks and convert them to NSAttributedString.
/// Later, TextView update NSAttributedString and send updates back.
///
protocol ServiceLayerModule_BlockActionsServiceTextProtocolSetText {
    func action(contextID: String, blockID: String, attributedString: NSAttributedString) -> AnyPublisher<Never, Error>
    func action(contextID: String, blockID: String, text: String, marks: Anytype_Model_Block.Content.Text.Marks) -> AnyPublisher<Never, Error>
}

/// Protocol for `SetStyle` for text block.
/// It is used in `TurnInto` actions in UI.
/// When you would like to update style of block ( or turn into this block to another block ),
/// you will use this method.
protocol ServiceLayerModule_BlockActionsServiceTextProtocolSetStyle {
    associatedtype Success
    func action(contextID: String, blockID: String, style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<Success, Error>
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
    func action(contextID: String, blockID: String, color: UIColor) -> AnyPublisher<Never, Error>
    func action(contextID: String, blockID: String, color: String) -> AnyPublisher<Never, Error>
}

/// Protocol for `SetAlignment` for text block. Actually, not only for text block.
/// When you would like to set alignment of a block ( text block or not text block ), you should call method of this protocol.
protocol ServiceLayerModule_BlockActionsServiceTextProtocolSetAlignment {
    func action(contextID: String, blockIds: [String], alignment: NSTextAlignment) -> AnyPublisher<Never, Error>
    func action(contextID: String, blockIds: [String], align: Anytype_Model_Block.Align) -> AnyPublisher<Never, Error>
}

protocol ServiceLayerModule_BlockActionsServiceTextProtocolSplit {
    associatedtype Success
    func action(contextID: String, blockID: String, cursorPosition: Int32, style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<Success, Error>
    func action(contextID: String, blockID: String, range: NSRange, style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<Success, Error>
}

protocol ServiceLayerModule_BlockActionsServiceTextProtocolMerge {
    associatedtype Success
    func action(contextID: String, firstBlockID: String, secondBlockID: String) -> AnyPublisher<Success, Error>
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

extension Namespace {
    class BlockActionsService: ServiceLayerModule_BlockActionsServiceTextProtocol {
        var setText: SetText = .init()
        var setStyle: SetStyle = .init()
        var setForegroundColor: SetForegroundColor = .init()
        var setAlignment: SetAlignment = .init()
        var split: Split = .init()
        var merge: Merge = .init()
    }
}

extension Namespace.BlockActionsService {
    typealias Success = ServiceLayerModule.Success
    // MARK: SetText
    struct SetText: ServiceLayerModule_BlockActionsServiceTextProtocolSetText {
        func action(contextID: String, blockID: String, attributedString: NSAttributedString) -> AnyPublisher<Never, Error> {
            // convert attributed string to marks here?
            let result = BlocksModelsModule.Parser.Text.AttributedText.Converter.asMiddleware(attributedText: attributedString)
            return action(contextID: contextID, blockID: blockID, text: result.text, marks: result.marks)
        }
        func action(contextID: String, blockID: String, text: String, marks: Anytype_Model_Block.Content.Text.Marks) -> AnyPublisher<Never, Error> {
            
            /// TODO: Add private queue, don't use global queue.
            Anytype_Rpc.Block.Set.Text.Text.Service.invoke(contextID: contextID, blockID: blockID, text: text, marks: marks, queue: .global()).ignoreOutput().subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
        }
    }
    
    // MARK: SetStyle
    struct SetStyle: ServiceLayerModule_BlockActionsServiceTextProtocolSetStyle {
        func action(contextID: String, blockID: String, style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Set.Text.Style.Service.invoke(contextID: contextID, blockID: blockID, style: style).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
        }
    }
    
    // MARK: SetForegroundColor
    struct SetForegroundColor: ServiceLayerModule_BlockActionsServiceTextProtocolSetForegroundColor {
        func action(contextID: String, blockID: String, color: UIColor) -> AnyPublisher<Never, Error> {
            // convert color to String?
            let result = BlocksModelsModule.Parser.Text.Color.Converter.asMiddleware(color, background: false)
            return action(contextID: contextID, blockID: blockID, color: result)
        }
        func action(contextID: String, blockID: String, color: String) -> AnyPublisher<Never, Error> {
            Anytype_Rpc.Block.Set.Text.Color.Service.invoke(contextID: contextID, blockID: blockID, color: color)
                .ignoreOutput().subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
        }
    }
    
    // MARK: SetAlignment
    struct SetAlignment: ServiceLayerModule_BlockActionsServiceTextProtocolSetAlignment {
        func action(contextID: String, blockIds: [String], alignment: NSTextAlignment) -> AnyPublisher<Never, Error> {
            let ourAlignment = BlocksModelsModule.Parser.Common.Alignment.UIKitConverter.asModel(alignment)
            let middlewareAlignment = ourAlignment.flatMap(BlocksModelsModule.Parser.Common.Alignment.Converter.asMiddleware)
            
            if let middlewareAlignment = middlewareAlignment {
                return self.action(contextID: contextID, blockIds: blockIds, align: middlewareAlignment)
            }
            return .empty()
        }
        func action(contextID: String, blockIds: [String], align: Anytype_Model_Block.Align) -> AnyPublisher<Never, Error> {
            Anytype_Rpc.BlockList.Set.Align.Service.invoke(contextID: contextID, blockIds: blockIds, align: align).ignoreOutput().subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    
    // MARK: Split
    struct Split: ServiceLayerModule_BlockActionsServiceTextProtocolSplit {
        func action(contextID: String, blockID: String, cursorPosition: Int32, style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Split.Service.invoke(contextID: contextID, blockID: blockID, range: .init(from: cursorPosition, to: cursorPosition), style: style, mode: .bottom).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
        func action(contextID: String, blockID: String, range: NSRange, style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<Success, Error> {
            let middlewareRange = BlocksModelsModule.Parser.Text.AttributedText.RangeConverter.asMiddleware(range)
            return Anytype_Rpc.Block.Split.Service.invoke(contextID: contextID, blockID: blockID, range: middlewareRange, style: style, mode: .bottom, queue: .global()).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
        }
    }

    // MARK: Merge
    struct Merge: ServiceLayerModule_BlockActionsServiceTextProtocolMerge {
        func action(contextID: String, firstBlockID: String, secondBlockID: String) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Merge.Service.invoke(contextID: contextID, firstBlockID: firstBlockID, secondBlockID: secondBlockID, queue: .global())
                .map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
}
