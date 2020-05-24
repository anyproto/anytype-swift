//
//  BlocksViews+Toolbar+UnderlyingAction.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 20.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import UIKit
// MARK: These actions are only blueprints.
// Supposeedly, that we have to move them somewhere on domain level.
// So, now we have to move it somewhere.
// But where?...
// These entries are coming from user actions.
// So, they are nice to be there, right?...

extension BlocksViews.Toolbar {
    enum UnderlyingAction {
        enum BlockType {
            case text(Text)
            case list(List)
            case page(Page)
            case media(Media)
            case tool(Tool)
            case other(Other)
            static func convert(_ type: BlocksViews.Toolbar.AddBlock.BlocksTypes) -> Self {
                switch type {
                case let .text(value): return .text(.convert(value))
                case let .list(value): return .list(.convert(value))
                case let .page(value): return .page(.convert(value))
                case let .media(value): return .media(.convert(value))
                case let .tool(value): return .tool(.convert(value))
                case let .other(value): return .other(.convert(value))
                }
            }
        }
        
        enum ChangeColor {
            case textColor(UIColor)
            case backgroundColor(UIColor)
        }
        
        enum EditAction {
            case delete, duplicate
        }

        /// Do not delete this commented code.
        /// It may be needed later.
//        enum EditBlock {
//            case delete
//            case duplicate
//            case undo
//            case redo
//            static func convert(_ type: BlocksViews.Toolbar.EditActions.Action) -> Self {
//                switch type {
//                case .delete: return .delete
//                case .duplicate: return .duplicate
//                case .undo: return .undo
//                case .redo: return .redo
//                }
//            }
//        }
//        enum ChangeColor {
//            case textColor(UIColor)
//            case backgroundColor(UIColor)
//            // TODO: Add type that wraps textColor and backgroundColor like this type.
//            static func convert(_ type: (UIColor?, UIColor?)) -> Self? {
//                if let first = type.0 {
//                    return .textColor(first)
//                }
//                else if let second = type.1 {
//                    return .backgroundColor(second)
//                }
//                return nil
//            }
//        }
        
        case addBlock(BlockType), turnIntoBlock(BlockType), changeColor(ChangeColor), editBlock(EditAction)
    }
}

// MARK: UnderlyingAction / BlockType / Text
extension BlocksViews.Toolbar.UnderlyingAction.BlockType {
    enum Text {
        fileprivate typealias UserInterfaceValue = BlocksViews.Toolbar.AddBlock.BlocksTypes.Text
        fileprivate static func convert(_ type: UserInterfaceValue) -> Self {
            switch type {
            case .text: return .text
            case .h1: return .h1
            case .h2: return .h2
            case .h3: return .h3
            case .highlighted: return .highlighted
            }
        }
        case text, h1, h2, h3, highlighted
    }
}

// MARK: UnderlyingAction / BlockType / List
extension BlocksViews.Toolbar.UnderlyingAction.BlockType {
    enum List {
        fileprivate typealias UserInterfaceValue = BlocksViews.Toolbar.AddBlock.BlocksTypes.List
        fileprivate static func convert(_ type: UserInterfaceValue) -> Self {
            switch type {
            case .bulleted: return .bulleted
            case .checkbox: return .checkbox
            case .numbered: return .numbered
            case .toggle: return .toggle
            }
        }
        case bulleted, checkbox, numbered, toggle
    }
}

// MARK: UnderlyingAction / BlockType / Page
extension BlocksViews.Toolbar.UnderlyingAction.BlockType {
    enum Page {
        fileprivate typealias UserInterfaceValue = BlocksViews.Toolbar.AddBlock.BlocksTypes.Page
        fileprivate static func convert(_ type: UserInterfaceValue) -> Self {
            switch type {
            case .page: return .page
            case .existingTool: return .existingPage
            }
        }
        case page, existingPage
    }
}

// MARK: UnderlyingAction / BlockType / Media
extension BlocksViews.Toolbar.UnderlyingAction.BlockType {
    enum Media {
        fileprivate typealias UserInterfaceValue = BlocksViews.Toolbar.AddBlock.BlocksTypes.Media
        fileprivate static func convert(_ type: UserInterfaceValue) -> Self {
            switch type {
            case .file: return .file
            case .picture: return .picture
            case .video: return .video
            case .bookmark: return .bookmark
            case .code: return .code
            }
        }
        case file, picture, video, bookmark, code
    }
}

// MARK: UnderlyingAction / BlockType / Tool
extension BlocksViews.Toolbar.UnderlyingAction.BlockType {
    enum Tool {
        fileprivate typealias UserInterfaceValue = BlocksViews.Toolbar.AddBlock.BlocksTypes.Tool
        fileprivate static func convert(_ type: UserInterfaceValue) -> Self {
            switch type {
            case .contact: return .contact
            case .database: return .database
            case .set: return .set
            case .task: return .task
            }
        }
        case contact, database, set, task
    }
}

// MARK: UnderlyingAction / BlockType / Other
extension BlocksViews.Toolbar.UnderlyingAction.BlockType {
    enum Other {
        fileprivate typealias UserInterfaceValue = BlocksViews.Toolbar.AddBlock.BlocksTypes.Other
        fileprivate static func convert(_ type: UserInterfaceValue) -> Self {
            switch type {
            case .divider: return .divider
            case .dots: return .dots
            }
        }
        case divider, dots
    }
}
