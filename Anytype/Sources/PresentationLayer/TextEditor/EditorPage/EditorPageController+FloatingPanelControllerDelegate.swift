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

    func floatingPanel(_ fpc: FloatingPanelController, shouldRemoveAt location: CGPoint, with velocity: CGVector) -> Bool {
        let surfaceOffset = fpc.surfaceLocation.y - fpc.surfaceLocation(for: .full).y
        // If panel moved more than a half of its hight than hide panel
        if fpc.surfaceView.bounds.height / 2 < surfaceOffset {
            return true
        }
        return false
    }
}
