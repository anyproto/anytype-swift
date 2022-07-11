import Combine
import Foundation
import BlocksModels

protocol SimpleTableSelectionHandler: AnyObject {
    func didStartSimpleTableSelectionMode(simpleTableBlockId: BlockId, selectedBlockIds: [BlockId])
    func didStopSimpleTableSelectionMode()
}

protocol SimpleTableMenuDelegate: AnyObject {
    func didSelectTab(tab: SimpleTableMenuView.Tab)
}

protocol SimpleTableStateManagerProtocol: EditorPageBlocksStateManagerProtocol {
    var selectedMenuTabPublisher: AnyPublisher<SimpleTableMenuView.Tab, Never> { get }
    var selectedMenuTab: SimpleTableMenuView.Tab { get }
}

final class SimpleTableStateManager: SimpleTableStateManagerProtocol, SimpleTableMenuDelegate {
    var editorEditingStatePublisher: AnyPublisher<EditorEditingState, Never> { $editingState.eraseToAnyPublisher() }
    var selectedMenuTabPublisher: AnyPublisher<SimpleTableMenuView.Tab, Never> { $selectedMenuTab.eraseToAnyPublisher() }
    var editorSelectedBlocks: AnyPublisher<[BlockId], Never> { $selectedBlocks.eraseToAnyPublisher() }

    var tableBlockInformation: BlockInformation?
    var selectedBlocksIndexPaths = [IndexPath]()

    @Published var editingState: EditorEditingState = .editing
    @Published var selectedMenuTab: SimpleTableMenuView.Tab = .cell
    @Published private var selectedBlocks = [BlockId]()

    private let document: BaseDocumentProtocol
    private let tableService: BlockTableServiceProtocol

    weak var menuViewModel: SimpleTableMenuViewModel?
    weak var mainEditorSelectionManager: SimpleTableSelectionHandler?
    weak var dataSource: SpreadsheetViewDataSource?

    init(
        document: BaseDocumentProtocol,
        tableService: BlockTableServiceProtocol
    ) {
        self.document = document
        self.tableService = tableService
    }

    func checkDocumentLockField() {

    }

    func canSelectBlock(at indexPath: IndexPath) -> Bool {
        return true
    }

    func didLongTap(at indexPath: IndexPath) {

    }

    func didUpdateSelectedIndexPaths(_ indexPaths: [IndexPath]) {
        guard case .selecting = editingState else { return }
        guard let dataSource = dataSource else {
            return
        }

        let items = indexPaths.compactMap(dataSource.item(for:))
        let blockIds = items.compactMap { $0.blockId }

        guard let tableBlockInformation = tableBlockInformation else {
            return
        }

        mainEditorSelectionManager?.didStartSimpleTableSelectionMode(
            simpleTableBlockId: tableBlockInformation.id,
            selectedBlockIds: blockIds
        )
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
        editingState = .editing
    }


    // MARK: - SimpleTableMenuDelegate

    func didSelectTab(tab: SimpleTableMenuView.Tab) {
        self.selectedMenuTab = tab

        updateMenuItems()
    }

    private func updateMenuItems() {
        switch selectedMenuTab {
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
            menuViewModel?.items = SimpleTableRowMenuItem.allCases.map { item in
                HorizontalListItem.init(
                    id: "\(item.hashValue)",
                    title: item.title,
                    image: .icon(.emoji(.lamp)),
                    action: { [weak self] in self?.handleRowAction(action: item) }
                )
            }
        case .column:
            menuViewModel?.items = SimpleTableColumnMenuItem.allCases.map { item in
                HorizontalListItem.init(
                    id: "\(item.hashValue)",
                    title: item.title,
                    image: .icon(.emoji(.lamp)),
                    action: { [weak self] in self?.handleColumnAction(action: item) }
                )
            }
        }
    }

    private func handleColumnAction(action: SimpleTableColumnMenuItem) {
        switch action {
        case .insertLeft:
            selectedBlocksIndexPaths
        case .insertRight:
            break
        case .moveLeft:
            break
        case .moveRight:
            break
        case .duplicate:
            break
        case .delete:
            break
        case .clearContents:
            break
        case .sort:
            break
        case .color:
            break
        case .style:
            break
        }
    }

    private func handleRowAction(action: SimpleTableRowMenuItem) {

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

private extension EditorItem {
     var blockId: BlockId? {
        switch self {
        case .header(let objectHeader):
            return nil
        case .block(let blockViewModel):
            return blockViewModel.blockId
        case .system(let systemContentConfiguationProvider):
            return nil
        }
    }
}
