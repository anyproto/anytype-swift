import UIKit
import Services
import Foundation
import Services

enum SimpleTableOptionType {
    case cell(SimpleTableCellMenuItem)
    case row(SimpleTableRowMenuItem)
    case column(SimpleTableColumnMenuItem)
}

final class SimpleTableSelectionOptionHandler {
    var onFinishSelection: (() -> Void)?

    var selectedBlocksIndexPaths = [IndexPath]()

    private let router: EditorRouterProtocol
    private let tableService: BlockTableServiceProtocol
    private let document: BaseDocumentProtocol
    private let blockInformationProvider: BlockModelInfomationProvider
    private let actionHandler: BlockActionHandlerProtocol

    private var currentSortType: BlocksSortType = .asc

    init(
        router: EditorRouterProtocol,
        tableService: BlockTableServiceProtocol,
        document: BaseDocumentProtocol,
        blockInformationProvider: BlockModelInfomationProvider,
        actionHandler: BlockActionHandlerProtocol
    ) {
        self.router = router
        self.tableService = tableService
        self.document = document
        self.blockInformationProvider = blockInformationProvider
        self.actionHandler = actionHandler
    }

    // MARK: - Public

    func handle(action: SimpleTableOptionType) {
        Task { @MainActor in
            switch action {
            case .cell(let cellAction):
                await handleCellAction(action: cellAction)
            case .row(let rowAction):
                await handleRowAction(action: rowAction)
            case .column(let columnnAction):
                await handleColumnAction(action: columnnAction)
            }
        }
    }

    // MARK: - Private

