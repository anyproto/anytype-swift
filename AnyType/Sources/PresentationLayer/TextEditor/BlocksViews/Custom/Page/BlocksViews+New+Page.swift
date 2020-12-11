//
//  BlocksViews+New+Page.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 08.06.2020.
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
extension BlocksViews.New.Page {
    enum Title {}
    enum IconEmoji {}
}

extension BlocksViews.New.Page {
    enum Base {} // Base ViewModel
}

extension BlocksViews.New.Page.Base {
    /// Base View Model that all ToolsBlocksViews.BlockViewModel will inherit from.
    /// Add common behavior to this class.
    ///
    class ViewModel: BlocksViews.New.Base.ViewModel {
        /// This DetailsViewModel could be extracted somewhere.
        /// Somewhere near EventHandler.
        typealias PageDetailsViewModel = DocumentModule.Document.ViewController.ViewModel.PageDetailsViewModel
        @Environment(\.developerOptions) var developerOptions
        private(set) var pageDetailsViewModel: PageDetailsViewModel?
        
        // MARK: Subclassing
        func onIncoming(event: Events) {}
    }
}

extension BlocksViews.New.Page.Base {
    enum Events {
        case pageDetailsViewModelDidSet
    }
}

extension BlocksViews.New.Page.Base.ViewModel {
    func configured(pageDetailsViewModel: PageDetailsViewModel?) -> Self {
        self.pageDetailsViewModel = pageDetailsViewModel
        self.onIncoming(event: .pageDetailsViewModelDidSet)
        return self
    }
}
