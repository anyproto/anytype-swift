//
//  TextView+BlocksToolbar+UnderlyingActions.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 23.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit

#warning("DeveloperMessages.FileIsDeprecated")
// NOTE: This file is deprecated because actions below should be moved to different namespace.

// MARK: These actions are only blueprints.
// Supposeedly, that we have to move them somewhere on domain level.
// So, now we have to move it somewhere.
// But where?...
// These entries are coming from user actions.
// So, they are nice to be there, right?...

extension CustomTextView.BlockToolbar {
    /// This is an action that is reachable by user interaction from BlockToolbar.
    ///
    enum UnderlyingAction {
        case addBlock(BlockType), turnIntoBlock(BlockType), changeColor(ChangeColor), editBlock(EditBlock)
    }
}

// MARK: BlockType
extension CustomTextView.BlockToolbar.UnderlyingAction {
    typealias AddBlock = CustomTextView.BlockToolbar.AddBlock
    /// This is a block type action.
    /// It consists of block types.
    /// Main purpose is aggreate these types into addBlock or turnIntoBlock wrapper-action.
    ///
    enum BlockType {
        // TODO: Add existences or invert dependencies by moving BlocksTypes here?
        typealias Text = AddBlock.BlocksTypes.Text
        typealias List = AddBlock.BlocksTypes.List
        typealias Media = AddBlock.BlocksTypes.Media
        typealias Tool = AddBlock.BlocksTypes.Tool
        typealias Other = AddBlock.BlocksTypes.Other
        case text(Text)
        case list(List)
        case media(Media)
        case tool(Tool)
        case other(Other)
        static func convert(_ type: CustomTextView.BlockToolbar.AddBlock.BlocksTypes) -> Self {
            switch type {
            case let .text(value): return .text(value)
            case let .list(value): return .list(value)
            case let .media(value): return .media(value)
            case let .tool(value): return .tool(value)
            case let .other(value): return .other(value)
            }
        }
    }
}

// MARK: EditBlock
extension CustomTextView.BlockToolbar.UnderlyingAction {
    /// This is edit block action.
    /// It consists of edit actions that user could do with block.
    /// For example, user could delete or duplicate block.
    /// Or user could press redo/undo on this block.
    ///
    enum EditBlock {
        case delete
        case duplicate
        case undo
        case redo
        static func convert(_ type: CustomTextView.BlockToolbar.EditActions.Action) -> Self {
            switch type {
            case .delete: return .delete
            case .duplicate: return .duplicate
            case .undo: return .undo
            case .redo: return .redo
            }
        }
    }
}

// MARK: ChangeColor
extension CustomTextView.BlockToolbar.UnderlyingAction {
    /// This is change color action.
    /// It aggregates actions as setForegroundColor and setBackgroundColor.
    /// User chooses colors and applies them to specific part of the block.
    ///
    enum ChangeColor {
        case textColor(UIColor)
        case backgroundColor(UIColor)
        // TODO: Add type that wraps textColor and backgroundColor like this type.
        static func convert(_ type: (UIColor?, UIColor?)) -> Self? {
            if let first = type.0 {
                return .textColor(first)
            }
            else if let second = type.1 {
                return .backgroundColor(second)
            }
            return nil
        }
    }
}
