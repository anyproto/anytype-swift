import Foundation
import UIKit

enum DiscussionCollectionScrollPosition: Equatable {
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

enum DiscussionCollectionScrollOperation: Equatable {
    case scrollTo(_ itemId: String, _ position: DiscussionCollectionScrollPosition)
}

struct DiscussionCollectionScrollProxy: Equatable {
    private(set) var operationId = UUID()
    private(set) var scrollOperation: DiscussionCollectionScrollOperation?
    
    mutating func scrollTo(itemId: String, position: DiscussionCollectionScrollPosition = .center) {
        operationId = UUID()
        scrollOperation = .scrollTo(itemId, position)
    }
}
