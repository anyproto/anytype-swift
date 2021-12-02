import UIKit

class EditorCollectionView: UICollectionView {
    private(set) var indexPathsForMovingItems = Set<IndexPath>()

    func deselectAllMovingItems() {
        indexPathsForMovingItems.removeAll()

        reloadData()
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

    override func cellForItem(at indexPath: IndexPath) -> UICollectionViewCell? {
        let cell = super.cellForItem(at: indexPath)

        let contentView = cell?.contentView as? CustomTypesAccessable
        contentView?.isMoving = indexPathsForMovingItems.contains(indexPath)

        return cell
    }

    private func setCelIsMoving(isMoving: Bool, at indexPath: IndexPath) {
        let cell = cellForItem(at: indexPath)
        let contentView = cell?.contentView as? CustomTypesAccessable

        contentView?.isMoving = isMoving
    }
}
