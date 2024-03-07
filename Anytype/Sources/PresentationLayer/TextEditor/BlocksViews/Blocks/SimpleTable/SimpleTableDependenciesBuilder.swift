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
    private let pasteboardService: PasteboardBlockDocumentServiceProtocol
    private let markdownListener: MarkdownListener
    private let focusSubjectHolder: FocusSubjectsHolder
    private let tableService: BlockTableServiceProtocol
    private let responderScrollViewHelper: ResponderScrollViewHelper
    private let defaultObjectService: DefaultObjectCreationServiceProtocol
    private let linkToObjectCoordinator: LinkToObjectCoordinatorProtocol
    private let typesService: TypesServiceProtocol
    private let accessoryStateManager: AccessoryViewStateManager

    weak var mainEditorSelectionManager: SimpleTableSelectionHandler?
    

    init(
        document: BaseDocumentProtocol,
        router: EditorRouterProtocol,
        handler: BlockActionHandlerProtocol,
        pasteboardService: PasteboardBlockDocumentServiceProtocol,
        markdownListener: MarkdownListener,
        focusSubjectHolder: FocusSubjectsHolder,
        mainEditorSelectionManager: SimpleTableSelectionHandler?,
        responderScrollViewHelper: ResponderScrollViewHelper,
        defaultObjectService: DefaultObjectCreationServiceProtocol,
        linkToObjectCoordinator: LinkToObjectCoordinatorProtocol,
        typesService: TypesServiceProtocol,
        accessoryStateManager: AccessoryViewStateManager,
        tableService: BlockTableServiceProtocol
    ) {
        self.document = document
        self.router = router
        self.handler = handler
        self.pasteboardService = pasteboardService
        self.markdownListener = markdownListener
        self.focusSubjectHolder = focusSubjectHolder
        self.mainEditorSelectionManager = mainEditorSelectionManager
        self.responderScrollViewHelper = responderScrollViewHelper
        self.defaultObjectService = defaultObjectService
        self.linkToObjectCoordinator = linkToObjectCoordinator
        self.typesService = typesService
        self.accessoryStateManager = accessoryStateManager
        self.tableService = tableService
        
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
            blockMarkupChanger: BlockMarkupChanger(),
            blockTableService: tableService
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
