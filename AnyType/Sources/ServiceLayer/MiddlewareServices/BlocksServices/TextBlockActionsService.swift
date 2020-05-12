//
//  TextBlockActionsService.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 07.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import UIKit

// MARK: - Actions Protocols
/// Protocol for `Set Text and Marks` for text block.
/// NOTE: It has two methods. One of them accept high-level storage `NSAttributedString`
/// It is necessary for us to have third part of communication between middleware.
/// We consume middleware marks and convert them to NSAttributedString.
/// Later, TextView update NSAttributedString and send updates back.
/// 
protocol TextBlockActionsServiceProtocolSetText {
    func action(contextID: String, blockID: String, attributedString: NSAttributedString) -> AnyPublisher<Never, Error>
    func action(contextID: String, blockID: String, text: String, marks: Anytype_Model_Block.Content.Text.Marks) -> AnyPublisher<Never, Error>
}

/// Protocol for `SetStyle` for text block.
/// It is used in `TurnInto` actions in UI.
/// When you would like to update style of block ( or turn into this block to another block ),
/// you will use this method.
protocol TextBlockActionsServiceProtocolSetStyle {
    func action(contextID: String, blockID: String, style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<Never, Error>
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
protocol TextBlockActionsServiceProtocolSetForegroundColor {
    func action(contextID: String, blockID: String, color: UIColor) -> AnyPublisher<Never, Error>
    func action(contextID: String, blockID: String, color: String) -> AnyPublisher<Never, Error>
}

/// Protocol for TextBlockActions service.
protocol TextBlockActionsServiceProtocol {
    associatedtype SetText: TextBlockActionsServiceProtocolSetText
    associatedtype SetStyle: TextBlockActionsServiceProtocolSetStyle
    associatedtype SetForegroundColor: TextBlockActionsServiceProtocolSetForegroundColor
    
    var setText: SetText {get}
    var setStyle: SetStyle {get}
    var setForegroundColor: SetForegroundColor {get}
}

class TextBlockActionsService: TextBlockActionsServiceProtocol {
    var setText: SetText = .init()
    var setStyle: SetStyle = .init()
    var setForegroundColor: SetForegroundColor = .init()
    
    // MARK: SetText
    struct SetText: TextBlockActionsServiceProtocolSetText {
        func action(contextID: String, blockID: String, attributedString: NSAttributedString) -> AnyPublisher<Never, Error> {
            // convert attributed string to marks here?
            let result = BlockModels.Parser.Text.AttributedText.Converter.asMiddleware(attributedText: attributedString)
            return action(contextID: contextID, blockID: blockID, text: result.text, marks: result.marks)
        }
        func action(contextID: String, blockID: String, text: String, marks: Anytype_Model_Block.Content.Text.Marks) -> AnyPublisher<Never, Error> {
            Anytype_Rpc.Block.Set.Text.Text.Service.invoke(contextID: contextID, blockID: blockID, text: text, marks: marks).ignoreOutput().subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
        }
    }
    
    // MARK: SetStyle
    struct SetStyle: TextBlockActionsServiceProtocolSetStyle {
        func action(contextID: String, blockID: String, style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<Never, Error> {
            Anytype_Rpc.Block.Set.Text.Style.Service.invoke(contextID: contextID, blockID: blockID, style: style).ignoreOutput().subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
        }
    }
    
    // MARK: SetForegroundColor
    struct SetForegroundColor: TextBlockActionsServiceProtocolSetForegroundColor {
        func action(contextID: String, blockID: String, color: UIColor) -> AnyPublisher<Never, Error> {
            // convert color to String?
            let result = BlockModels.Parser.Text.Color.Converter.asMiddleware(color, background: false)
            return action(contextID: contextID, blockID: blockID, color: result)
        }
        func action(contextID: String, blockID: String, color: String) -> AnyPublisher<Never, Error> {
            Anytype_Rpc.Block.Set.Text.Color.Service.invoke(contextID: contextID, blockID: blockID, color: color)
                .ignoreOutput().subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
        }
    }
}
