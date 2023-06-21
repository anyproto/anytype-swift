import UIKit
import Services
import AnytypeCore

final class SimpleTableCellsBuilder {
    private let document: BaseDocumentProtocol
    private let router: EditorRouterProtocol
    private let handler: BlockActionHandlerProtocol
    private let pasteboardService: PasteboardServiceProtocol
    private let markdownListener: MarkdownListener
    private let cursorManager: EditorCursorManager
    private let focusSubjectHolder: FocusSubjectsHolder
    private let infoContainer: InfoContainerProtocol
    private let blockTableService: BlockTableServiceProtocol
    private let responderScrollViewHelper: ResponderScrollViewHelper
    private let delegate: BlockDelegate?

    init(
        document: BaseDocumentProtocol,
        router: EditorRouterProtocol,
        handler: BlockActionHandlerProtocol,
        pasteboardService: PasteboardServiceProtocol,
        delegate: BlockDelegate?,
        markdownListener: MarkdownListener,
        cursorManager: EditorCursorManager,
        focusSubjectHolder: FocusSubjectsHolder,
        responderScrollViewHelper: ResponderScrollViewHelper,
        blockTableService: BlockTableServiceProtocol = BlockTableService()
    ) {
        self.document = document
        self.router = router
        self.handler = handler
        self.pasteboardService = pasteboardService
        self.delegate = delegate
        self.markdownListener = markdownListener
        self.cursorManager = cursorManager
        self.focusSubjectHolder = focusSubjectHolder
        self.infoContainer = document.infoContainer
        self.responderScrollViewHelper = responderScrollViewHelper
        self.blockTableService = blockTableService
    }

    func buildItems(
        from info: BlockInformation
    ) -> [[EditorItem]] {
        guard let computedTable = ComputedTable(blockInformation: info, infoContainer: infoContainer) else {
            return []
        }

        return buildModels(computedTable: computedTable)
    }

    private func buildModels(computedTable: ComputedTable) -> [[EditorItem]] {
        return computedTable.cells.map {
            $0.map { item in
                guard let blockInformation = item.blockInformation else {
                    return makeEmptyContentCellConfiguration(columnId: item.columnId, rowId: item.rowId, isHeaderRow: item.isHeaderRow)
                }
                switch item.blockInformation?.content {
                case let .text(content):
                    return textBlockConfiguration(information: blockInformation, content: content, table: computedTable, isHeaderRow: item.isHeaderRow)
                default:
                    anytypeAssertionFailure("Wrong path")
                    return makeEmptyContentCellConfiguration(columnId: item.columnId, rowId: item.rowId, isHeaderRow: item.isHeaderRow)
                }
            }
        }
    }

    private func makeEmptyContentCellConfiguration(
        columnId: BlockId,
        rowId: BlockId,
        isHeaderRow: Bool
    ) -> EditorItem {
        .system(
            EmptyRowViewViewModel(
                contextId: document.objectId,
                rowId: rowId,
                columnId: columnId,
                tablesService: blockTableService,
                cursorManager: cursorManager,
                isHeaderRow: isHeaderRow
            )
        )
    }

    private func textBlockConfiguration(
        information: BlockInformation,
        content: BlockText,
        table: ComputedTable,
        isHeaderRow: Bool
    ) -> EditorItem {
        let isCheckable = content.contentType == .title ? document.details?.layoutValue == .todo : false
        let anytypeText = content.anytypeText(document: document)
        
        let textBlockActionHandler = SimpleTablesTextBlockActionHandler(
            info: information,
            showPage: { [weak self] data in
                self?.router.showPage(data: data)
            },
            openURL: { [weak router] url in
                router?.openUrl(url)
            },
            showTextIconPicker: { [unowned router, unowned document] in
                router.showTextIconPicker(
                    contextId: document.objectId,
                    objectId: information.id
                )
            },
            showWaitingView: { [weak router] text in
                router?.showWaitingView(text: text)
            },
            hideWaitingView: {  [weak router] in
                router?.hideWaitingView()
            },
            content: content,
            anytypeText: anytypeText,
            actionHandler: handler,
            pasteboardService: pasteboardService,
            markdownListener: markdownListener,
            blockDelegate: delegate,
            onKeyboardAction: { [weak self] action in
                self?.handleKeyboardAction(table: table, block: information, action: action)
            },
            responderScrollViewHelper: responderScrollViewHelper
        )

        let viewModel = TextBlockViewModel(
            info: information,
            content: content,
            anytypeText: anytypeText,
            isCheckable: isCheckable,
            focusSubject: focusSubjectHolder.focusSubject(for: information.id),
            actionHandler: textBlockActionHandler,
            customBackgroundColor: isHeaderRow ? UIColor.headerRowColor : nil
        )

        return EditorItem.block(viewModel)
    }

