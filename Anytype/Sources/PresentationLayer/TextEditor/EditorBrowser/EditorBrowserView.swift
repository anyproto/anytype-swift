import Foundation
import UIKit

final class EditorBrowserView: UIView {
    
    // Forward touches for drag and drop.
    // When user move object to navigation bar or bottom bar,
    // scroll is disabled because collection don't get touch event.
    weak var childCollectionView: UICollectionView?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let childCollectionView = childCollectionView,
              childCollectionView.hasActiveDrag || childCollectionView.hasActiveDrop else {
            return super.hitTest(point, with: event)
        }
        return childCollectionView.hitTest(point, with: event) ?? childCollectionView
    }
}
