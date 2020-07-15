//
//  ToolsBlocksViews.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 13.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI

/// For now we distinguish ToolsBlocksViews.
/// This namespace refer to all views that are categorized as `Tools` in our GUI.
/// List of these tools will be finished later, for now we only have only tools below.
/// Feel free to add implemented tools into list.
/// When you are ready or about to start, please, add new `enum` entry as `enum NewTool` into list.
/// Implement it.
///
enum ToolsBlocksViews {
    enum PageLink {} // -> New Page. Holding link.
}

extension ToolsBlocksViews {
    enum Base {} // Base ViewModel
    enum Supplement {} // Actually, for Flattener and other unrelated to ViewModels stuff.
}

extension ToolsBlocksViews.Base {
    /// Base View Model that all ToolsBlocksViews.BlockViewModel will inherit from.
    /// Add common behavior to this class.
    ///
    class BlockViewModel: BlocksViews.Base.ViewModel {
        @Environment(\.developerOptions) var developerOptions
        private weak var delegate: TextBlocksViewsUserInteractionProtocol? // Do we need it?
    }
}
