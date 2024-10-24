import UIKit
import Services

// MARK: - UICollectionViewDelegate

extension EditorPageController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if collectionView.isEditing {
            viewModel.didSelectBlock(at: indexPath)
            collectionView.deselectItem(at: indexPath, animated: false)
        } else {
            didSelectItems(collectionView: collectionView)
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didDeselectItemAt indexPath: IndexPath
    ) {
        didSelectItems(collectionView: collectionView)
    }
    
    func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        guard dividerCursorController.movingMode != .drum  else { return false }

        if dataSource.snapshot().sectionIdentifiers[indexPath.section] == .header {
                    return false
                }
        return true
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        shouldSelectItemAt indexPath: IndexPath
    ) -> Bool {
        canSelect(indexPath: indexPath, collection: collectionView)
    }

    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return collectionView.isEditing
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yTranslation = scrollView.panGestureRecognizer.translation(in: scrollView.superview).y
        bottomNavigationManager.onScroll(bottom: yTranslation < 0)

        NotificationCenter.default.post(
            name: .editorCollectionContentOffsetChangeNotification,
            object: scrollView.contentOffset.y
        )
    }
    
    func canSelect(indexPath: IndexPath, collection: UICollectionView? = nil) -> Bool {
        let collectionView = collection ?? collectionView
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch item {
        case let .block(block):
            if case .text = block.content, collectionView.isEditing { return false }
            return viewModel.blocksStateManager.canSelectBlock(at: indexPath)
        case .header, .system:
            return false
        }
    }
    
    private func didSelectItems(collectionView: UICollectionView) {
        guard let selectedItems = collectionView.indexPathsForSelectedItems else { return }
        viewModel.blocksStateManager.didUpdateSelectedIndexPathsResetIfNeeded(selectedItems, allSelected: isAllSelected())
    }
}
