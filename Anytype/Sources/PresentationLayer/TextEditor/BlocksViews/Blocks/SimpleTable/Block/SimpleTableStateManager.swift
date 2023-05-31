import Combine
import Foundation
import Services
import UIKit
import AnytypeCore

protocol SimpleTableSelectionHandler: AnyObject {
    func didStartSimpleTableSelectionMode(
        simpleTableBlockId: BlockId,
        selectedBlockIds: [BlockId],
        menuModel: SimpleTableMenuModel
    )
    func didStopSimpleTableSelectionMode()
}

protocol SimpleTableMenuDelegate: AnyObject {
    func didSelectTab(tab: SimpleTableMenuView.Tab)
}

protocol SimpleTableStateManagerProtocol: EditorPageBlocksStateManagerProtocol {
    var selectedMenuTabPublisher: AnyPublisher<SimpleTableMenuView.Tab, Never> { get }
    var selectedMenuTab: SimpleTableMenuView.Tab { get }

    var selectedBlocksIndexPathsPublisher: AnyPublisher<[IndexPath], Never> { get }
}

final class SimpleTableStateManager: SimpleTableStateManagerProtocol {


    var editorEditingStatePublisher: AnyPublisher<EditorEditingState, Never> { $editingState.eraseToAnyPublisher() }
    var selectedMenuTabPublisher: AnyPublisher<SimpleTableMenuView.Tab, Never> { $selectedMenuTab.eraseToAnyPublisher() }
    var editorSelectedBlocks: AnyPublisher<[BlockId], Never> { fatalError("To remove!!!") } // Not used

    var selectedBlocksIndexPathsPublisher: AnyPublisher<[IndexPath], Never> { selectedIndexPathsSubject.eraseToAnyPublisher() }

    @Published var editingState: EditorEditingState = .editing
    @Published var selectedMenuTab: SimpleTableMenuView.Tab = .cell

    private let selectedIndexPathsSubject = PassthroughSubject<[IndexPath], Never>()
    private let tableBlockInformation: BlockInformation
    private let document: BaseDocumentProtocol
    private let selectionOptionHandler: SimpleTableSelectionOptionHandler
    private let router: EditorRouterProtocol
    private let cursorManager: EditorCursorManager
    private var selectedBlocksIndexPaths = [IndexPath]() {
        didSet {
            selectionOptionHandler.selectedBlocksIndexPaths = selectedBlocksIndexPaths

            if selectedMenuTab == .cell {
                selectedCellsIndexPaths = selectedBlocksIndexPaths
            }
        }
    }

    private var selectedCellsIndexPaths = [IndexPath]()

    private weak var mainEditorSelectionManager: SimpleTableSelectionHandler?
    weak var viewInput: EditorPageViewInput?

    init(
        document: BaseDocumentProtocol,
        tableBlockInformation: BlockInformation,
        selectionOptionHandler: SimpleTableSelectionOptionHandler,
        router: EditorRouterProtocol,
        cursorManager: EditorCursorManager,
        mainEditorSelectionManager: SimpleTableSelectionHandler?
    ) {
        self.document = document
        self.tableBlockInformation = tableBlockInformation
        self.selectionOptionHandler = selectionOptionHandler
        self.router = router
        self.cursorManager = cursorManager
        self.mainEditorSelectionManager = mainEditorSelectionManager

        selectionOptionHandler.onFinishSelection = { [weak self] in self?.resetToEditingMode() }
    }

    func checkOpenedState() {}

    func checkDocumentLockField() {
        switch editingState {
        case .editing, .locked, .loading:
            break
        default:
            return // Unable to change state while moving or selecting blocks
        }

        if document.isLocked {
            editingState = .locked
        } else if case .locked = editingState, !document.isLocked {
            editingState = .editing
        }
    }

    func canSelectBlock(at indexPath: IndexPath) -> Bool {
        return true
    }

    func didLongTap(at indexPath: IndexPath) {

    }

    func didUpdateSelectedIndexPaths(_ indexPaths: [IndexPath]) {
        guard case .selecting = editingState else { return }

        UISelectionFeedbackGenerator().selectionChanged()

        guard indexPaths.count > 0 else {
            resetToEditingMode()
            return
        }
        selectedBlocksIndexPaths = indexPaths

        updateMenuItems(for: selectedBlocksIndexPaths)
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

        selectedBlocksIndexPaths.removeAll()
        selectedMenuTab = .cell
    }


    // MARK: - Private

    private func resetToEditingMode() {
        editingState = .editing
        mainEditorSelectionManager?.didStopSimpleTableSelectionMode()
        selectedMenuTab = .cell
    }

