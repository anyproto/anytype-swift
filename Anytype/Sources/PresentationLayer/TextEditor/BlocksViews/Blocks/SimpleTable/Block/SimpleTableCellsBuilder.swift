import UIKit
import BlocksModels
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
    private weak var delegate: BlockDelegate?

    init(
        document: BaseDocumentProtocol,
        router: EditorRouterProtocol,
        handler: BlockActionHandlerProtocol,
        pasteboardService: PasteboardServiceProtocol,
        delegate: BlockDelegate?,
        markdownListener: MarkdownListener,
        cursorManager: EditorCursorManager,
        focusSubjectHolder: FocusSubjectsHolder
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
    }

    func buildItems(
        from info: BlockInformation
    ) -> [[EditorItem]] {
        var tableColumnsBlockInfo: BlockInformation?
        var tableRowsBlockInfo: BlockInformation?

        for childId in info.childrenIds {
            guard let childInformation = infoContainer.get(id: childId) else {
                anytypeAssertionFailure("Can't find child of table view", domain: .simpleTables)
                return []
            }

            if childInformation.content == .layout(.init(style: .tableRows)) {
                tableRowsBlockInfo = childInformation
            } else if childInformation.content == .layout(.init(style: .tableColumns)) {
                tableColumnsBlockInfo = childInformation
            }
        }

        guard let tableColumnsBlockInfo = tableColumnsBlockInfo,
              let tableRowsBlockInfo = tableRowsBlockInfo else {
            anytypeAssertionFailure("Missing column or rows information", domain: .simpleTables)
            return []
        }

        return buildModels(
            tableColumnsBlockInfo: tableColumnsBlockInfo,
            tableRowsBlockInfo: tableRowsBlockInfo
        )
    }

    private func buildModels(
        tableColumnsBlockInfo: BlockInformation,
        tableRowsBlockInfo: BlockInformation
    ) -> [[EditorItem]] {
        let computedTable = ComputedTable(
            infoContainer: infoContainer,
            tableColumnsBlockInfo: tableColumnsBlockInfo,
            tableRowsBlockInfo: tableRowsBlockInfo
        )

        return computedTable.cells.map {
            $0.map { item in
                guard let blockInformation = item.blockInformation else {
                    return makeEmptyContentCellConfiguration(columnId: item.columnId, rowId: item.rowId)
                }
                switch item.blockInformation?.content {
                case let .text(content):
                    return textBlockConfiguration(information: blockInformation, content: content)
                default:
                    anytypeAssertionFailure("Wrong path", domain: .simpleTables)
                    return makeEmptyContentCellConfiguration(columnId: item.columnId, rowId: item.rowId)
                }
            }
        }
    }

    private func makeEmptyContentCellConfiguration(
        columnId: BlockId,
        rowId: BlockId
    ) -> EditorItem {
        .system(
            EmptyRowViewViewModel(
                contextId: document.objectId,
                rowId: rowId,
                columnId: columnId,
                tablesService: BlockTableService(),
                cursorManager: cursorManager
            )
        )
    }

    private func textBlockConfiguration(information: BlockInformation, content: BlockText) -> EditorItem {
        let isCheckable = content.contentType == .title ? document.details?.layout == .todo : false

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
            showURLBookmarkPopup: { [weak router] parameters in
                router?.showLinkContextualMenu(inputParameters: parameters)
            },
            actionHandler: handler,
            pasteboardService: pasteboardService,
            markdownListener: markdownListener,
            blockDelegate: delegate
        )

        let viewModel = TextBlockViewModel(
            info: information,
            content: content,
            isCheckable: isCheckable,
            focusSubject: focusSubjectHolder.focusSubject(for: information.id),
            actionHandler: textBlockActionHandler
        )

        return EditorItem.block(viewModel)
    }
}

struct ComputedTable {
    struct Cell {
        let rowId: BlockId
        let columnId: BlockId
        let blockInformation: BlockInformation?
    }

    let cells: [[Cell]]

    init(
        infoContainer: InfoContainerProtocol,
        tableColumnsBlockInfo: BlockInformation,
        tableRowsBlockInfo: BlockInformation
    ) {
        let numberOfColumns = tableColumnsBlockInfo.childrenIds.count
        var blocks = [[Cell]]()

        for rowId in tableRowsBlockInfo.childrenIds {
            guard let childInformation = infoContainer.get(id: rowId) else {
                anytypeAssertionFailure("Missing column or rows information", domain: .simpleTables)
                fatalError()
            }

            if childInformation.content == .tableRow {
                var rowBlocks = [Cell]()

                for column in 0..<numberOfColumns {
                    let columnId = tableColumnsBlockInfo.childrenIds[column]

                    let rowChildInformation = childInformation.childrenIds[safe: column]
                    let child = rowChildInformation.map { infoContainer.get(id: $0) }.flatMap { $0 }

                    let cell = Cell(rowId: rowId, columnId: columnId, blockInformation: child)
                    rowBlocks.append(cell)
                }

                blocks.append(rowBlocks)
            }
        }

        self.cells = blocks
    }
}
