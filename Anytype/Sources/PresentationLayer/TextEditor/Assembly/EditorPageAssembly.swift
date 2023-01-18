import BlocksModels
import UIKit
import AnytypeCore

final class EditorAssembly {
    
    private let serviceLocator: ServiceLocator
    private let coordinatorsDI: CoordinatorsDIProtocol
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    
    init(
        serviceLocator: ServiceLocator,
        coordinatorsDI: CoordinatorsDIProtocol,
        modulesDI: ModulesDIProtocol,
        uiHelpersDI: UIHelpersDIProtocol
    ) {
        self.serviceLocator = serviceLocator
        self.coordinatorsDI = coordinatorsDI
        self.modulesDI = modulesDI
        self.uiHelpersDI = uiHelpersDI
    }
    
    func buildEditorController(
        browser: EditorBrowserController?,
        data: EditorScreenData
    ) -> UIViewController {
        buildEditorModule(browser: browser, data: data).vc
    }

    func buildEditorModule(
        browser: EditorBrowserController?,
        data: EditorScreenData
    ) -> (vc: UIViewController, router: EditorPageOpenRouterProtocol) {
        switch data.type {
        case .page:
            return buildPageModule(browser: browser, data: data)
        case .set:
            return buildSetModule(browser: browser, data: data)
        }
    }
    
    // MARK: - Set
    private func buildSetModule(
        browser: EditorBrowserController?,
        data: EditorScreenData
    ) -> (EditorSetHostingController, EditorPageOpenRouterProtocol) {
        let document = BaseDocument(objectId: data.pageId)
        let setDocument = SetDocument(
            document: document,
            relationDetailsStorage: ServiceLocator.shared.relationDetailsStorage()
        )
        let dataviewService = DataviewService(
            objectId: data.pageId,
            prefilledFieldsBuilder: SetPrefilledFieldsBuilder()
        )
        let detailsService = ServiceLocator.shared.detailsService(objectId: data.pageId)
        
        let model = EditorSetViewModel(
            setDocument: setDocument,
            dataviewService: dataviewService,
            searchService: ServiceLocator.shared.searchService(),
            detailsService: detailsService,
            objectActionsService: ServiceLocator.shared.objectActionsService(),
            textService: serviceLocator.textService,
            groupsSubscriptionsHandler: ServiceLocator.shared.groupsSubscriptionsHandler(),
            setSubscriptionDataBuilder: SetSubscriptionDataBuilder()
        )
        let controller = EditorSetHostingController(objectId: data.pageId, model: model)

        let router = EditorSetRouter(
            document: document,
            rootController: browser,
            viewController: controller,
            navigationContext: NavigationContext(rootViewController: browser ?? controller),
            createObjectModuleAssembly: modulesDI.createObject,
            newSearchModuleAssembly: modulesDI.newSearch,
            editorPageCoordinator: coordinatorsDI.editorPage.make(browserController: browser),
            addNewRelationCoordinator: coordinatorsDI.addNewRelation.make(document: document),
            objectSettingCoordinator: coordinatorsDI.objectSettings.make(document: document, browserController: browser),
            relationValueCoordinator: coordinatorsDI.relationValue.make(),
            objectCoverPickerModuleAssembly: modulesDI.objectCoverPicker,
            objectIconPickerModuleAssembly: modulesDI.objectIconPicker,
            toastPresenter: uiHelpersDI.toastPresenter(using: browser),
            alertHelper: AlertHelper(viewController: controller)
        )
        
        model.setup(router: router)
        
        return (controller, router)
    }
    
    // MARK: - Page
    
