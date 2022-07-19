import BlocksModels
import UIKit
import AnytypeCore

struct SimpleTableDependenciesContainer {
    let blockDelegate: BlockDelegate?
    let relativePositionProvider: RelativePositionProvider?
    let stateManager: SimpleTableStateManager
    let viewModel: SimpleTableViewModel
}

final class SimpleTableDependenciesBuilder {
    private let document: BaseDocumentProtocol
    private let router: EditorRouterProtocol
    private let handler: BlockActionHandlerProtocol
    private let pasteboardService: PasteboardServiceProtocol
    private let markdownListener: MarkdownListener
    private let focusSubjectHolder: FocusSubjectsHolder
    private let tableService = BlockTableService()

    weak var mainEditorSelectionManager: SimpleTableSelectionHandler?
    weak var viewInput: (EditorPageViewInput & RelativePositionProvider)?

    init(
        document: BaseDocumentProtocol,
        router: EditorRouterProtocol,
        handler: BlockActionHandlerProtocol,
        pasteboardService: PasteboardServiceProtocol,
        markdownListener: MarkdownListener,
        focusSubjectHolder: FocusSubjectsHolder,
        viewInput: (EditorPageViewInput & RelativePositionProvider)?,
        mainEditorSelectionManager: SimpleTableSelectionHandler?
    ) {
        self.document = document
        self.router = router
        self.handler = handler
        self.pasteboardService = pasteboardService
        self.markdownListener = markdownListener
        self.focusSubjectHolder = focusSubjectHolder
        self.viewInput = viewInput
        self.mainEditorSelectionManager = mainEditorSelectionManager
    }

    func buildDependenciesContainer(blockInformation: BlockInformation) -> SimpleTableDependenciesContainer {
        let cursorManager = EditorCursorManager(focusSubjectHolder: focusSubjectHolder)

        let stateManager = SimpleTableStateManager(
            document: document,
            tableBlockInformation: blockInformation,
            tableService: tableService,
            listService: BlockListService(contextId: document.objectId),
            router: router,
            actionHandler: handler,
            cursorManager: cursorManager,
            mainEditorSelectionManager: mainEditorSelectionManager
        )

        let simpleTablesAccessoryState = AccessoryViewBuilder.accessoryState(
            actionHandler: handler,
            router: router,
            pasteboardService: pasteboardService,
            document: document,
            onShowStyleMenu: stateManager.didSelectStyleSelection(info:),
            onBlockSelection: stateManager.didSelectEditingState(info:)
        )

        let simpleTablesBlockDelegate = BlockDelegateImpl(
            viewInput: viewInput,
            accessoryState: simpleTablesAccessoryState
        )

        let cellsBuilder = SimpleTableCellsBuilder(
            document: document,
            router: router,
            handler: handler,
            pasteboardService: pasteboardService,
            delegate: simpleTablesBlockDelegate,
            markdownListener: markdownListener,
            cursorManager: cursorManager,
            focusSubjectHolder: focusSubjectHolder
        )

        let viewModel = SimpleTableViewModel(
            document: document,
            tableBlockInfo: blockInformation,
            cellBuilder: cellsBuilder,
            stateManager: stateManager,
            cursorManager: cursorManager
        )

        return .init(
            blockDelegate: simpleTablesBlockDelegate,
            relativePositionProvider: viewInput,
            stateManager: stateManager,
            viewModel: viewModel
        )
    }
}
