import BlocksModels
import UIKit
import AnytypeCore

final class EditorAssembly {
    private weak var browser: EditorBrowserController?
    
    init(browser: EditorBrowserController?) {
        self.browser = browser
    }
    
    func buildEditorController(
        data: EditorScreenData,
        editorBrowserViewInput: EditorBrowserViewInputProtocol?
    ) -> UIViewController {
        buildEditorModule(data: data, editorBrowserViewInput: editorBrowserViewInput).vc
    }

    func buildEditorModule(
        data: EditorScreenData,
        editorBrowserViewInput: EditorBrowserViewInputProtocol?
    ) -> (vc: UIViewController, router: EditorRouterProtocol) {
        switch data.type {
        case .page:
            let module = buildPageModule(data: data)
            module.0.browserViewInput = editorBrowserViewInput
            return module
        case .set:
            return buildSetModule(data: data)
        }
    }
    
    // MARK: - Set
    private func buildSetModule(data: EditorScreenData) -> (EditorSetHostingController, EditorRouterProtocol) {
        let searchService = SearchService()
        let document = BaseDocument(objectId: data.pageId)
        let dataviewService = DataviewService(objectId: data.pageId)

        let model = EditorSetViewModel(
            document: document,
            dataviewService: dataviewService,
            searchService: searchService
        )
        let controller = EditorSetHostingController(objectId: data.pageId, model: model)

        
        let router = EditorRouter(
            rootController: browser,
            viewController: controller,
            document: document,
            assembly: self,
            templatesCoordinator: TemplatesCoordinator(
                rootViewController: controller,
                keyboardHeightListener: .init(),
                searchService: searchService
            )
        )
        
        model.setup(router: router)
        
        return (controller, router)
    }
    
    // MARK: - Page
    
    private func buildPageModule(data: EditorScreenData) -> (EditorPageController, EditorRouterProtocol) {
        let simpleTableMenuViewModel = SimpleTableMenuViewModel()
        let blocksOptionViewModel = HorizonalTypeListViewModel(itemProvider: nil)

        let blocksSelectionOverlayView = buildBlocksSelectionOverlayView(
            simleTableMenuViewModel: simpleTableMenuViewModel,
            blockOptionsViewViewModel: blocksOptionViewModel
        )

        let controller = EditorPageController(blocksSelectionOverlayView: blocksSelectionOverlayView)
        let document = BaseDocument(objectId: data.pageId)
        let router = EditorRouter(
            rootController: browser,
            viewController: controller,
            document: document,
            assembly: self,
            templatesCoordinator: TemplatesCoordinator(
                rootViewController: controller,
                keyboardHeightListener: .init(),
                searchService: SearchService()
            )
        )

        let viewModel = buildViewModel(
            viewInput: controller,
            document: document,
            router: router,
            blocksOptionViewModel: blocksOptionViewModel,
            simpleTableMenuViewModel: simpleTableMenuViewModel,
            blocksSelectionOverlayViewModel: blocksSelectionOverlayView.viewModel,
            isOpenedForPreview: data.isOpenedForPreview
        )

        controller.viewModel = viewModel
        
        return (controller, router)
    }
    
