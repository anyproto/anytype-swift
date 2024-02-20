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
            collectionView.indexPathsForSelectedItems.map(
                viewModel.blocksStateManager.didUpdateSelectedIndexPaths
            )
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didDeselectItemAt indexPath: IndexPath
    ) {
        collectionView.indexPathsForSelectedItems.map(
            viewModel.blocksStateManager.didUpdateSelectedIndexPaths
        )
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
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return false }
        
        switch item {
        case let .block(block):
            if case .text = block.content, collectionView.isEditing { return false }

            return viewModel.blocksStateManager.canSelectBlock(at: indexPath)
        case .header, .system:
            return false
        }
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
}
