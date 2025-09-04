
import UIKit

extension UICollectionView {

    var lastIndexPath: IndexPath {
        let section = max(numberOfSections - 1, 0)
        let row = max(numberOfItems(inSection: section) - 1, 0)

        return IndexPath(row: row, section: section)
    }
    
    func deselectAllSelectedItems(animated: Bool = true) {
        self.indexPathsForSelectedItems?.forEach { self.deselectItem(at: $0, animated: animated) }
    }
    
    func selectAllItems(
        animated: Bool = true,
        in section: Int = 0,
        startingFrom startIndex: Int = 0
    ) {
        let itemsCount = self.numberOfItems(inSection: section)
        guard itemsCount > startIndex else { return }
        (startIndex..<itemsCount).forEach {
            self.selectItem(at: IndexPath(item: $0, section: section), animated: true, scrollPosition: [])
        }
    }
    
    func scrollToItem(at indexPath: IndexPath, at scrollPosition: UICollectionView.ScrollPosition, animated: Bool, completion: (() -> Void)? = nil) {
        if animated {
            CATransaction.begin()
            CATransaction.setCompletionBlock {
                completion?()
            }
            scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
            CATransaction.commit()
        } else {
            scrollToItem(at: indexPath, at: scrollPosition, animated: animated)
            completion?()
        }
    }
}
