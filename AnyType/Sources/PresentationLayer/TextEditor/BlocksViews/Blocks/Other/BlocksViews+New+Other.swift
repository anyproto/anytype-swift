//
//  BlocksViews+New+Other.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 22.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI

/// For now we distinguish OtherBlocksViews.
/// This namespace refer to all views that are categorized as `Other` in our GUI.
/// List of these blocks will be finished later, for now we only have only blocks below.
/// Feel free to add implemented blocks into list.
/// When you are ready or about to start, please, add new `enum` entry as `enum NewEntry` into list.
/// Don't forget to implement it.
///
extension BlocksViews.New.Other {
    enum Divider {} // -> Divider. Has Styles.
    enum Base {} // Base ViewModel
}

extension BlocksViews.New.Other.Base {
    /// Base View Model that all ToolsBlocksViews.BlockViewModel will inherit from.
    /// Add common behavior to this class.
    ///
    class ViewModel: BlocksViews.New.Base.ViewModel {
        @Environment(\.developerOptions) var developerOptions
    }
}
