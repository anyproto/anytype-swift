
import UIKit

extension UICollectionView {
    
    func deselectAllSelectedItems(animated: Bool = true) {
        self.indexPathsForSelectedItems?.forEach { self.deselectItem(at: $0, animated: animated) }
    }
    
    func selectAllItems(animated: Bool = true,
                        in section: Int = 0,
                        startingFrom startIndex: Int = 0) {
        let itemsCount = self.numberOfItems(inSection: section)
        guard itemsCount > startIndex else { return }
        (startIndex..<itemsCount).forEach {
            self.selectItem(at: IndexPath(item: $0, section: section), animated: true, scrollPosition: [])
        }
    }
}