    @MainActor
    private func handleColumnAction(action: SimpleTableColumnMenuItem) async {
        guard let table = ComputedTable(
            blockInformation: blockInformationProvider.info,
            infoContainer: document.infoContainer
        ) else { return }

        let selectedColumns = selectedBlocksIndexPaths
            .map { table.cells[$0.section][$0.row].columnId }
        let uniqueColumns = Set(selectedColumns)

        let selectedBlockIds = selectedBlocksIndexPaths
            .compactMap { table.cells[$0.section][$0.row].blockId }

        await fillSelectedRows()

        switch action {
        case .insertLeft:
            await uniqueColumns.asyncForEach {
                try? await tableService.insertColumn(contextId: document.objectId, targetId: $0, position: .left)
            }
        case .insertRight:
            await uniqueColumns.asyncForEach {
                try? await tableService.insertColumn(contextId: document.objectId, targetId: $0, position: .right)
            }
        case .moveLeft:
            let allColumnIds = table.allColumnIds
            let dropColumnIds = uniqueColumns.compactMap { item -> BlockId? in
                guard let index = allColumnIds.firstIndex(of: item) else { return nil }
                let indexBefore = allColumnIds.index(before: index)

                return allColumnIds[safe: indexBefore]
            }

            await zip(uniqueColumns, dropColumnIds).asyncForEach { targetId, dropColumnId in
                try? await tableService.columnMove(contextId: document.objectId, targetId: targetId, dropTargetID: dropColumnId, position: .left)
            }
        case .moveRight:
            let allColumnIds = table.allColumnIds
            let dropColumnIds = uniqueColumns.compactMap { item -> BlockId? in
                guard let index = allColumnIds.firstIndex(of: item) else { return nil }
                let indexBefore = allColumnIds.index(after: index)

                return allColumnIds[safe: indexBefore]
            }

            await zip(uniqueColumns, dropColumnIds).asyncForEach { targetId, dropColumnId in
                try? await tableService.columnMove(contextId: document.objectId, targetId: targetId, dropTargetID: dropColumnId, position: .right)
            }
        case .duplicate:
            await uniqueColumns.asyncForEach {
                try? await tableService.columnDuplicate(contextId: document.objectId, targetId: $0)
            }

        case .delete:
            await uniqueColumns.asyncForEach {
                try? await tableService.deleteColumn(contextId: document.objectId, targetId: $0)
            }
        case .clearContents:
            try? await tableService.clearContents(contextId: document.objectId, blockIds: selectedBlockIds)
        case .sort:
            await uniqueColumns.asyncForEach {
                try? await tableService.columnSort(contextId: document.objectId, columnId: $0, blocksSortType: currentSortType)
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

    @MainActor
    private func handleRowAction(action: SimpleTableRowMenuItem) async {
        guard let table = ComputedTable(
            blockInformation: blockInformationProvider.info,
            infoContainer: document.infoContainer
        ) else { return }

        let selectedRowIds = selectedBlocksIndexPaths
            .map { table.cells[$0.section][$0.row].rowId }
        let uniqueRows = Set(selectedRowIds)

        let selectedBlockIds = selectedBlocksIndexPaths
            .compactMap { table.cells[$0.section][$0.row].blockId }

        await fillSelectedRows()

        switch action {
        case .insertAbove:
            await uniqueRows.asyncForEach {
                try? await tableService.insertRow(contextId: document.objectId, targetId: $0, position: .top)
            }
        case .insertBelow:
            await uniqueRows.asyncForEach {
                try? await tableService.insertRow(contextId: document.objectId, targetId: $0, position: .bottom)
            }
        case .moveUp:
            let allRowIds = table.allRowIds
            let dropRowIds = uniqueRows.compactMap { item -> BlockId? in
                guard let index = allRowIds.firstIndex(of: item) else { return nil }
                let indexBefore = allRowIds.index(before: index)

                return allRowIds[safe: indexBefore]
            }

            await zip(uniqueRows, dropRowIds).asyncForEach { targetId, dropColumnId in
                try? await tableService.rowMove(
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

            await zip(uniqueRows, dropRowIds).asyncForEach { targetId, dropColumnId in
                try? await tableService.rowMove(
                    contextId: document.objectId,
                    targetId: targetId,
                    dropTargetID: dropColumnId,
                    position: .bottom
                )
            }
        case .duplicate:
            await uniqueRows.asyncForEach {
                try? await tableService.rowDuplicate(contextId: document.objectId, targetId: $0)
            }
        case .delete:
            await uniqueRows.asyncForEach {
                try? await tableService.deleteRow(contextId: document.objectId, targetId: $0)
            }
        case .clearContents:
            try? await tableService.clearContents(contextId: document.objectId, blockIds: selectedBlockIds)
        case .color:
            onColorSelection(for: selectedBlockIds)
            return
        case .style:
            onStyleSelection(for: selectedBlockIds)
            return
        }

        onFinishSelection?()
    }

    @MainActor
    private func handleCellAction(action: SimpleTableCellMenuItem) async {
        guard let table = ComputedTable(
            blockInformation: blockInformationProvider.info,
            infoContainer: document.infoContainer
        ) else { return }


        let selectedBlockIds = selectedBlocksIndexPaths
            .compactMap { table.cells[$0.section][$0.row].blockId }

        await fillSelectedRows()

        switch action {
        case .clearContents:
            try? await tableService.clearContents(contextId: document.objectId, blockIds: selectedBlockIds)
        case .color:
            onColorSelection(for: selectedBlockIds)
            return
        case .style:
            onStyleSelection(for: selectedBlockIds)
            return
        case .clearStyle:
            try? await tableService.clearStyle(contextId: document.objectId, blocksIds: selectedBlockIds)
        }

        onFinishSelection?()
    }

    @MainActor
    private func fillSelectedRows() async {
        guard let table = ComputedTable(
            blockInformation: blockInformationProvider.info,
            infoContainer: document.infoContainer
        ) else { return }

        let selectedRows = Set(
            selectedBlocksIndexPaths
                .compactMap { table.cells[$0.section][$0.row].rowId }
        )

        guard selectedRows.count > 0 else { return }

        try? await tableService.rowListFill(contextId: document.objectId, targetIds: Array(selectedRows))
    }
}
