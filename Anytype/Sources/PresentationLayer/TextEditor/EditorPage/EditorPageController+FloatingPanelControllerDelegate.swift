import UIKit
import FloatingPanel
import BlocksModels

// MARK: - FloatingPanelControllerDelegate

extension EditorPageController: FloatingPanelControllerDelegate {
    
    func floatingPanelDidRemove(_ fpc: FloatingPanelController) {
        UIView.animate(withDuration: CATransaction.animationDuration()) { [unowned self] in
            insetsHelper?.restoreEditingOffset()
        }

        guard let selectedIndexPath = collectionView.indexPathsForSelectedItems?.first else { return }
        
        collectionView.deselectAllSelectedItems()

        guard let item = dataSource.itemIdentifier(for: selectedIndexPath) else { return }
        
        switch item {
        case let .block(block):
            if let blockViewModel = block as? TextBlockViewModel {
                blockViewModel.set(focus: .end)
            }
        case .header, .system:
            return
        }
    }

    func adjustContentOffset(fpc: FloatingPanelController) {
        let selectedItems: [IndexPath] = collectionView.indexPathsForSelectedItems ?? []

        // find first visible blocks
        let closestItem = selectedItems.first { indexPath in
            collectionView.indexPathsForVisibleItems.contains(indexPath)
        }

        // if visible block was found
        if let closestItem = closestItem {
            guard let itemCell = collectionView.cellForItem(at: closestItem) else { return }
            let itemPointInCollection = itemCell.convert(itemCell.bounds, to: view)

            // if visible block not intersect style menu than do nothing
            if !itemPointInCollection.intersects(fpc.surfaceView.frame) {
                collectionView.contentInset.bottom = fpc.surfaceView.bounds.height
                return
            }
        }
        // if visible block intersect style menu or block is not visible than calculate collectionView contentOffset
        guard let closestItem = closestItem == nil ? selectedItems.first : closestItem else { return }
        guard let closestItemAttributes = collectionView.layoutAttributesForItem(at: closestItem)  else { return }

        let yOffset = closestItemAttributes.frame.maxY - collectionView.bounds.height + fpc.surfaceView.bounds.height + fpc.surfaceView.layoutMargins.bottom
        collectionView.setContentOffset(CGPoint(x: 0.0, y: yOffset), animated: true)
        collectionView.contentInset.bottom = fpc.surfaceView.bounds.height
    }

    func floatingPanel(_ fpc: FloatingPanelController, shouldRemoveAt location: CGPoint, with velocity: CGVector) -> Bool {
        let surfaceOffset = fpc.surfaceLocation.y - fpc.surfaceLocation(for: .full).y
        // If panel moved more than a half of its hight than hide panel
        if fpc.surfaceView.bounds.height / 2 < surfaceOffset {
            return true
        }
        return false
    }
}
