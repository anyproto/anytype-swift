import Services
import UIKit
import AnytypeCore
import SwiftUI

@MainActor
final class EditorAssembly {
    
    private let serviceLocator: ServiceLocator
    private let coordinatorsDI: CoordinatorsDIProtocol
    private let modulesDI: ModulesDIProtocol
    private let uiHelpersDI: UIHelpersDIProtocol
    
    nonisolated init(
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
        data: EditorScreenData,
        widgetListOutput: WidgetObjectListCommonModuleOutput? = nil
    ) -> UIViewController {
        buildEditorModule(browser: browser, data: data, widgetListOutput: widgetListOutput).vc
    }

    func buildEditorModule(
        browser: EditorBrowserController?,
        data: EditorScreenData,
        widgetListOutput: WidgetObjectListCommonModuleOutput? = nil
    ) -> (vc: UIViewController, router: EditorPageOpenRouterProtocol?) {
        switch data {
        case let .page(pageData):
            return buildPageModule(browser: browser, data: pageData)
        case let .set(setData):
            return buildSetModule(browser: browser, data: setData)
        case .favorites:
            return favoritesModule(browser: browser, output: widgetListOutput)
        case .recentEdit:
            return recentEditModule(browser: browser, output: widgetListOutput)
        case .recentOpen:
            return recentOpenModule(browser: browser, output: widgetListOutput)
        case .sets:
            return setsModule(browser: browser, output: widgetListOutput)
        case .collections:
            return collectionsModule(browser: browser, output: widgetListOutput)
        case .bin:
            return binModule(browser: browser, output: widgetListOutput)
        }
    }
    
    // MARK: - Set
    
    private func buildSetModule(
        browser: EditorBrowserController?,
        data: EditorSetObject
    ) -> (EditorSetHostingController, EditorPageOpenRouterProtocol) {
        let setDocument = serviceLocator.documentsProvider.setDocument(
            objectId: data.objectId,
            forPreview: !data.isSupportedForEdit,
            inlineParameters: data.inline
        )
        let dataviewService = serviceLocator.dataviewService(objectId: data.objectId, blockId: data.inline?.blockId)
        
        let detailsService = serviceLocator.detailsService(objectId: data.objectId)
        
        let headerModel = ObjectHeaderViewModel(
            document: setDocument,
            configuration: .init(
                isOpenedForPreview: false,
                usecase: .editor
            ),
            interactor: serviceLocator.objectHeaderInteractor(objectId: setDocument.inlineParameters?.targetObjectID ?? setDocument.objectId)
        )
        
        let model = EditorSetViewModel(
            setDocument: setDocument,
            headerViewModel: headerModel,
            subscriptionStorageProvider: serviceLocator.subscriptionStorageProvider(),
            dataviewService: dataviewService,
            searchService: serviceLocator.searchService(),
            detailsService: detailsService,
            objectActionsService: serviceLocator.objectActionsService(),
            textService: serviceLocator.textService,
            groupsSubscriptionsHandler: serviceLocator.groupsSubscriptionsHandler(),
            setSubscriptionDataBuilder: SetSubscriptionDataBuilder(activeWorkspaceStorage: serviceLocator.activeWorkspaceStorage()),
            objectTypeProvider: serviceLocator.objectTypeProvider()
        )
        let controller = EditorSetHostingController(objectId: data.objectId, model: model)
        let navigationContext = NavigationContext(rootViewController: browser ?? controller)

        let router = EditorSetRouter(
            setDocument: setDocument,
            rootController: browser,
            navigationContext: navigationContext,
            createObjectModuleAssembly: modulesDI.createObject(),
            newSearchModuleAssembly: modulesDI.newSearch(),
            editorPageCoordinator: coordinatorsDI.editorPage().make(browserController: browser),
            objectSettingCoordinator: coordinatorsDI.objectSettings().make(browserController: browser),
            relationValueCoordinator: coordinatorsDI.relationValue().make(),
            objectCoverPickerModuleAssembly: modulesDI.objectCoverPicker(),
            objectIconPickerModuleAssembly: modulesDI.objectIconPicker(),
            setViewSettingsCoordinatorAssembly: coordinatorsDI.setViewSettings(),
            setSortsListCoordinatorAssembly: coordinatorsDI.setSortsList(),
            setFiltersListCoordinatorAssembly: coordinatorsDI.setFiltersList(),
            setViewSettingsImagePreviewModuleAssembly: modulesDI.setViewSettingsImagePreview(),
            setViewSettingsGroupByModuleAssembly: modulesDI.setViewSettingsGroupByView(),
            editorSetRelationsCoordinatorAssembly: coordinatorsDI.setRelations(),
            setViewPickerCoordinatorAssembly: coordinatorsDI.setViewPicker(),
            toastPresenter: uiHelpersDI.toastPresenter(using: browser),
            alertHelper: AlertHelper(viewController: controller),
            setObjectCreationSettingsCoordinator: coordinatorsDI.setObjectCreationSettings().make(with: navigationContext)
        )
        
        setupHeaderModelActions(headerModel: headerModel, using: router)
        
        model.setup(router: router)
        
        return (controller, router)
    }
    
