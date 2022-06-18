import BlocksModels
import UIKit
import AnytypeCore

final class SimpleTableViewModelBuilder {
    private var infoContainer: InfoContainerProtocol { document.infoContainer }
    private let document: BaseDocumentProtocol
    private let router: EditorRouterProtocol
    private let handler: BlockActionHandlerProtocol
    private let pasteboardService: PasteboardServiceProtocol
    private let delegate: BlockDelegate
    private let markdownListener: MarkdownListener
    private let cursorManager: EditorCursorManager
    private let focusSubjectHolder: FocusSubjectsHolder

    private weak var relativePositionProvider: RelativePositionProvider?

    init(
        document: BaseDocumentProtocol,
        router: EditorRouterProtocol,
        handler: BlockActionHandlerProtocol,
        pasteboardService: PasteboardServiceProtocol,
        delegate: BlockDelegate,
        markdownListener: MarkdownListener,
        relativePositionProvider: RelativePositionProvider?,
        cursorManager: EditorCursorManager,
        focusSubjectHolder: FocusSubjectsHolder
    ) {
        self.document = document
        self.router = router
        self.handler = handler
        self.pasteboardService = pasteboardService
        self.delegate = delegate
        self.markdownListener = markdownListener
        self.relativePositionProvider = relativePositionProvider
        self.cursorManager = cursorManager
        self.focusSubjectHolder = focusSubjectHolder
    }

    func buildViewModel(from tableInfo: BlockInformation) -> SimpleTableBlockViewModel {
        SimpleTableBlockViewModel(
            info: tableInfo,
            models: buildItems(from: tableInfo),
            blockDelegate: delegate,
            relativePositionProvider: relativePositionProvider
        )
    }

    // MARK: - Private

    private func buildItems(
        from info: BlockInformation
    ) -> [[SimpleTableBlockProtocol]] {
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
    ) -> [[SimpleTableBlockProtocol]] {
        let numberOfColumns = tableColumnsBlockInfo.childrenIds.count
        var blocks = [[SimpleTableBlockProtocol]]()

        for rowId in tableRowsBlockInfo.childrenIds {
            guard let childInformation = infoContainer.get(id: rowId) else {
                anytypeAssertionFailure("Missing column or rows information", domain: .simpleTables)
                return blocks
            }

            if childInformation.content == .tableRow {
                var rowBlocks = [SimpleTableBlockProtocol]()

                for column in 0..<numberOfColumns {
                    if let rowChildInformation = childInformation.childrenIds[safe: column],
                       let rowChildInformation = infoContainer.get(id: rowChildInformation) {
                        if case .text = rowChildInformation.content {

                            let cellConfiguration = SimpleTableCellConfiguration(
                                item: textBlockConfiguration(information: rowChildInformation),
                                backgroundColor: rowChildInformation.backgroundColor.map(UIColor.Background.uiColor(from:)) ?? nil
                            )

                            rowBlocks.append(cellConfiguration)
                        }
                    } else {
                        let columnId = tableColumnsBlockInfo.childrenIds[column]

                        let cellConfiguration = makeEmptyContentCellConfiguration(
                            columnId: columnId,
                            info: childInformation
                        )
                        rowBlocks.append(cellConfiguration)
                    }
                }

                blocks.append(rowBlocks)
            }
        }

        return blocks
    }

    private func makeEmptyContentCellConfiguration(
        columnId: BlockId,
        info: BlockInformation
    ) -> SimpleTableBlockProtocol {
        let configuration = EmptyRowViewViewModel(
            contextId: document.objectId,
            info: info,
            columnRowId: "\(info.id)-\(columnId)",
            tablesService: BlockTableService(),
            cursorManager: cursorManager
        ).emptyRowConfiguration()

        return SimpleTableCellConfiguration(
            item: configuration,
            backgroundColor: .backgroundPrimary // get column background
        )
    }

    private func textBlockConfiguration(information: BlockInformation) -> TextBlockContentConfiguration {
        guard case let .text(content) = information.content else {
            fatalError()
        }

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

        return TextBlockViewModel(
            info: information,
            content: content,
            isCheckable: isCheckable,
            focusSubject: focusSubjectHolder.focusSubject(for: information.id),
            actionHandler: textBlockActionHandler
        ).textBlockContentConfiguration()
    }
}