    private func buildViewModel(
        viewInput: EditorPageViewInput,
        document: BaseDocumentProtocol,
        router: EditorRouter,
        blocksOptionViewModel: HorizonalTypeListViewModel,
        simpleTableMenuViewModel: SimpleTableMenuViewModel,
        blocksSelectionOverlayViewModel: BlocksSelectionOverlayViewModel,
        isOpenedForPreview: Bool
    ) -> EditorPageViewModel {                
        let modelsHolder = EditorMainItemModelsHolder()
        let markupChanger = BlockMarkupChanger(infoContainer: document.infoContainer)
        let focusSubjectHolder = FocusSubjectsHolder()

        let cursorManager = EditorCursorManager(focusSubjectHolder: focusSubjectHolder)
        let listService = BlockListService(contextId: document.objectId)
        let singleService = ServiceLocator.shared.blockActionsServiceSingle(contextId: document.objectId)
        let blockActionService = BlockActionService(
            documentId: document.objectId,
            listService: listService,
            singleService: singleService,
            modelsHolder: modelsHolder,
            cursorManager: cursorManager
        )
        let keyboardHandler = KeyboardActionHandler(
            service: blockActionService,
            listService: listService,
            toggleStorage: ToggleStorage.shared,
            container: document.infoContainer,
            modelsHolder: modelsHolder
        )

        let blockTableService = BlockTableService()
        let actionHandler = BlockActionHandler(
            document: document,
            markupChanger: markupChanger,
            service: blockActionService,
            listService: listService,
            keyboardHandler: keyboardHandler,
            blockTableService: blockTableService
        )

        let pasteboardMiddlewareService = PasteboardMiddleService(document: document)
        let pasteboardHelper = PasteboardHelper()
        let pasteboardService = PasteboardService(document: document,
                                                  pasteboardHelper: pasteboardHelper,
                                                  pasteboardMiddlewareService: pasteboardMiddlewareService)
        
        let accessoryState = AccessoryViewBuilder.accessoryState(
            actionHandler: actionHandler,
            router: router,
            pasteboardService: pasteboardService,
            document: document,
            onShowStyleMenu: router.showStyleMenu(information:),
            onBlockSelection: actionHandler.selectBlock(info:)
        )
        
        let markdownListener = MarkdownListenerImpl()
        
        let blockDelegate = BlockDelegateImpl(
            viewInput: viewInput,
            accessoryState: accessoryState
        )

        let wholeBlockMarkupViewModel = MarkupViewModel(
            actionHandler: actionHandler
        )

        let headerModel = ObjectHeaderViewModel(
            document: document,
            router: router,
            isOpenedForPreview: isOpenedForPreview
        )
        let blockActionsServiceSingle = ServiceLocator.shared
            .blockActionsServiceSingle(contextId: document.objectId)

        let blocksStateManager = EditorPageBlocksStateManager(
            document: document,
            modelsHolder: modelsHolder,
            blocksSelectionOverlayViewModel: blocksSelectionOverlayViewModel,
            blockActionsServiceSingle: blockActionsServiceSingle,
            actionHandler: actionHandler,
            pasteboardService: pasteboardService,
            router: router,
            initialEditingState: isOpenedForPreview ? .locked : .editing
        )

        let simpleTableDependenciesBuilder = SimpleTableDependenciesBuilder(
            document: document,
            router: router,
            handler: actionHandler,
            pasteboardService: pasteboardService,
            markdownListener: markdownListener,
            focusSubjectHolder: focusSubjectHolder,
            viewInput: viewInput,
            mainEditorSelectionManager: blocksStateManager
        )

        let blocksConverter = BlockViewModelBuilder(
            document: document,
            handler: actionHandler,
            pasteboardService: pasteboardService,
            router: router,
            delegate: blockDelegate,
            markdownListener: markdownListener,
            simpleTableDependenciesBuilder: simpleTableDependenciesBuilder,
            subjectsHolder: focusSubjectHolder
        )

        actionHandler.blockSelectionHandler = blocksStateManager

        blocksStateManager.blocksSelectionOverlayViewModel = blocksSelectionOverlayViewModel
        blocksStateManager.blocksOptionViewModel = blocksOptionViewModel
        
        return EditorPageViewModel(
            document: document,
            viewInput: viewInput,
            blockDelegate: blockDelegate,
            router: router,
            modelsHolder: modelsHolder,
            blockBuilder: blocksConverter,
            actionHandler: actionHandler,
            wholeBlockMarkupViewModel: wholeBlockMarkupViewModel,
            headerModel: headerModel,
            blockActionsService: blockActionsServiceSingle,
            blocksStateManager: blocksStateManager,
            cursorManager: cursorManager,
            objectActionsService: ServiceLocator.shared.objectActionsService(),
            searchService: ServiceLocator.shared.searchService(),
            isOpenedForPreview: isOpenedForPreview
        )
    }

    private func buildBlocksSelectionOverlayView(
        simleTableMenuViewModel: SimpleTableMenuViewModel,
        blockOptionsViewViewModel: HorizonalTypeListViewModel
    ) -> BlocksSelectionOverlayView {
        let blocksOptionView = SelectionOptionsView(viewModel: blockOptionsViewViewModel)
        let blocksSelectionOverlayViewModel = BlocksSelectionOverlayViewModel()

        return BlocksSelectionOverlayView(
            viewModel: blocksSelectionOverlayViewModel,
            blocksOptionView: blocksOptionView,
            simpleTablesOptionView: SimpleTableMenuView(viewModel: simleTableMenuViewModel)
        )
    }
}
