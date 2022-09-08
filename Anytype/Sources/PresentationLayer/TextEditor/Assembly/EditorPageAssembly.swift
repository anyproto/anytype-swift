import BlocksModels
import UIKit
import AnytypeCore

final class EditorAssembly {
    
    private let serviceLocator: ServiceLocator
    private let coordinatorsDI: CoordinatorsDIProtocol
    
    init(
        serviceLocator: ServiceLocator,
        coordinatorsDI: CoordinatorsDIProtocol
    ) {
        self.serviceLocator = serviceLocator
        self.coordinatorsDI = coordinatorsDI
    }
    
    func buildEditorController(
        browser: EditorBrowserController?,
        data: EditorScreenData,
        editorBrowserViewInput: EditorBrowserViewInputProtocol?
    ) -> UIViewController {
        buildEditorModule(browser: browser, data: data, editorBrowserViewInput: editorBrowserViewInput).vc
    }

    func buildEditorModule(
        browser: EditorBrowserController?,
        data: EditorScreenData,
        editorBrowserViewInput: EditorBrowserViewInputProtocol?
    ) -> (vc: UIViewController, router: EditorRouterProtocol) {
        switch data.type {
        case .page:
            let module = buildPageModule(browser: browser, data: data)
            module.0.browserViewInput = editorBrowserViewInput
            return module
        case .set:
            return buildSetModule(browser: browser, data: data)
        }
    }
    
    // MARK: - Set
    private func buildSetModule(
        browser: EditorBrowserController?,
        data: EditorScreenData
    ) -> (EditorSetHostingController, EditorRouterProtocol) {
        let document = BaseDocument(objectId: data.pageId)
        let dataviewService = DataviewService(
            objectId: data.pageId,
            prefilledFieldsBuilder: SetFilterPrefilledFieldsBuilder()
        )
        let detailsService = ServiceLocator.shared.detailsService(objectId: data.pageId)

        let model = EditorSetViewModel(
            document: document,
            dataviewService: dataviewService,
            searchService: ServiceLocator.shared.searchService(),
            detailsService: detailsService,
            relationDetailsStorage: ServiceLocator.shared.relationDetailsStorage()
        )
        let controller = EditorSetHostingController(objectId: data.pageId, model: model)

        let router = EditorRouter(
            rootController: browser,
            viewController: controller,
            document: document,
            assembly: self,
            templatesCoordinator: coordinatorsDI.templates.make(viewController: controller),
            urlOpener: URLOpener(viewController: browser),
            relationValueCoordinator: coordinatorsDI.relationValue.make(viewController: controller)
        )
        
        model.setup(router: router)
        
        return (controller, router)
    }
    
    // MARK: - Page
    
    private func buildPageModule(
        browser: EditorBrowserController?,
        data: EditorScreenData
    ) -> (EditorPageController, EditorRouterProtocol) {
        let simpleTableMenuViewModel = SimpleTableMenuViewModel()
        let blocksOptionViewModel = SelectionOptionsViewModel(itemProvider: nil)

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
            templatesCoordinator: coordinatorsDI.templates.make(viewController: controller),
            urlOpener: URLOpener(viewController: browser),
            relationValueCoordinator: coordinatorsDI.relationValue.make(viewController: controller)
        )

        let viewModel = buildViewModel(
            scrollView: controller.collectionView,
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
        scrollView: UIScrollView,
        viewInput: EditorPageViewInput,
        document: BaseDocumentProtocol,
        router: EditorRouter,
        blocksOptionViewModel: SelectionOptionsViewModel,
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
            initialEditingState: isOpenedForPreview ? .locked : .editing,
            viewInput: viewInput
        )
        
        let accessoryState = AccessoryViewBuilder.accessoryState(
            actionHandler: actionHandler,
            router: router,
            pasteboardService: pasteboardService,
            document: document,
            onShowStyleMenu: blocksStateManager.didSelectStyleSelection(info:),
            onBlockSelection: actionHandler.selectBlock(info:)
        )
        
        let markdownListener = MarkdownListenerImpl()
        
        let blockDelegate = BlockDelegateImpl(
            viewInput: viewInput,
            accessoryState: accessoryState
        )

        let headerModel = ObjectHeaderViewModel(
            document: document,
            router: router,
            isOpenedForPreview: isOpenedForPreview
        )

        let responderScrollViewHelper = ResponderScrollViewHelper(scrollView: scrollView)
        let simpleTableDependenciesBuilder = SimpleTableDependenciesBuilder(
            document: document,
            router: router,
            handler: actionHandler,
            pasteboardService: pasteboardService,
            markdownListener: markdownListener,
            focusSubjectHolder: focusSubjectHolder,
            viewInput: viewInput,
            mainEditorSelectionManager: blocksStateManager,
            responderScrollViewHelper: responderScrollViewHelper
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
        blockOptionsViewViewModel: SelectionOptionsViewModel
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