    private func updateMenuItems(for selectedBlocks: [IndexPath]) {
        guard let computedTable = ComputedTable(blockInformation: tableBlockInformation, infoContainer: document.infoContainer) else {
            return
        }
        let horizontalListItems: [SelectionOptionsItemViewModel]

        switch selectedMenuTab {
        case .cell:
            horizontalListItems = SimpleTableCellMenuItem.allCases.map { item in
                SelectionOptionsItemViewModel(
                    id: "\(UUID().uuidString) \(item.hashValue)", // sometimes SwiftUI view do not update items with equal hashes and action doesn't work. This class could be deinited whilte reusing cell.s
                    title: item.title,
                    imageAsset: item.imageAsset,
                    action: { [weak selectionOptionHandler] in selectionOptionHandler?.handle(action: .cell(item)) }
                )
            }
        case .row:
            horizontalListItems = SimpleTableRowMenuItem.allCases.map { item in
                SelectionOptionsItemViewModel(
                    id: "\(UUID().uuidString) \(item.hashValue)",
                    title: item.title,
                    imageAsset: item.imageAsset,
                    action: { [weak selectionOptionHandler] in selectionOptionHandler?.handle(action: .row(item)) }
                )
            }
        case .column:
            horizontalListItems = SimpleTableColumnMenuItem.allCases.map { item in
                SelectionOptionsItemViewModel(
                    id: "\(UUID().uuidString) \(item.hashValue)",
                    title: item.title,
                    imageAsset: item.imageAsset,
                    action: { [weak selectionOptionHandler] in selectionOptionHandler?.handle(action: .column(item)) }
                )
            }
        }

        let blockIds = computedTable.cells.blockIds(for: selectedBlocks)

        mainEditorSelectionManager?.didStartSimpleTableSelectionMode(
            simpleTableBlockId: tableBlockInformation.id,
            selectedBlockIds: blockIds,
            menuModel: .init(
                tabs: tabs(),
                items: horizontalListItems,
                onDone: { [weak self] in self?.didSelectEditingMode() }
            )
        )
    }

    private func tabs() -> [SimpleTableMenuModel.TabModel] {
        SimpleTableMenuView.Tab.allCases.map { item in
            SimpleTableMenuModel.TabModel(
                id: item.rawValue,
                title: item.title,
                isSelected: selectedMenuTab == item,
                action: { [weak self] in self?.didSelectTab(tab: item) }
            )
        }
    }
}

// MARK: - SimpleTableMenuDelegate
extension SimpleTableStateManager: SimpleTableMenuDelegate {
    func didSelectTab(tab: SimpleTableMenuView.Tab) {
        guard let table = ComputedTable(blockInformation: tableBlockInformation, infoContainer: document.infoContainer) else {
            return
        }

        let selectedIndexPaths: [IndexPath]

        switch tab {
        case .cell:
            selectedIndexPaths = selectedCellsIndexPaths
        case .column:
            let rowIndexPaths = selectedCellsIndexPaths.flatMap {
                SpreadsheetSelectionHelper.allIndexPaths(
                    for: $0.row,
                    sectionsCount: table.cells.count
                )
            }
            selectedIndexPaths = rowIndexPaths
        case .row:
            let rowIndexPaths = selectedCellsIndexPaths.flatMap {
                SpreadsheetSelectionHelper.allIndexPaths(
                    for: $0.section,
                    rowsCount: table.cells.first?.count ?? 0
                )
            }
            selectedIndexPaths = rowIndexPaths
        }

        self.selectedMenuTab = tab

        self.selectedIndexPathsSubject.send(selectedIndexPaths)
        self.selectedBlocksIndexPaths = selectedIndexPaths

        updateMenuItems(for: selectedBlocksIndexPaths)
    }
}

// MARK: - BlocksSelectionHandler
extension SimpleTableStateManager: BlockSelectionHandler {
    func didSelectEditingState(info: BlockInformation) {
        guard let computedTable = ComputedTable(blockInformation: tableBlockInformation, infoContainer: document.infoContainer),
              let selectedIndexPath = computedTable.cells.indexPaths(for: info) else {
            return
        }

        editingState = .selecting(blocks: [info.id])
        selectedIndexPathsSubject.send([selectedIndexPath])
        selectedBlocksIndexPaths = [selectedIndexPath]

        updateMenuItems(for: [selectedIndexPath])
    }

    func didSelectStyleSelection(infos: [BlockInformation]) {
        guard
            let firstInfo = infos.first,
            let computedTable = ComputedTable(blockInformation: tableBlockInformation, infoContainer: document.infoContainer),
              let selectedIndexPath = computedTable.cells.indexPaths(for: firstInfo) else {
            return
        }

        editingState = .selecting(blocks: [firstInfo.id])

        router.showStyleMenu(
            informations: [firstInfo],
            restrictions: SimpleTableTextCellRestrictions(),
            didShow: { presentedView in
                //
            },
            onDismiss: { [weak self] in
                self?.editingState = .editing
                self?.cursorManager.restoreLastFocus(at: firstInfo.id)
            }
        )

        selectedIndexPathsSubject.send([selectedIndexPath])
    }
}

// MARK: - Private helpers

extension Array where Element == [ComputedTable.Cell] {
    func indexPaths(for blockInformation: BlockInformation) -> IndexPath? {
        for (sectionIndex, sections) in self.enumerated() {
            for (rowIndex, item) in sections.enumerated() {
                if item.blockInformation?.id == blockInformation.id {
                    return IndexPath(item: rowIndex, section: sectionIndex)
                }
            }
        }

        return nil
    }

    func blockIds(for indexPaths: [IndexPath]) -> [BlockId] {
        var blockIds = [BlockId]()

        for (sectionIndex, sections) in self.enumerated() {
            for (rowIndex, item) in sections.enumerated() {
                if indexPaths.contains(where: { $0.section == sectionIndex && $0.row == rowIndex }) {
                    if let blockInformation = item.blockInformation {
                        blockIds.append(blockInformation.id)
                    } else {
                        blockIds.append("\(item.rowId)-\(item.columnId)")
                    }
                }
            }
        }

        return blockIds
    }
}

private extension EditorItem {
     var blockId: BlockId? {
        switch self {
        case .header:
            return nil
        case .block(let blockViewModel):
            return blockViewModel.blockId
        case .system:
            return nil
        }
    }
}
