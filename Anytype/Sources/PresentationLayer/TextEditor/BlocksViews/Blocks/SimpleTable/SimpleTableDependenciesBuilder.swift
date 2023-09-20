import Services
import UIKit
import AnytypeCore

struct SimpleTableDependenciesContainer {
    let stateManager: SimpleTableStateManager
    let viewModel: SimpleTableViewModel
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
    private let pageService: PageRepositoryProtocol
    private let linkToObjectCoordinator: LinkToObjectCoordinatorProtocol
    private let searchService: SearchServiceProtocol
    private let accessoryStateManager: AccessoryViewStateManager
//    private let collectionController: EditorBlockCollectionController

    weak var mainEditorSelectionManager: SimpleTableSelectionHandler?
    

    init(
        document: BaseDocumentProtocol,
        router: EditorRouterProtocol,
        handler: BlockActionHandlerProtocol,
        pasteboardService: PasteboardServiceProtocol,
        markdownListener: MarkdownListener,
        focusSubjectHolder: FocusSubjectsHolder,
        mainEditorSelectionManager: SimpleTableSelectionHandler?,
        responderScrollViewHelper: ResponderScrollViewHelper,
        pageService: PageRepositoryProtocol,
        linkToObjectCoordinator: LinkToObjectCoordinatorProtocol,
        searchService: SearchServiceProtocol,
        accessoryStateManager: AccessoryViewStateManager
    ) {
        self.document = document
        self.router = router
        self.handler = handler
        self.pasteboardService = pasteboardService
        self.markdownListener = markdownListener
        self.focusSubjectHolder = focusSubjectHolder
//        self.collectionController = collectionController
        self.mainEditorSelectionManager = mainEditorSelectionManager
        self.responderScrollViewHelper = responderScrollViewHelper
        self.pageService = pageService
        self.linkToObjectCoordinator = linkToObjectCoordinator
        self.searchService = searchService
        self.accessoryStateManager = accessoryStateManager
        
        self.cursorManager = EditorCursorManager(focusSubjectHolder: focusSubjectHolder)
    }

    func buildDependenciesContainer(blockInformation: BlockInformation) -> SimpleTableDependenciesContainer {
        let blockInformationProvider = BlockModelInfomationProvider(infoContainer: document.infoContainer, info: blockInformation)
        
        let selectionOptionHandler = SimpleTableSelectionOptionHandler(
            router: router,
            tableService: tableService,
            document: document,
            blockInformationProvider: blockInformationProvider,
            actionHandler: handler
        )

        let stateManager = SimpleTableStateManager(
            document: document,
            blockInformationProvider: blockInformationProvider,
            selectionOptionHandler: selectionOptionHandler,
            router: router,
            cursorManager: cursorManager,
            mainEditorSelectionManager: mainEditorSelectionManager
        )

        let simpleTablesAccessoryState = AccessoryViewBuilder.accessoryState(
            actionHandler: handler,
            router: router,
            document: document,
            searchService: searchService
        )

        let cellsBuilder = SimpleTableCellsBuilder(
            document: document,
            router: router,
            handler: handler,
            pasteboardService: pasteboardService,
            markdownListener: markdownListener,
            cursorManager: cursorManager,
            focusSubjectHolder: focusSubjectHolder,
            responderScrollViewHelper: responderScrollViewHelper, 
            stateManager: stateManager,
            accessoryStateManager: accessoryStateManager,
            blockMarkupChanger: BlockMarkupChanger()
        )

        let viewModel = SimpleTableViewModel(
            document: document,
            tableBlockInfoProvider: .init(infoContainer: document.infoContainer, info: blockInformation),
            cellBuilder: cellsBuilder,
            stateManager: stateManager,
            cursorManager: cursorManager
        )

        return .init(stateManager: stateManager, viewModel: viewModel)
    }
}
