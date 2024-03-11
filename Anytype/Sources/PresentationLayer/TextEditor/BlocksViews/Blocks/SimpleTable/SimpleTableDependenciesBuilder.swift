import Services
import UIKit
import AnytypeCore

final class SimpleTableHeightCacheContainer {
    var cachedSectionRowHeights = [AnyHashable: CGFloat]()
}

struct SimpleTableDependenciesContainer {
    let blockDelegate: BlockDelegate?
    let relativePositionProvider: RelativePositionProvider?
    let stateManager: SimpleTableStateManager
    let viewModel: SimpleTableViewModel
    let cacheContainer: SimpleTableHeightCacheContainer
}

@MainActor
final class SimpleTableDependenciesBuilder {
    let cursorManager: EditorCursorManager
    
    private let document: BaseDocumentProtocol
    private let router: EditorRouterProtocol
    private let handler: BlockActionHandlerProtocol
    private let pasteboardService: PasteboardServiceProtocol
    private let markdownListener: MarkdownListener
    private let focusSubjectHolder: FocusSubjectsHolder
    private let tableService = BlockTableService()
    private let responderScrollViewHelper: ResponderScrollViewHelper
    private let cacheContainer = SimpleTableHeightCacheContainer()
    private let defaultObjectService: DefaultObjectCreationServiceProtocol
    private let linkToObjectCoordinator: LinkToObjectCoordinatorProtocol

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
        mainEditorSelectionManager: SimpleTableSelectionHandler?,
        responderScrollViewHelper: ResponderScrollViewHelper,
        defaultObjectService: DefaultObjectCreationServiceProtocol,
        linkToObjectCoordinator: LinkToObjectCoordinatorProtocol
    ) {
        self.document = document
        self.router = router
        self.handler = handler
        self.pasteboardService = pasteboardService
        self.markdownListener = markdownListener
        self.focusSubjectHolder = focusSubjectHolder
        self.viewInput = viewInput
        self.mainEditorSelectionManager = mainEditorSelectionManager
        self.responderScrollViewHelper = responderScrollViewHelper
        self.defaultObjectService = defaultObjectService
        self.linkToObjectCoordinator = linkToObjectCoordinator
        
        self.cursorManager = EditorCursorManager(focusSubjectHolder: focusSubjectHolder)
    }

    func buildDependenciesContainer(blockInformation: BlockInformation) -> SimpleTableDependenciesContainer {
        let selectionOptionHandler = SimpleTableSelectionOptionHandler(
            router: router,
            tableService: tableService,
            document: document,
            tableBlockInformation: blockInformation,
            actionHandler: handler
        )

        let stateManager = SimpleTableStateManager(
            document: document,
            tableBlockInformation: blockInformation,
            selectionOptionHandler: selectionOptionHandler,
            router: router,
            cursorManager: cursorManager,
            mainEditorSelectionManager: mainEditorSelectionManager
        )

        let simpleTablesAccessoryState = AccessoryViewBuilder.accessoryState(
            actionHandler: handler,
            router: router,
            pasteboardService: pasteboardService,
            document: document,
            onShowStyleMenu: stateManager.didSelectStyleSelection(infos:),
            onBlockSelection: stateManager.didSelectEditingState(info:),
            linkToObjectCoordinator: linkToObjectCoordinator,
            cursorManager: cursorManager
        )

        let simpleTablesBlockDelegate = BlockDelegateImpl(
            viewInput: viewInput,
            accessoryState: simpleTablesAccessoryState.0,
            cursorManager: cursorManager
        )

        let cellsBuilder = SimpleTableCellsBuilder(
            document: document,
            router: router,
            handler: handler,
            pasteboardService: pasteboardService,
            delegate: simpleTablesBlockDelegate,
            markdownListener: markdownListener,
            cursorManager: cursorManager,
            focusSubjectHolder: focusSubjectHolder,
            responderScrollViewHelper: responderScrollViewHelper
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
            viewModel: viewModel,
            cacheContainer: cacheContainer
        )
    }
}
