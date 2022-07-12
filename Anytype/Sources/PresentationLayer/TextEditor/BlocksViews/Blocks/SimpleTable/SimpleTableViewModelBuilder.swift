import BlocksModels
import UIKit
import AnytypeCore

final class SimpleTableViewModelBuilder {
    private let document: BaseDocumentProtocol
    private let router: EditorRouterProtocol
    private let handler: BlockActionHandlerProtocol
    private let pasteboardService: PasteboardServiceProtocol
    private let markdownListener: MarkdownListener
    private let cursorManager: EditorCursorManager
    private let focusSubjectHolder: FocusSubjectsHolder

    weak var mainEditorSelectionManager: SimpleTableSelectionHandler?
    private weak var relativePositionProvider: RelativePositionProvider?

    init(
        document: BaseDocumentProtocol,
        router: EditorRouterProtocol,
        handler: BlockActionHandlerProtocol,
        pasteboardService: PasteboardServiceProtocol,
        markdownListener: MarkdownListener,
        relativePositionProvider: RelativePositionProvider?,
        cursorManager: EditorCursorManager,
        focusSubjectHolder: FocusSubjectsHolder
    ) {
        self.document = document
        self.router = router
        self.handler = handler
        self.pasteboardService = pasteboardService
        self.markdownListener = markdownListener
        self.relativePositionProvider = relativePositionProvider
        self.cursorManager = cursorManager
        self.focusSubjectHolder = focusSubjectHolder
    }

    func buildViewModel(from tableInfo: BlockInformation) -> SimpleTableBlockViewModel {
        let tableService = BlockTableService()

        let stateManager = SimpleTableStateManager(
            document: document,
            tableBlockInformation: tableInfo,
            tableService: tableService,
            mainEditorSelectionManager: mainEditorSelectionManager
        )

        let simpleTablesAccessoryState = AccessoryViewBuilder.accessoryState(
            actionHandler: handler,
            router: router,
            pasteboardService: pasteboardService,
            document: document,
            onShowStyleMenu: { _ in } ,
            onBlockSelection: stateManager.didSelectEditingState(info:)
        )

        let simpleTablesBlockDelegate = BlockDelegateImpl(
            viewInput: nil,
            accessoryState: simpleTablesAccessoryState
        )

        let viewModel = SimpleTableBlockViewModel(
            document: document,
            info: tableInfo,
            cellsBuilder: .init(
                document: document,
                router: router,
                handler: handler,
                pasteboardService: pasteboardService,
                delegate: simpleTablesBlockDelegate,
                markdownListener: markdownListener,
                cursorManager: cursorManager,
                focusSubjectHolder: focusSubjectHolder
            ),
            blockDelegate: simpleTablesBlockDelegate,
            cursorManager: cursorManager,
            stateManager: stateManager,
            relativePositionProvider: relativePositionProvider
        )

        return viewModel
    }
}