    // MARK: - Page
    
    func buildPageModule(
        browser: EditorBrowserController?,
        data: EditorPageObject
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
        
        let document = serviceLocator.documentService().document(
            objectId: data.objectId,
            forPreview: data.isOpenedForPreview
        )
        let navigationContext = NavigationContext(rootViewController: browser ?? controller)
        let router = EditorRouter(
            rootController: browser,
            viewController: controller,
            navigationContext: navigationContext,
            document: document,
            addNewRelationCoordinator: coordinatorsDI.addNewRelation().make(),
            templatesCoordinator: coordinatorsDI.templates().make(viewController: controller),
            setObjectCreationSettingsCoordinator: coordinatorsDI.setObjectCreationSettings().make(with: navigationContext),
            urlOpener: uiHelpersDI.urlOpener(),
            relationValueCoordinator: coordinatorsDI.relationValue().make(),
            editorPageCoordinator: coordinatorsDI.editorPage().make(browserController: browser),
            linkToObjectCoordinator: coordinatorsDI.linkToObject().make(browserController: browser),
            objectCoverPickerModuleAssembly: modulesDI.objectCoverPicker(),
            objectIconPickerModuleAssembly: modulesDI.objectIconPicker(),
            objectSettingCoordinator: coordinatorsDI.objectSettings().make(browserController: browser),
            searchModuleAssembly: modulesDI.search(),
            toastPresenter: uiHelpersDI.toastPresenter(using: browser),
            codeLanguageListModuleAssembly: modulesDI.codeLanguageList(),
            newSearchModuleAssembly: modulesDI.newSearch(),
            textIconPickerModuleAssembly: modulesDI.textIconPicker(),
            alertHelper: AlertHelper(viewController: controller),
            templateService: serviceLocator.templatesService
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
            configuration: EditorPageViewModelConfiguration(
                isOpenedForPreview: data.isOpenedForPreview,
                usecase: data.usecase
            )
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
        configuration: EditorPageViewModelConfiguration
    ) -> EditorPageViewModel {
        let modelsHolder = EditorMainItemModelsHolder()
        let markupChanger = BlockMarkupChanger(document: document)
        let focusSubjectHolder = FocusSubjectsHolder()

        let cursorManager = EditorCursorManager(focusSubjectHolder: focusSubjectHolder)
        let listService = serviceLocator.blockListService()
        let blockActionService = BlockActionService(
            documentId: document.objectId,
            listService: listService,
            singleService: serviceLocator.blockActionsServiceSingle(),
            objectActionService: serviceLocator.objectActionsService(),
            modelsHolder: modelsHolder,
            bookmarkService: serviceLocator.bookmarkService(),
            cursorManager: cursorManager,
            objectTypeProvider: serviceLocator.objectTypeProvider()
        )
        let keyboardHandler = KeyboardActionHandler(
            documentId: document.objectId,
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
            blockTableService: blockTableService,
            fileService: serviceLocator.fileService(), 
            objectService: serviceLocator.objectActionsService()
        )

        let pasteboardMiddlewareService = PasteboardMiddleService(document: document)
        let pasteboardHelper = PasteboardHelper()
        let pasteboardService = PasteboardService(document: document,
                                                  pasteboardHelper: pasteboardHelper,
                                                  pasteboardMiddlewareService: pasteboardMiddlewareService)
        
        let blocksStateManager = EditorPageBlocksStateManager(
            document: document,
            modelsHolder: modelsHolder,
            blocksSelectionOverlayViewModel: blocksSelectionOverlayViewModel,
            blockActionsServiceSingle: serviceLocator.blockActionsServiceSingle(),
            toastPresenter: uiHelpersDI.toastPresenter(using: browser),
            actionHandler: actionHandler,
            pasteboardService: pasteboardService,
            router: router,
            initialEditingState: configuration.isOpenedForPreview ? .readonly(state: .locked) : .editing,
            viewInput: viewInput,
            bottomNavigationManager: bottomNavigationManager,
            documentsProvider: serviceLocator.documentsProvider
        )
        
        let accessoryState = AccessoryViewBuilder.accessoryState(
            actionHandler: actionHandler,
            router: router,
            pasteboardService: pasteboardService,
            document: document,
            onShowStyleMenu: blocksStateManager.didSelectStyleSelection(infos:),
            onBlockSelection: actionHandler.selectBlock(info:),
            pageService: serviceLocator.pageRepository(),
            linkToObjectCoordinator: coordinatorsDI.linkToObject().make(browserController: browser),
            cursorManager: cursorManager
        )
        
        let markdownListener = MarkdownListenerImpl(
            internalListeners: [
                BeginingOfTextMarkdownListener(),
                InlineMarkdownListener()
            ]
        )
        
        let blockDelegate = BlockDelegateImpl(
            viewInput: viewInput,
            accessoryState: accessoryState.0,
            cursorManager: cursorManager
        )
        let headerModel = ObjectHeaderViewModel(
            document: document,
            configuration: configuration,
            interactor: serviceLocator.objectHeaderInteractor(objectId: document.objectId)
        )
        setupHeaderModelActions(headerModel: headerModel, using: router)

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
            pageService: serviceLocator.pageRepository(),
            linkToObjectCoordinator: coordinatorsDI.linkToObject().make(browserController: browser)
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
            pageService: serviceLocator.pageRepository(),
            detailsService: serviceLocator.detailsService(objectId: document.objectId),
            audioSessionService: serviceLocator.audioSessionService(),
            infoContainer: document.infoContainer,
            tableService: blockTableService
        )

        actionHandler.blockSelectionHandler = blocksStateManager

        blocksStateManager.blocksSelectionOverlayViewModel = blocksSelectionOverlayViewModel
        blocksStateManager.blocksOptionViewModel = blocksOptionViewModel
        
        let editorPageTemplatesHandler = EditorPageTemplatesHandler()
        
        let viewModel = EditorPageViewModel(
            document: document,
            viewInput: viewInput,
            blockDelegate: blockDelegate,
            router: router,
            modelsHolder: modelsHolder,
            blockBuilder: blocksConverter,
            actionHandler: actionHandler,
            headerModel: headerModel,
            blockActionsService: serviceLocator.blockActionsServiceSingle(),
            blocksStateManager: blocksStateManager,
            cursorManager: cursorManager,
            objectActionsService: serviceLocator.objectActionsService(),
            searchService: serviceLocator.searchService(),
            editorPageTemplatesHandler: editorPageTemplatesHandler,
            accountManager: serviceLocator.accountManager(),
            configuration: configuration,
            templatesSubscriptionService: serviceLocator.templatesSubscription(),
            activeWorkpaceStorage: serviceLocator.activeWorkspaceStorage()
        )
        
        accessoryState.1.onTypeTap = { [weak viewModel] in
            viewModel?.onChangeType(type: $0)
        }
        
        return viewModel
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
    
    private func favoritesModule(browser: EditorBrowserController?, output: WidgetObjectListCommonModuleOutput?) -> (UIViewController, EditorPageOpenRouterProtocol?) {
        let moduleAssembly = modulesDI.widgetObjectList()
        let bottomPanelManager = BrowserBottomPanelManager(browser: browser)
        let module = moduleAssembly.makeFavorites(bottomPanelManager: bottomPanelManager, output: output)
        return (module, nil)
    }
    
    private func recentEditModule(browser: EditorBrowserController?, output: WidgetObjectListCommonModuleOutput?) -> (UIViewController, EditorPageOpenRouterProtocol?) {
        let moduleAssembly = modulesDI.widgetObjectList()
        let bottomPanelManager = BrowserBottomPanelManager(browser: browser)
        let module = moduleAssembly.makerecentEdit(bottomPanelManager: bottomPanelManager, output: output)
        return (module, nil)
    }
    
    private func recentOpenModule(browser: EditorBrowserController?, output: WidgetObjectListCommonModuleOutput?) -> (UIViewController, EditorPageOpenRouterProtocol?) {
        let moduleAssembly = modulesDI.widgetObjectList()
        let bottomPanelManager = BrowserBottomPanelManager(browser: browser)
        let module = moduleAssembly.makeRecentOpen(bottomPanelManager: bottomPanelManager, output: output)
        return (module, nil)
    }

    private func setsModule(browser: EditorBrowserController?, output: WidgetObjectListCommonModuleOutput?) -> (UIViewController, EditorPageOpenRouterProtocol?) {
        let moduleAssembly = modulesDI.widgetObjectList()
        let bottomPanelManager = BrowserBottomPanelManager(browser: browser)
        let module = moduleAssembly.makeSets(bottomPanelManager: bottomPanelManager, output: output)
        return (module, nil)
    }
    
    private func collectionsModule(browser: EditorBrowserController?, output: WidgetObjectListCommonModuleOutput?) -> (UIViewController, EditorPageOpenRouterProtocol?) {
        let moduleAssembly = modulesDI.widgetObjectList()
        let bottomPanelManager = BrowserBottomPanelManager(browser: browser)
        let module = moduleAssembly.makeCollections(bottomPanelManager: bottomPanelManager, output: output)
        return (module, nil)
    }

    private func binModule(browser: EditorBrowserController?, output: WidgetObjectListCommonModuleOutput?) -> (UIViewController, EditorPageOpenRouterProtocol?) {
        let moduleAssembly = modulesDI.widgetObjectList()
        let bottomPanelManager = BrowserBottomPanelManager(browser: browser)
        let module = moduleAssembly.makeBin(bottomPanelManager: bottomPanelManager, output: output)
        return (module, nil)
    }
    
    private func setupHeaderModelActions(headerModel: ObjectHeaderViewModel, using router: ObjectHeaderRouterProtocol) {
        headerModel.onCoverPickerTap = { [weak router] args in
            router?.showCoverPicker(document: args.0, onCoverAction: args.1)
        }
        
        headerModel.onIconPickerTap = { [weak router] args in
            router?.showIconPicker(document: args.0, onIconAction: args.1)
        }
    }
}
