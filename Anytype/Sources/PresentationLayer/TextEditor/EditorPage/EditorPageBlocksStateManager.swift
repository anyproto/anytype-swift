import BlocksModels
import UIKit

protocol EditorPageMovingManagerProtocol {
    var movingBlocksIndexPaths: [IndexPath]? { get }
    var dividerPositionIndexPath: IndexPath? { get }

    func canPlaceDividerAtIndexPath(_ indexPath: IndexPath) -> Bool
}

protocol EditorPageSelectionManagerProtocol {
    var selectedBlocksIndexPaths: [IndexPath]? { get }

    func didUpdateSelectedIndexPaths(_ indexPaths: [IndexPath])
}

protocol EditorPageBlocksStateManagerProtocol: EditorPageSelectionManagerProtocol, EditorPageMovingManagerProtocol { }

final class EditorPageBlocksStateManager: EditorPageBlocksStateManagerProtocol {
    private(set) var selectedBlocksIndexPaths = [IndexPath]()
    private(set) var movingBlocksIndexPaths: [IndexPath]? = [IndexPath]()
    private(set) var dividerPositionIndexPath: IndexPath?

    private let modelsHolder: BlockViewModelsHolder

    init(modelsHolder: BlockViewModelsHolder) {
        self.modelsHolder = modelsHolder
    }


    // MARK: - Methods for handling centered screen indexPath

    func canPlaceDividerAtIndexPath(_ indexPath: IndexPath) -> Bool {
        let notAllowedTypes: [BlockContentType] = [.text(.title), .featuredRelations]

        if let element = modelsHolder.models[safe: indexPath.row],
           !notAllowedTypes.contains(element.content.type) {
            dividerPositionIndexPath = indexPath
            return true
        }

        // Divider can be placed at the bottom of last cell.
        if indexPath.row == modelsHolder.models.count {
            dividerPositionIndexPath = indexPath
            return true
        }

        return false
    }
}
