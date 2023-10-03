import Foundation
import SwiftUI
import Services

protocol EditorPageModuleAssemblyProtocol: AnyObject {
    @MainActor
    func make(data: EditorPageObject, output: EditorPageModuleOutput?) -> AnyView 
}

final class EditorPageModuleAssembly: EditorPageModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    // TODO: Delete coordinator dependency
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
    
    // MARK: - EditorPageModuleAssemblyProtocol
    
    @MainActor
    func make(data: EditorPageObject, output: EditorPageModuleOutput?) -> AnyView {
        let simpleTableMenuViewModel = SimpleTableMenuViewModel()
        let blocksOptionViewModel = SelectionOptionsViewModel(itemProvider: nil)

        let blocksSelectionOverlayView = buildBlocksSelectionOverlayView(
            simleTableMenuViewModel: simpleTableMenuViewModel,
            blockOptionsViewViewModel: blocksOptionViewModel
        )
        
        let environmentBridge = EditorPageViewEnvironmentBridge()
        let bottomNavigationManager = EditorBottomNavigationManager(browser: nil, environmentBridge: environmentBridge)
        
        let controller = EditorPageController(
            blocksSelectionOverlayView: blocksSelectionOverlayView,
            bottomNavigationManager: bottomNavigationManager,
            browserViewInput: nil
        )
        let document = BaseDocument(objectId: data.objectId, forPreview: data.isOpenedForPreview)
        let navigationContext = NavigationContext(rootViewController: controller)
        let router = EditorRouter(
            rootController: nil,
            viewController: controller,
            navigationContext: navigationContext,
            document: document,
            addNewRelationCoordinator: coordinatorsDI.addNewRelation().make(),
            templatesCoordinator: coordinatorsDI.templates().make(viewController: controller),
            setObjectCreationSettingsCoordinator: coordinatorsDI.setObjectCreationSettings().make(
                with: .creation,
                navigationContext: navigationContext
            ),
            urlOpener: uiHelpersDI.urlOpener(),
            relationValueCoordinator: coordinatorsDI.relationValue().make(),
            editorPageCoordinator: coordinatorsDI.editorPage().make(browserController: nil),
            linkToObjectCoordinator: coordinatorsDI.linkToObject().make(browserController: nil),
            objectCoverPickerModuleAssembly: modulesDI.objectCoverPicker(),
            objectIconPickerModuleAssembly: modulesDI.objectIconPicker(),
            objectSettingCoordinator: coordinatorsDI.objectSettings().make(browserController: nil),
            searchModuleAssembly: modulesDI.search(),
            toastPresenter: uiHelpersDI.toastPresenter(using: nil),
            codeLanguageListModuleAssembly: modulesDI.codeLanguageList(),
            newSearchModuleAssembly: modulesDI.newSearch(),
            textIconPickerModuleAssembly: modulesDI.textIconPicker(),
            alertHelper: AlertHelper(viewController: controller),
            pageService: serviceLocator.pageRepository(),
            templateService: serviceLocator.templatesService
        )

        let viewModel = buildViewModel(
            browser: nil,
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
                shouldShowTemplateSelection: data.shouldShowTemplatesOptions,
                usecase: data.usecase
            )
        )

        controller.viewModel = viewModel
        
        let view = EditorPageView(editorPageController: controller, environmentBridge: environmentBridge)
            .eraseToAnyView()
        
        return view
    }
    
    // MARK: - Private
    
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
            fileService: serviceLocator.fileService()
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
            bottomNavigationManager: bottomNavigationManager
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
            accessoryState: accessoryState,
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
            tableService: blockTableService,
            objectTypeProvider: serviceLocator.objectTypeProvider()
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
            blockActionsService: serviceLocator.blockActionsServiceSingle(),
            blocksStateManager: blocksStateManager,
            cursorManager: cursorManager,
            objectActionsService: serviceLocator.objectActionsService(),
            searchService: serviceLocator.searchService(),
            editorPageTemplatesHandler: editorPageTemplatesHandler,
            accountManager: serviceLocator.accountManager(),
            configuration: configuration
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
    
    private func setupHeaderModelActions(headerModel: ObjectHeaderViewModel, using router: ObjectHeaderRouterProtocol) {
        headerModel.onCoverPickerTap = { [weak router] args in
            router?.showCoverPicker(document: args.0, onCoverAction: args.1)
        }
        
        headerModel.onIconPickerTap = { [weak router] args in
            router?.showIconPicker(document: args.0, onIconAction: args.1)
        }
    }
}
