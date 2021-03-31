//
//  BlocksViews+New+Tools.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.06.2020.
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
extension BlocksViews.New.Tools {
    enum PageLink {} // -> New Page. Holding link.
    enum Base {} // Base ViewModel
}

extension BlocksViews.New.Tools.Base {
    /// Base View Model that all ToolsBlocksViews.BlockViewModel will inherit from.
    /// Add common behavior to this class.
    ///
    class ViewModel: BlocksViews.New.Base.ViewModel {
        @Environment(\.developerOptions) var developerOptions
    }
}
