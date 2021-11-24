import UIKit

class EditorCollectionView: UICollectionView {
    private(set) var indexPathsForMovingItems = [IndexPath]()

    func setItemIsMoving(_ isMoving: Bool, at indexPath: IndexPath) {
        if isMoving && !indexPathsForMovingItems.contains(indexPath) {
            indexPathsForMovingItems.append(indexPath)
        } else if !isMoving && indexPathsForMovingItems.contains(indexPath) {
            indexPathsForMovingItems.firstIndex(of: indexPath).map {
                indexPathsForMovingItems.remove(at: $0)
            }
        }
        if indexPathsForMovingItems.contains(indexPath) {
            indexPathsForMovingItems.append(indexPath)
        }

        let cell = cellForItem(at: indexPath)
        let contentView = cell?.contentView as? CustomTypesAccessable

        contentView?.isMoving = isMoving
    }

    override func reloadData() {
        super.reloadData()

        indexPathsForMovingItems.forEach { indexPath in
            setItemIsMoving(true, at: indexPath)
        }
    }
}