    private func handleKeyboardAction(table: ComputedTable, block: BlockInformation, action: CustomTextView.KeyboardAction) {
        guard let newComputedTable = ComputedTable(blockInformation: table.info, infoContainer: infoContainer) else {
            return
        }

        switch action {
        case .delete:
            guard let indexPath = newComputedTable.cells.indexPaths(for: block),
                  let newFocusingCell = newComputedTable.cells[safe: (indexPath.section - 1)]?[safe: indexPath.row]
            else { return }

            focus(on: newFocusingCell, position: .end)
        case .enterAtTheBegining, .enterAtTheEnd, .enterForEmpty, .enterInside:
            guard let indexPath = newComputedTable.cells.indexPaths(for: block),
                  let newFocusingCell = newComputedTable.cells[safe: (indexPath.section + 1)]?[safe: indexPath.row]
            else { return }

            focus(on: newFocusingCell, position: .end)
        }
    }

    private func focus(on cell: ComputedTable.Cell, position: BlockFocusPosition) {
        if let blockInformation = cell.blockInformation {
            cursorManager.focus(at: blockInformation.id, position: position)
        } else {
            blockTableService.rowListFill(
                contextId: document.objectId,
                targetIds: [cell.rowId]
            )

            cursorManager.blockFocus = .init(id: "\(cell.rowId)-\(cell.columnId)", position: .beginning)
        }
    }
}

struct ComputedTable {
    struct Cell {
        var blockId: BlockId { "\(rowId)-\(columnId)" }
        let rowId: BlockId
        let columnId: BlockId
        let isHeaderRow: Bool
        let blockInformation: BlockInformation?
    }

    let info: BlockInformation
    let cells: [[Cell]]

    private init?(
        info: BlockInformation,
        infoContainer: InfoContainerProtocol,
        tableColumnsBlockInfo: BlockInformation,
        tableRowsBlockInfo: BlockInformation
    ) {
        let numberOfColumns = tableColumnsBlockInfo.childrenIds.count
        var blocks = [[Cell]]()

        for rowId in tableRowsBlockInfo.childrenIds {
            guard let childInformation = infoContainer.get(id: rowId) else {
                anytypeAssertionFailure("Missing column or rows information")
                return nil
            }

            if case let .tableRow(tableRow) = childInformation.content {
                var rowBlocks = [Cell]()

                for columnIndex in 0..<numberOfColumns {
                    let columnId = tableColumnsBlockInfo.childrenIds[columnIndex]

                    let child = infoContainer.get(id: "\(rowId)-\(columnId)")
                    let cell = Cell(rowId: rowId, columnId: columnId, isHeaderRow: tableRow.isHeader, blockInformation: child)
                    rowBlocks.append(cell)
                }

                blocks.append(rowBlocks)
            }
        }

        self.cells = blocks
        self.info = info
    }
}

extension ComputedTable {
    init?(blockInformation: BlockInformation, infoContainer: InfoContainerProtocol) {
        guard let newBlockInformation = infoContainer.get(id: blockInformation.id) else { return nil }
        var tableColumnsBlockInfo: BlockInformation?
        var tableRowsBlockInfo: BlockInformation?

        for childId in newBlockInformation.childrenIds {
            guard let childInformation = infoContainer.get(id: childId) else {
                anytypeAssertionFailure("Can't find child of table view")
                return nil
            }

            if childInformation.content == .layout(.init(style: .tableRows)) {
                tableRowsBlockInfo = childInformation
            } else if childInformation.content == .layout(.init(style: .tableColumns)) {
                tableColumnsBlockInfo = childInformation
            }
        }

        guard let tableColumnsBlockInfo = tableColumnsBlockInfo,
              let tableRowsBlockInfo = tableRowsBlockInfo else {
            anytypeAssertionFailure("Missing column or rows information")
            return nil
        }

        self.init(info: blockInformation, infoContainer: infoContainer, tableColumnsBlockInfo: tableColumnsBlockInfo, tableRowsBlockInfo: tableRowsBlockInfo)
    }
}

extension ComputedTable {
    var allColumnIds: [BlockId] {
        cells.first?.compactMap { $0.columnId } ?? []
    }

    var allRowIds: [BlockId] {
        cells.compactMap {
            $0.first.map { $0.rowId }
        }
    }
}

extension UIColor {
    static var headerRowColor: UIColor {
        UIColor(hexString: "#353a3a").withAlphaComponent(0.3)
    }
}
