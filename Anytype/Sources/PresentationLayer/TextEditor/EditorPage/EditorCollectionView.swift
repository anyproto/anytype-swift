import UIKit

class EditorCollectionView: UICollectionView {
    private(set) var indexPathsForMovingItems = Set<IndexPath>()
    var isLocked: Bool = false {
        didSet {
            visibleCells.forEach {
                ($0 as? CustomTypesAccessable)?.isLocked = isLocked
            }
        }
    }

    func deselectAllMovingItems() {
        indexPathsForMovingItems.forEach { indexPath in
            setItemIsMoving(false, at: indexPath)
        }

        indexPathsForMovingItems.removeAll()
    }

    func setItemIsMoving(_ isMoving: Bool, at indexPath: IndexPath) {
        if isMoving && !indexPathsForMovingItems.contains(indexPath) {
            indexPathsForMovingItems.insert(indexPath)
        } else if !isMoving && indexPathsForMovingItems.contains(indexPath) {
            indexPathsForMovingItems.remove(indexPath)
        }

        if indexPathsForMovingItems.contains(indexPath) {
            indexPathsForMovingItems.insert(indexPath)
        }

        setCelIsMoving(isMoving: isMoving, at: indexPath)
    }

    private func setCelIsMoving(isMoving: Bool, at indexPath: IndexPath) {
        let cell = cellForItem(at: indexPath) as? CustomTypesAccessable

        cell?.isMoving = isMoving
    }

    func adjustContentOffsetForSelectedItem(relatively relativeView: UIView) {
        guard let firstSelectedItem = indexPathsForSelectedItems?.first else { return }
        guard let itemAttributes = layoutAttributesForItem(at: firstSelectedItem)  else { return }


        let viewRectInCollection = relativeView.convert(relativeView.bounds, to: self)
        let intersectView = viewRectInCollection.intersects(itemAttributes.frame)

        // take in account top of adjustedContentInset
        let adjustedCollectionY = bounds.origin.y + adjustedContentInset.top
        let adjustedCollectionBounds = CGRect(origin: .init(x: bounds.origin.x, y: adjustedCollectionY), size: bounds.size)
        let visibleInCollection = itemAttributes.frame.intersects(adjustedCollectionBounds)


        // if visible block or intersect view than do nothing
        if !intersectView, visibleInCollection {
            contentInset.bottom = relativeView.bounds.height
            return
        }

        var yOffset: CGFloat = 0

        // if cell is above of view show view on the top edge of the collection view
        if itemAttributes.frame.maxY < viewRectInCollection.minY {
            yOffset = itemAttributes.frame.minY - adjustedContentInset.top
        } else { // if cell is below view show selected item above this view
            yOffset = itemAttributes.frame.maxY - bounds.height + relativeView.bounds.height + relativeView.layoutMargins.bottom
        }

        setContentOffset(CGPoint(x: 0.0, y: yOffset), animated: true)
        contentInset.bottom = relativeView.bounds.height
    }
}
