import Foundation
import SwiftUI

enum PageBlockViewEvents {
    case pageDetailsViewModelDidSet
}

/// Base View Model that all ToolsBlocksViews.BlockViewModel will inherit from.
/// Add common behavior to this class.
///
class PageBlockViewModel: BlocksViews.Base.ViewModel {
    /// This DetailsViewModel could be extracted somewhere.
    /// Somewhere near EventHandler.
    typealias PageDetailsViewModel = DetailsActiveModel
    private(set) var pageDetailsViewModel: PageDetailsViewModel?
    
    // MARK: Subclassing
    func onIncoming(event: PageBlockViewEvents) {}

    func configured(pageDetailsViewModel: PageDetailsViewModel?) -> Self {
        self.pageDetailsViewModel = pageDetailsViewModel
        self.onIncoming(event: .pageDetailsViewModelDidSet)
        return self
    }
}
