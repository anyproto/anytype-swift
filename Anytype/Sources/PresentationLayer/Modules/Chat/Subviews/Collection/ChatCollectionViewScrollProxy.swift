import Foundation
import UIKit

enum ChatCollectionScrollPosition: Equatable {
    case top
    case center
    case bottom
    
    var collectionViewPosition: UICollectionView.ScrollPosition {
        switch self {
        case .top:
            return .top
        case .center:
            return .centeredVertically
        case .bottom:
            return .bottom
        }
    }
}

enum ChatCollectionScrollOperation: Equatable {
    case scrollTo(_ itemId: String, _ position: ChatCollectionScrollPosition, _ animated: Bool)
}

struct ChatCollectionScrollProxy: Equatable {
    private(set) var operationId = UUID()
    private(set) var scrollOperation: ChatCollectionScrollOperation?
    private(set) var refreshVisibleRangeOperationId: UUID?

    mutating func scrollTo(itemId: String, position: ChatCollectionScrollPosition = .center, animated: Bool = true) {
        operationId = UUID()
        scrollOperation = .scrollTo(itemId, position, animated)
    }

    /// Request a one-shot re-emit of the current visible range with `forceUpdate: true`.
    /// Use after a programmatic scroll when the collection view's visible range may not
    /// have changed but you still need to re-trigger downstream tracking (e.g. mark-as-read).
    mutating func refreshVisibleRange() {
        refreshVisibleRangeOperationId = UUID()
    }
}
