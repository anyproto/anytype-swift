//
//  BlocksViews+UserActions.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 16.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

// MARK: - UserAction
extension BlocksViews {
    typealias Model = BlockModels.Block.RealBlock
    /// Top-level user action.
    /// All parsing is starting from this enumeration.
    ///
    enum UserAction {
        // when a model is about to update.
        case updated(Model)
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
    }
}
