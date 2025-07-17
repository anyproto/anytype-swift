import Foundation
import UIKit


struct LayoutItem {
    var x: CGFloat
    var y: CGFloat
    var ownPreferedHeight: CGFloat
    var height: CGFloat
    var zIndex: Int
    var indexPath: IndexPath
    
    /// Creates layout attributes for item at given indexPath
    @MainActor
    func attributes(collectionViewWidth: CGFloat) -> UICollectionViewLayoutAttributes {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
        attributes.frame = CGRect(
            x: x,
            y: y,
            width: collectionViewWidth - x,
            height: height
        )
        // If you don't set zIndex you can ocassionally end up with incorrect initial layout size
        attributes.zIndex = zIndex
        return attributes
    }
}
