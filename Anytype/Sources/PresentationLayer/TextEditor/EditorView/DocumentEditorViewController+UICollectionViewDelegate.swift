import UIKit
import Amplitude
import BlocksModels

// MARK: - UICollectionViewDelegate

extension DocumentEditorViewController: UICollectionViewDelegate {
    
    func collectionView(
        _ collectionView: UICollectionView,
        didSelectItemAt indexPath: IndexPath
    ) {
        viewModel.didSelectBlock(at: indexPath)
        collectionView.deselectItem(at: indexPath, animated: false)
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        didDeselectItemAt indexPath: IndexPath
    ) {
        return
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
            if case .text = block.content { return false }
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
    
}
