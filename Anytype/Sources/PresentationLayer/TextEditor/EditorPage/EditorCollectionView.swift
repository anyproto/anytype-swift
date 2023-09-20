import UIKit

class EditorCollectionView: UICollectionView {
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        setup()
    }
    
    private func setup() {
        alwaysBounceVertical = true
    }
    
//    override var adjustedContentInset: UIEdgeInsets {
//        .init(
//            top: 0,
//            left: super.adjustedContentInset.left,
//            bottom: super.adjustedContentInset.bottom,
//            right: super.adjustedContentInset.right
//        )
//    }

    var isLocked: Bool = false {
        didSet {
            visibleCells.forEach {
                ($0 as? CustomTypesAccessable)?.isLocked = isLocked
            }
        }
    }
    
    override func setContentOffset(_ contentOffset: CGPoint, animated: Bool) {
        if contentOffset == .zero {
            print("ZEROOO")
        }
        super.setContentOffset(contentOffset, animated: animated)
    }

    private(set) var indexPathsForMovingItems = Set<IndexPath>()

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
        guard let lastSelectedItem = indexPathsForSelectedItems?.last else { return }
        guard let itemAttributes = layoutAttributesForItem(at: lastSelectedItem)  else { return }


        let viewRectInCollection = relativeView.convert(relativeView.bounds, to: self)
        let isRelativeViewIntersectedByCell = viewRectInCollection.intersects(itemAttributes.frame)

        // take in account top of collection adjustedContentInset
        let adjustedCollectionY = bounds.origin.y + adjustedContentInset.top
        let adjustedCollectionBounds = CGRect(origin: .init(x: bounds.origin.x, y: adjustedCollectionY), size: bounds.size)
        let visibleInCollection = itemAttributes.frame.intersects(adjustedCollectionBounds)


        // if cell is visible and not intersects relativeView than do nothing
        if !isRelativeViewIntersectedByCell, visibleInCollection {
            contentInset.bottom = relativeView.bounds.height
            return
        }

        var yOffset: CGFloat = 0

        // if cell is above of view show view on the top edge of the collection view
        if itemAttributes.frame.maxY < viewRectInCollection.minY {
            yOffset = itemAttributes.frame.minY - adjustedContentInset.top
        } else { // if cell is below relative view show selected item above this view
            yOffset = itemAttributes.frame.maxY - bounds.height + relativeView.bounds.height + relativeView.layoutMargins.bottom
        }

        setContentOffset(CGPoint(x: 0.0, y: yOffset), animated: true)
        contentInset.bottom = relativeView.bounds.height
    }
}
