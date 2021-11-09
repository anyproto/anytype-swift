import UIKit
import Amplitude
import BlocksModels

// MARK: - UICollectionViewDelegate

extension EditorPageController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        if collectionView.isEditing {
            guard let item = dataSource.itemIdentifier(for: indexPath) else { return }
            if case let .block(block) = item, case .text = block.content { return }

            viewModel.didSelectBlock(at: indexPath)
            collectionView.deselectItem(at: indexPath, animated: false)
        } else {
            // View model handle selection
        }
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didDeselectItemAt indexPath: IndexPath
    ) {
        // View model handle selection
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
        case .block:
            return true
        case .header:
            return false
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        contextMenuConfigurationForItemAt indexPath: IndexPath,
        point: CGPoint
    ) -> UIContextMenuConfiguration? {
        return nil
        guard let item = dataSource.itemIdentifier(for: indexPath) else { return nil }

        switch item {
        case let .block(block):
            // Analytics
            Amplitude.instance().logEvent(AmplitudeEventsName.popupActionMenu)
            
            return block.contextMenuConfiguration()
        case .header:
                    return nil
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
