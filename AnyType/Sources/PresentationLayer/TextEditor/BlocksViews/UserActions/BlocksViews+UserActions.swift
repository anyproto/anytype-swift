//
//  BlocksViews+UserActions.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 16.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine

// MARK: - UserAction
extension BlocksViews {
    typealias Model = BlockModels.Block.RealBlock
    /// Top-level user action.
    /// All parsing is starting from this enumeration.
    ///
    enum UserAction {
        // when a model is about to update.
        case updated(Model)
        case toolbars(ToolbarOpenAction)
        case specific(SpecificAction)
    }
}

// MARK: - Specific Action
extension BlocksViews.UserAction {
    /// Specific action for each specific blocks views type.
    /// You should define a `.UserAction` payload enumeration in each namespace.
    /// After that you could add it as an entry of this enum.
    ///
    enum SpecificAction {
        case tool(ToolsBlocksViews.UserAction)
        case file(FileBlocksViews.UserAction)
        case page(PageBlocksViews.UserAction)
    }
}

// MARK: - ToolbarOpenAction
extension BlocksViews.UserAction {
    /// Toolbar Open action.
    /// When you would like to open specific toolbar, you should add new entry in enumeration.
    /// After that you need to process this entry in specific ToolbarRouter.
    ///
    enum ToolbarOpenAction: Equatable {
        static func == (lhs: BlocksViews.UserAction.ToolbarOpenAction, rhs: BlocksViews.UserAction.ToolbarOpenAction) -> Bool {
            switch (lhs, rhs) {
            case (.addBlock, .addBlock): return true
            case (.turnIntoBlock, .turnIntoBlock): return true
            default: return false
            }
        }
        
        case addBlock(AddBlock)
        case turnIntoBlock(TurnIntoBlock)
        case marksPane(MarksPane)
    }
}

extension BlocksViews.UserAction.ToolbarOpenAction {
    struct AddBlock {
        typealias Output = PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>
        typealias Input = Void
        var output: Output
    }
    
    struct TurnIntoBlock {
        typealias Output = PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>
        var output: Output
    }
}

extension BlocksViews.UserAction.ToolbarOpenAction {
    enum MarksPane {
        case setTextColor(TextColor)
        case setBackgroundColor(BackgroundColor)
        case setStyle(Style)
        case mainPane(MainPane)
    }
}

extension BlocksViews.UserAction.ToolbarOpenAction.MarksPane {
    struct MainPane {
        typealias Output = PassthroughSubject<MarksPane.Main.Action, Never>
        typealias Input = MarksPane.Main.RawUserResponse
        var output: Output
        var input: Input?
    }
}

extension BlocksViews.UserAction.ToolbarOpenAction.MarksPane {
    struct TextColor {
        typealias Output = PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>
        typealias Input = MarksPane.Panes.Color.UserResponse
        var output: Output
        var input: Input?
    }
    
    struct BackgroundColor {
        typealias Output = PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>
        typealias Input = MarksPane.Panes.Color.UserResponse
        var output: Output
        var input: Input?
    }
    
    struct Style {
        typealias Output = PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never>
        typealias Input = MarksPane.Panes.StylePane.UserResponse
        var output: Output
        var input: Input?
    }
}
