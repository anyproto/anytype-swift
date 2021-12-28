import UIKit

extension EditorPageController: UICollectionViewDragDelegate {
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard collectionView.isEditing,
              viewModel.blocksStateManager.canSelectBlock(at: indexPath),
              let item = collectionView.cellForItem(at: indexPath),
              !view.isAnySubviewFirstResponder()
        else { return [] }

        let itemProvider = NSItemProvider(object: item.description as NSItemProviderWriting)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = dragItem

        return [dragItem]
    }

    func collectionView(_ collectionView: UICollectionView, dragSessionWillBegin session: UIDragSession) {
        dividerCursorController.movingMode = .dragNdrop
    }

    func collectionView(_ collectionView: UICollectionView, dragSessionDidEnd session: UIDragSession) {
        dividerCursorController.movingMode = .none
        collectionView.deselectAllSelectedItems()
    }
}

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
    }

    func collectionView(
        _ collectionView: UICollectionView,
        dropSessionDidUpdate session: UIDropSession,
        withDestinationIndexPath destinationIndexPath: IndexPath?
    ) -> UICollectionViewDropProposal {
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
            intent: .insertIntoDestinationIndexPath)
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

        guard let item = coordinator.items.first,
              let sourceIndexPath = item.sourceIndexPath
        else {
            return
        }

        viewModel.blocksStateManager.moveItem(at: sourceIndexPath)

        collectionView.deselectAllSelectedItems()
    }
}