    private func buildPageModule(
        browser: EditorBrowserController?,
        data: EditorScreenData
    ) -> (EditorPageController, EditorPageOpenRouterProtocol) {
        let simpleTableMenuViewModel = SimpleTableMenuViewModel()
        let blocksOptionViewModel = SelectionOptionsViewModel(itemProvider: nil)

        let blocksSelectionOverlayView = buildBlocksSelectionOverlayView(
            simleTableMenuViewModel: simpleTableMenuViewModel,
            blockOptionsViewViewModel: blocksOptionViewModel
        )
        let bottomNavigationManager = EditorBottomNavigationManager(browser: browser)
        
        let controller = EditorPageController(
            blocksSelectionOverlayView: blocksSelectionOverlayView,
            bottomNavigationManager: bottomNavigationManager,
            browserViewInput: browser
        )
        let document = BaseDocument(objectId: data.pageId)
        let router = EditorRouter(
            rootController: browser,
            viewController: controller,
            navigationContext: NavigationContext(rootViewController: browser ?? controller),
            document: document,
            addNewRelationCoordinator: coordinatorsDI.addNewRelation.make(document: document),
            templatesCoordinator: coordinatorsDI.templates.make(viewController: controller),
            urlOpener: URLOpener(viewController: browser),
            relationValueCoordinator: coordinatorsDI.relationValue.make(),
            editorPageCoordinator: coordinatorsDI.editorPage.make(browserController: browser),
            linkToObjectCoordinator: coordinatorsDI.linkToObject.make(browserController: browser),
            objectCoverPickerModuleAssembly: modulesDI.objectCoverPicker,
            objectIconPickerModuleAssembly: modulesDI.objectIconPicker,
            objectSettingCoordinator: coordinatorsDI.objectSettings.make(document: document, browserController: browser),
            searchModuleAssembly: modulesDI.search,
            toastPresenter: uiHelpersDI.toastPresenter(using: browser),
            codeLanguageListModuleAssembly: modulesDI.codeLanguageList,
            newSearchModuleAssembly: modulesDI.newSearch,
            textIconPickerModuleAssembly: modulesDI.textIconPicker,
            alertHelper: AlertHelper(viewController: controller)
        )

        let viewModel = buildViewModel(
            browser: browser,
            controller: controller,
            scrollView: controller.collectionView,
            viewInput: controller,
            document: document,
            router: router,
            blocksOptionViewModel: blocksOptionViewModel,
            simpleTableMenuViewModel: simpleTableMenuViewModel,
            blocksSelectionOverlayViewModel: blocksSelectionOverlayView.viewModel,
            bottomNavigationManager: bottomNavigationManager,
            isOpenedForPreview: data.isOpenedForPreview
        )

        controller.viewModel = viewModel
        
        return (controller, router)
    }
    
    private func buildViewModel(
        browser: EditorBrowserController?,
        controller: UIViewController,
        scrollView: UIScrollView,
        viewInput: EditorPageViewInput,
        document: BaseDocumentProtocol,
        router: EditorRouter,
        blocksOptionViewModel: SelectionOptionsViewModel,
        simpleTableMenuViewModel: SimpleTableMenuViewModel,
        blocksSelectionOverlayViewModel: BlocksSelectionOverlayViewModel,
        bottomNavigationManager: EditorBottomNavigationManagerProtocol,
        isOpenedForPreview: Bool
    ) -> EditorPageViewModel {
        let modelsHolder = EditorMainItemModelsHolder()
        let markupChanger = BlockMarkupChanger(infoContainer: document.infoContainer)
        let focusSubjectHolder = FocusSubjectsHolder()

        let cursorManager = EditorCursorManager(focusSubjectHolder: focusSubjectHolder)
        let listService = ServiceLocator.shared.blockListService(documentId: document.objectId)
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
            toastPresenter: uiHelpersDI.toastPresenter(using: browser),
            actionHandler: actionHandler,
            pasteboardService: pasteboardService,
            router: router,
            initialEditingState: isOpenedForPreview ? .locked : .editing,
            viewInput: viewInput,
            bottomNavigationManager: bottomNavigationManager
        )
        
        let accessoryState = AccessoryViewBuilder.accessoryState(
            actionHandler: actionHandler,
            router: router,
            pasteboardService: pasteboardService,
            document: document,
            onShowStyleMenu: blocksStateManager.didSelectStyleSelection(info:),
            onBlockSelection: actionHandler.selectBlock(info:),
            pageService: serviceLocator.pageService(),
            linkToObjectCoordinator: coordinatorsDI.linkToObject.make(browserController: browser)
        )
        
        let markdownListener = MarkdownListenerImpl(
            internalListeners: [
                BeginingOfTextMarkdownListener(),
                InlineMarkdownListener()
            ]
        )
        
        let blockDelegate = BlockDelegateImpl(
            viewInput: viewInput,
            accessoryState: accessoryState,
            cursorManager: cursorManager
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
            responderScrollViewHelper: responderScrollViewHelper,
            pageService: serviceLocator.pageService(),
            linkToObjectCoordinator: coordinatorsDI.linkToObject.make(browserController: browser)
        )

        let blocksConverter = BlockViewModelBuilder(
            document: document,
            handler: actionHandler,
            pasteboardService: pasteboardService,
            router: router,
            delegate: blockDelegate,
            markdownListener: markdownListener,
            simpleTableDependenciesBuilder: simpleTableDependenciesBuilder,
            subjectsHolder: focusSubjectHolder,
            pageService: serviceLocator.pageService(),
            detailsService: serviceLocator.detailsService(objectId: document.objectId)
        )

        actionHandler.blockSelectionHandler = blocksStateManager

        blocksStateManager.blocksSelectionOverlayViewModel = blocksSelectionOverlayViewModel
        blocksStateManager.blocksOptionViewModel = blocksOptionViewModel
        
        let editorPageTemplatesHandler = EditorPageTemplatesHandler()
        
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
            editorPageTemplatesHandler: editorPageTemplatesHandler,
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
