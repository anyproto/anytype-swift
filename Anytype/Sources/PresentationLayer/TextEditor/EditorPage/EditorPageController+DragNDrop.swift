import UIKit

extension EditorPageController: UICollectionViewDropDelegate {
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        var destinationIndexPath: IndexPath?

        collectionView.performUsingPresentationValues {
            let location = coordinator.session.location(in: collectionView)
            destinationIndexPath = collectionView.indexPathForItem(at: location)
        }

        reorderItems(
            coordinator: coordinator,
            destinationIndexPath: destinationIndexPath,
            collectionView: collectionView
        )

        dividerCursorController.movingMode = .none
    }

    func collectionView(_ collectionView: UICollectionView, dropSessionDidEnd session: UIDropSession) {
        dividerCursorController.movingMode = .none
    }

    func collectionView(
        _ collectionView: UICollectionView,
        dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
        dividerCursorController.movingMode = .dragNdrop
        let indexPath = desiredIndexPath(using: destinationIndexPath)

        guard viewModel.blocksStateManager.canPlaceDividerAtIndexPath(indexPath) else {
            dividerCursorController.moveCursorView.isHidden = true

            return UICollectionViewDropProposal(operation: .forbidden)
        }

        collectionView.performUsingPresentationValues {
            let location = session.location(in: collectionView)
            dividerCursorController.adjustDivider(at: location)
        }

        return UICollectionViewDropProposal(
            operation: .move,
            intent: .insertIntoDestinationIndexPath
        )
    }

    private func desiredIndexPath(using destinationIndexPath: IndexPath?) -> IndexPath {
        if let destinationIndexPath = destinationIndexPath {
            return destinationIndexPath
        } else {
            let lastIndexPath = collectionView.lastIndexPath
            return .init(row: lastIndexPath.row + 1, section: lastIndexPath.section)
        }
    }

    private func reorderItems(
        coordinator: UICollectionViewDropCoordinator,
        destinationIndexPath: IndexPath?,
        collectionView: UICollectionView
    ) {
        dividerCursorController.moveCursorView.isHidden = true

        collectionView.deselectAllSelectedItems()
        
        guard let item = coordinator.items.first,
              let blockDragConfiguration = item.dragItem.localObject as? BlockDragConfiguration else {
            return
        }

        viewModel.blocksStateManager.moveItem(with: blockDragConfiguration)
    }
}
