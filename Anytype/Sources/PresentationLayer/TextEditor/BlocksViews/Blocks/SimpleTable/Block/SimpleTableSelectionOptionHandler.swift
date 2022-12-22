import UIKit
import BlocksModels
import Foundation

enum SimpleTableOptionType {
    case cell(SimpleTableCellMenuItem)
    case row(SimpleTableRowMenuItem)
    case column(SimpleTableColumnMenuItem)
}

final class SimpleTableSelectionOptionHandler {
    var onFinishSelection: (() -> Void)?

    var selectedBlocksIndexPaths = [IndexPath]()

    private let router: EditorRouterProtocol
    private let listService: BlockListServiceProtocol
    private let tableService: BlockTableServiceProtocol
    private let document: BaseDocumentProtocol
    private let tableBlockInformation: BlockInformation
    private let actionHandler: BlockActionHandlerProtocol

    private var currentSortType: BlocksSortType = .asc

    init(
        router: EditorRouterProtocol,
        listService: BlockListServiceProtocol,
        tableService: BlockTableServiceProtocol,
        document: BaseDocumentProtocol,
        tableBlockInformation: BlockInformation,
        actionHandler: BlockActionHandlerProtocol
    ) {
        self.router = router
        self.listService = listService
        self.tableService = tableService
        self.document = document
        self.tableBlockInformation = tableBlockInformation
        self.actionHandler = actionHandler
    }

    // MARK: - Public

    func handle(action: SimpleTableOptionType) {
        switch action {
        case .cell(let cellAction):
            handleCellAction(action: cellAction)
        case .row(let rowAction):
            handleRowAction(action: rowAction)
        case .column(let columnnAction):
            handleColumnAction(action: columnnAction)
        }
    }

    // MARK: - Private

    private func handleColumnAction(action: SimpleTableColumnMenuItem) {
        guard let table = ComputedTable(
            blockInformation: tableBlockInformation,
            infoContainer: document.infoContainer
        ) else { return }

        let selectedColumns = selectedBlocksIndexPaths
            .map { table.cells[$0.section][$0.row].columnId }
        let uniqueColumns = Set(selectedColumns)

        let selectedBlockIds = selectedBlocksIndexPaths
            .compactMap { table.cells[$0.section][$0.row].blockId }

        fillSelectedRows()

        switch action {
        case .insertLeft:
            uniqueColumns.forEach {
                tableService.insertColumn(contextId: document.objectId, targetId: $0, position: .left)
            }
        case .insertRight:
            uniqueColumns.forEach {
                tableService.insertColumn(contextId: document.objectId, targetId: $0, position: .right)
            }
        case .moveLeft:
            let allColumnIds = table.allColumnIds
            let dropColumnIds = uniqueColumns.compactMap { item -> BlockId? in
                guard let index = allColumnIds.firstIndex(of: item) else { return nil }
                let indexBefore = allColumnIds.index(before: index)

                return allColumnIds[safe: indexBefore]
            }

            zip(uniqueColumns, dropColumnIds).forEach { targetId, dropColumnId in
                tableService.columnMove(contextId: document.objectId, targetId: targetId, dropTargetID: dropColumnId, position: .left)

            }
        case .moveRight:
            let allColumnIds = table.allColumnIds
            let dropColumnIds = uniqueColumns.compactMap { item -> BlockId? in
                guard let index = allColumnIds.firstIndex(of: item) else { return nil }
                let indexBefore = allColumnIds.index(after: index)

                return allColumnIds[safe: indexBefore]
            }

            zip(uniqueColumns, dropColumnIds).forEach { targetId, dropColumnId in
                tableService.columnMove(contextId: document.objectId, targetId: targetId, dropTargetID: dropColumnId, position: .right)

            }
        case .duplicate:
            uniqueColumns.forEach {
                tableService.columnDuplicate(contextId: document.objectId, targetId: $0)
            }

        case .delete:
            uniqueColumns.forEach {
                tableService.deleteColumn(contextId: document.objectId, targetId: $0)
            }
        case .clearContents:
            tableService.clearContents(contextId: document.objectId, blockIds: selectedBlockIds)
        case .sort:
            uniqueColumns.forEach {
                tableService.columnSort(contextId: document.objectId, columnId: $0, blocksSortType: currentSortType)
            }

            currentSortType = currentSortType == .asc ? .desc : .asc

            return
        case .color:
            onColorSelection(for: selectedBlockIds)
            return
        case .style:
            onStyleSelection(for: selectedBlockIds)
            return
        }

        onFinishSelection?()
    }

