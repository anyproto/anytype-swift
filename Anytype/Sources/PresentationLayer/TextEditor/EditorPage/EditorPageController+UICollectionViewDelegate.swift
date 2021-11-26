import UIKit
import Amplitude
import BlocksModels

// MARK: - UICollectionViewDelegate

extension EditorPageController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        guard !dividerCursorController.isMovingModeEnabled else { return }
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
        case .header:
            return false
        }
    }

    func collectionView(_ collectionView: UICollectionView, canEditItemAt indexPath: IndexPath) -> Bool {
        return collectionView.isEditing
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        NotificationCenter.default.post(
            name: .editorCollectionContentOffsetChangeNotification,
            object: scrollView.contentOffset.y
        )
    }
}
