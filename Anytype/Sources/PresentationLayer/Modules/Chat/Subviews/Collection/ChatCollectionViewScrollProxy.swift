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
    case scrollTo(_ itemId: String, _ position: ChatCollectionScrollPosition)
}

struct ChatCollectionScrollProxy: Equatable {
    private(set) var operationId = UUID()
    private(set) var scrollOperation: ChatCollectionScrollOperation?
    
    mutating func scrollTo(itemId: String, position: ChatCollectionScrollPosition = .center) {
        operationId = UUID()
        scrollOperation = .scrollTo(itemId, position)
    }
}