    private func onColorSelection(for selectedBlockIds: [BlockId]) {
        let blockInformations = selectedBlockIds.compactMap(document.infoContainer.get(id:))

        let backgroundColors = blockInformations.map(\.backgroundColor)
        let textColors = blockInformations.compactMap { blockInformation -> MiddlewareColor in
            if case let .text(blockText) = blockInformation.content {
                return blockText.color ?? .default
            }

            return MiddlewareColor.default
        }

        let uniqueBackgroundColors = Set(backgroundColors)
        let uniqueTextColors = Set(textColors)

        let backgroundColor = uniqueBackgroundColors.count > 1 ? nil : (uniqueBackgroundColors.first ?? .default)
        let textColor = uniqueTextColors.count > 1 ? nil : (uniqueTextColors.first ?? .default)

        router.showColorPicker(
            onColorSelection: { [weak actionHandler] colorItem in
                switch colorItem {
                case .text(let blockColor):
                    actionHandler?.setTextColor(blockColor, blockIds: selectedBlockIds)
                case .background(let blockBackgroundColor):
                    actionHandler?.setBackgroundColor(blockBackgroundColor, blockIds: selectedBlockIds)
                }
            },
            selectedColor: textColor.map(UIColor.Dark.uiColor(from:)) ?? nil,
            selectedBackgroundColor: backgroundColor.map(UIColor.VeryLight.uiColor(from:)) ?? nil
        )
    }

    private func onStyleSelection(for selectedBlockIds: [BlockId]) {
        router.showMarkupBottomSheet(
            selectedBlockIds: selectedBlockIds,
            viewDidClose: {
                //
            }
        )
    }

    private func handleRowAction(action: SimpleTableRowMenuItem) {
        guard let table = ComputedTable(
            blockInformation: tableBlockInformation,
            infoContainer: document.infoContainer
        ) else { return }

        let selectedRowIds = selectedBlocksIndexPaths
            .map { table.cells[$0.section][$0.row].rowId }
        let uniqueRows = Set(selectedRowIds)

        let selectedBlockIds = selectedBlocksIndexPaths
            .compactMap { table.cells[$0.section][$0.row].blockId }

        fillSelectedRows()

        switch action {
        case .insertAbove:
            uniqueRows.forEach {
                tableService.insertRow(contextId: document.objectId, targetId: $0, position: .top)
            }
        case .insertBelow:
            uniqueRows.forEach {
                tableService.insertRow(contextId: document.objectId, targetId: $0, position: .bottom)
            }
        case .moveUp:
            let allRowIds = table.allRowIds
            let dropRowIds = uniqueRows.compactMap { item -> BlockId? in
                guard let index = allRowIds.firstIndex(of: item) else { return nil }
                let indexBefore = allRowIds.index(before: index)

                return allRowIds[safe: indexBefore]
            }

            zip(uniqueRows, dropRowIds).forEach { targetId, dropColumnId in
                tableService.rowMove(
                    contextId: document.objectId,
                    targetId: targetId,
                    dropTargetID: dropColumnId,
                    position: .top
                )
            }
        case .moveDown:
            let allRowIds = table.allRowIds
            let dropRowIds = uniqueRows.compactMap { item -> BlockId? in
                guard let index = allRowIds.firstIndex(of: item) else { return nil }
                let indexAfter = allRowIds.index(after: index)

                return allRowIds[safe: indexAfter]
            }

            zip(uniqueRows, dropRowIds).forEach { targetId, dropColumnId in
                tableService.rowMove(
                    contextId: document.objectId,
                    targetId: targetId,
                    dropTargetID: dropColumnId,
                    position: .bottom
                )
            }
        case .duplicate:
            uniqueRows.forEach {
                tableService.rowDuplicate(contextId: document.objectId, targetId: $0)
            }
        case .delete:
            uniqueRows.forEach {
                tableService.deleteRow(contextId: document.objectId, targetId: $0)
            }
        case .clearContents:
            tableService.clearContents(contextId: document.objectId, blockIds: selectedBlockIds)
        case .color:
            onColorSelection(for: selectedBlockIds)
            return
        case .style:
            onStyleSelection(for: selectedBlockIds)
            return
        }

        onFinishSelection?()
    }

    private func handleCellAction(action: SimpleTableCellMenuItem) {
        guard let table = ComputedTable(
            blockInformation: tableBlockInformation,
            infoContainer: document.infoContainer
        ) else { return }


        let selectedBlockIds = selectedBlocksIndexPaths
            .compactMap { table.cells[$0.section][$0.row].blockId }

        fillSelectedRows()

        switch action {
        case .clearContents:
            tableService.clearContents(contextId: document.objectId, blockIds: selectedBlockIds)
        case .color:
            onColorSelection(for: selectedBlockIds)
            return
        case .style:
            onStyleSelection(for: selectedBlockIds)
            return
        case .clearStyle:
            tableService.clearStyle(contextId: document.objectId, blocksIds: selectedBlockIds)
        }

        onFinishSelection?()
    }

    private func fillSelectedRows() {
        guard let table = ComputedTable(
            blockInformation: tableBlockInformation,
            infoContainer: document.infoContainer
        ) else { return }

        let selectedRows = Set(
            selectedBlocksIndexPaths
                .compactMap { table.cells[$0.section][$0.row].rowId }
        )

        guard selectedRows.count > 0 else { return }

        tableService.rowListFill(contextId: document.objectId, targetIds: Array(selectedRows))
    }
}
