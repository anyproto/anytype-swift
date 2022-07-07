import Combine
import Foundation
import BlocksModels

protocol SimpleTableSelectionHandler: AnyObject {
    func didStartSimpleTableSelectionMode(simpleTableBlockId: BlockId, selectedBlockIds: [BlockId])
    func didStopSimpleTableSelectionMode()
}

enum SimpleTableSelectionType {
    case cells(indexPaths: [IndexPath])
    case rows(rowIndexes: [Int])
    case columns(columnIndexes: [Int])
}

protocol SimpleTableMenuDelegate: AnyObject {
    func didSelectTab(tab: SimpleTableMenuView.Tab)
}

final class SimpleTableStateManager: EditorPageBlocksStateManagerProtocol, SimpleTableMenuDelegate {
    var tableBlockInformation: BlockInformation?

    var editorEditingStatePublisher: AnyPublisher<EditorEditingState, Never> { $editingState.eraseToAnyPublisher() }
    var editorSelectedBlocks: AnyPublisher<[BlockId], Never> { $selectedBlocks.eraseToAnyPublisher() }
    var selectedBlocksIndexPaths = [IndexPath]()

    @Published var editingState: EditorEditingState = .editing
    @Published private var selectedBlocks = [BlockId]()

    weak var menuViewModel: SimpleTableMenuViewModel?
    weak var mainEditorSelectionManager: SimpleTableSelectionHandler?

    func checkDocumentLockField() {

    }

    func canSelectBlock(at indexPath: IndexPath) -> Bool {
        return true
    }

    func didLongTap(at indexPath: IndexPath) {

    }

    func didUpdateSelectedIndexPaths(_ indexPaths: [IndexPath]) {

    }

    func canPlaceDividerAtIndexPath(_ indexPath: IndexPath) -> Bool {
        return false
    }

    func canMoveItemsToObject(at indexPath: IndexPath) -> Bool {
        return false
    }

    func moveItem(with blockDragConfiguration: BlockDragConfiguration) {

    }

    func didSelectMovingIndexPaths(_ indexPaths: [IndexPath]) {

    }

    func didSelectEditingMode() {

    }


    // MARK: - SimpleTableMenuDelegate

    func didSelectTab(tab: SimpleTableMenuView.Tab) {
        switch tab {
        case .cell:
            menuViewModel?.items = SimpleTableCellMenuItem.allCases.map {
                HorizontalListItem.init(
                    id: "\($0.hashValue)",
                    title: $0.title,
                    image: .icon(.emoji(.lamp)),
                    action: { }
                )
            }
        case .row:
            menuViewModel?.items = SimpleTableRowMenuItem.allCases.map {
                HorizontalListItem.init(
                    id: "\($0.hashValue)",
                    title: $0.title,
                    image: .icon(.emoji(.lamp)),
                    action: { }
                )
            }
        case .column:
            menuViewModel?.items = SimpleTableColumnMenuItem.allCases.map {
                HorizontalListItem.init(
                    id: "\($0.hashValue)",
                    title: $0.title,
                    image: .icon(.emoji(.lamp)),
                    action: { }
                )
            }
        }
    }
}

extension SimpleTableStateManager: BlockSelectionHandler {
    func didSelectEditingState(info: BlockInformation) {
        editingState = .selecting(blocks: [info.id])
        selectedBlocks = [info.id]

        tableBlockInformation.map {
            mainEditorSelectionManager?.didStartSimpleTableSelectionMode(
                simpleTableBlockId: $0.id,
                selectedBlockIds: [info.id]
            )
        }
    }
}
