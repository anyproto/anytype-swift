//
//  PageBlocksViews.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 28.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI

/// For now we distinguish PageBlocksViews.
/// This namespace refer to all views that are categorized as `Page` in our GUI.
/// Feel free to add implemented pages entries into list.
/// When you are ready or about to start, please, add new `enum` entry as `enum NewPageEntry` into list.
/// Implement it.
///
enum PageBlocksViews {
    enum Title {}
    enum IconEmoji {}
}

extension PageBlocksViews {
    enum Base {} // Base ViewModel
    enum Supplement {} // Actually, for Flattener and other unrelated to ViewModels stuff.
}

extension PageBlocksViews.Base {
    /// Base View Model that all ToolsBlocksViews.BlockViewModel will inherit from.
    /// Add common behavior to this class.
    ///
    class BlockViewModel: BlocksViews.Base.ViewModel {
        @Environment(\.developerOptions) var developerOptions
        private weak var delegate: TextBlocksViewsUserInteractionProtocol? // Do we need it?
        private(set) var pageDetailsViewModel: DocumentViewModel.PageDetailsViewModel?
        
        // MARK: Subclassing
        func onIncoming(event: Events) {}
    }
}

extension PageBlocksViews.Base {
    enum Events {
        case pageDetailsViewModelDidSet
    }
}

extension PageBlocksViews.Base.BlockViewModel {
    func configured(pageDetailsViewModel: DocumentViewModel.PageDetailsViewModel?) -> Self {
        self.pageDetailsViewModel = pageDetailsViewModel
        self.onIncoming(event: .pageDetailsViewModelDidSet)
        return self
    }
}
