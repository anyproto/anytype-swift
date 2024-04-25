import Foundation
import SwiftUI
import Services

@MainActor
protocol EditorPageModuleInput {
    func showSettings(output: ObjectSettingsCoordinatorOutput?)
}

struct EditorPageModuleInputContainer: EditorPageModuleInput {
    weak var model: EditorPageViewModel?
    
    func showSettings(output: ObjectSettingsCoordinatorOutput?) {
        model?.showSettings(output: output)
    }
}

@MainActor
protocol EditorPageModuleAssemblyProtocol: AnyObject {
    func make(data: EditorPageObject, output: EditorPageModuleOutput?, showHeader: Bool) -> AnyView
}

@MainActor
final class EditorPageModuleAssembly: EditorPageModuleAssemblyProtocol {
    
    private let serviceLocator: ServiceLocator
    // TODO: Delete coordinator dependency
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

    func make(data: EditorPageObject, output: EditorPageModuleOutput?, showHeader: Bool) -> AnyView {
        return EditorPageView(
            stateModel: self.buildStateModel(data: data, output: output, showHeader: showHeader)
        ).eraseToAnyView()
    }
    
    // MARK: - Private
    
    private func buildStateModel(data: EditorPageObject, output: EditorPageModuleOutput?, showHeader: Bool) -> EditorPageViewState {
        let simpleTableMenuViewModel = SimpleTableMenuViewModel()
        let blocksOptionViewModel = SelectionOptionsViewModel(itemProvider: nil)
        
        let blocksSelectionOverlayView = buildBlocksSelectionOverlayView(
            simleTableMenuViewModel: simpleTableMenuViewModel,
            blockOptionsViewViewModel: blocksOptionViewModel
        )

        let bottomNavigationManager = EditorBottomNavigationManager()
        
        let networkId = serviceLocator.activeWorkspaceStorage().workspaceInfo.networkId
        let controller = EditorPageController(
            blocksSelectionOverlayView: blocksSelectionOverlayView,
            bottomNavigationManager: bottomNavigationManager, 
            syncStatusData: SyncStatusData(status: .unknown, networkId: networkId),
            keyboardListener: uiHelpersDI.keyboardListener,
            showHeader: showHeader
        )

        let document = serviceLocator.documentService().document(
            objectId: data.objectId,
            forPreview: data.isOpenedForPreview
        )
        let navigationContext = NavigationContext(rootViewController: controller)
        let router = EditorRouter(
            viewController: controller,
            navigationContext: navigationContext,
            document: document,
            addNewRelationCoordinator: coordinatorsDI.addNewRelation().make(),
            templatesCoordinator: coordinatorsDI.templates().make(viewController: controller),
            setObjectCreationSettingsCoordinator: coordinatorsDI.setObjectCreationSettings().make(with: navigationContext),
            urlOpener: uiHelpersDI.urlOpener(),
            objectSettingCoordinatorAssembly: coordinatorsDI.objectSettings(),
            toastPresenter: uiHelpersDI.toastPresenter(using: nil),
            objectTypeSearchModuleAssembly: modulesDI.objectTypeSearch(),
            templateService: serviceLocator.templatesService,
            output: output
        )

        let viewModel = buildViewModel(
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
            ),
            output: output
        )

        bottomNavigationManager.output = viewModel

        controller.viewModel = viewModel
        
        return EditorPageViewState(viewController: controller, model: viewModel)
    }
    
    private func buildViewModel(
        scrollView: UIScrollView,
        viewInput: EditorPageViewInput,
        document: BaseDocumentProtocol,
        router: EditorRouter,
        blocksOptionViewModel: SelectionOptionsViewModel,
        simpleTableMenuViewModel: SimpleTableMenuViewModel,
        blocksSelectionOverlayViewModel: BlocksSelectionOverlayViewModel,
        bottomNavigationManager: EditorBottomNavigationManagerProtocol,
        configuration: EditorPageViewModelConfiguration,
        output: EditorPageModuleOutput?
    ) -> EditorPageViewModel {
        let modelsHolder = EditorMainItemModelsHolder()
        let markupChanger = BlockMarkupChanger()
        let focusSubjectHolder = FocusSubjectsHolder()
        
        let cursorManager = EditorCursorManager(focusSubjectHolder: focusSubjectHolder)
        let blockService = serviceLocator.blockService()
        let blockActionService = BlockActionService(
            documentId: document.objectId,
            blockService: blockService,
            objectActionService: serviceLocator.objectActionsService(),
            textServiceHandler: serviceLocator.textServiceHandler(),
            modelsHolder: modelsHolder,
            bookmarkService: serviceLocator.bookmarkService(),
            fileService: serviceLocator.fileService(),
            cursorManager: cursorManager,
            objectTypeProvider: serviceLocator.objectTypeProvider()
        )
        let keyboardHandler = KeyboardActionHandler(
            documentId: document.objectId,
            spaceId: document.spaceId,
            service: blockActionService,
            blockService: blockService,
            toggleStorage: ToggleStorage.shared,
            container: document.infoContainer,
            modelsHolder: modelsHolder,
            editorCollectionController: .init(viewInput: viewInput)
        )
        
        let actionHandler = BlockActionHandler(
            document: document,
            markupChanger: markupChanger,
            service: blockActionService,
            blockService: blockService,
            blockTableService: serviceLocator.blockTableService(),
            fileService: serviceLocator.fileService(),
            objectService: serviceLocator.objectActionsService(),
            pasteboardBlockService: serviceLocator.pasteboardBlockService(),
            bookmarkService: serviceLocator.bookmarkService(),
            objectTypeProvider: serviceLocator.objectTypeProvider()
        )
        
        let pasteboardService = serviceLocator.pasteboardBlockDocumentService()
        let blocksStateManager = EditorPageBlocksStateManager(
            document: document,
            modelsHolder: modelsHolder,
            blocksSelectionOverlayViewModel: blocksSelectionOverlayViewModel,
            blockService: serviceLocator.blockService(),
            toastPresenter: uiHelpersDI.toastPresenter(),
            actionHandler: actionHandler,
            pasteboardService: pasteboardService,
            router: router,
            initialEditingState: configuration.isOpenedForPreview ? .readonly : .editing,
            viewInput: viewInput,
            bottomNavigationManager: bottomNavigationManager,
            documentsProvider: serviceLocator.documentsProvider
        )
 
        let accessoryState = AccessoryViewBuilder.accessoryState(
            actionHandler: actionHandler,
            router: router,
            document: document,
            typesService: serviceLocator.typesService()
        )
        
        let markdownListener = MarkdownListenerImpl(
            internalListeners: [
                BeginingOfTextMarkdownListener(),
                InlineMarkdownListener()
            ]
        )
        
        let headerModel = ObjectHeaderViewModel(
            document: document,
            targetObjectId: document.objectId,
            configuration: configuration,
            output: output
        )
        setupHeaderModelActions(headerModel: headerModel, using: router)
        
        let responderScrollViewHelper = ResponderScrollViewHelper(scrollView: scrollView, keyboardListener: uiHelpersDI.keyboardListener)
        
        let simpleTableDependenciesBuilder = SimpleTableDependenciesBuilder(
            document: document,
            router: router,
            handler: actionHandler,
            pasteboardService: pasteboardService,
            markdownListener: markdownListener,
            focusSubjectHolder: focusSubjectHolder,
            mainEditorSelectionManager: blocksStateManager,
            responderScrollViewHelper: responderScrollViewHelper,
            defaultObjectService: serviceLocator.defaultObjectCreationService(),
            typesService: serviceLocator.typesService(),
            accessoryStateManager: accessoryState.0,
            tableService: serviceLocator.blockTableService()
        )
        
        let slashMenuActionHandler = SlashMenuActionHandler(
            document: document,
            actionHandler: actionHandler,
            router: router,
            pasteboardService: pasteboardService,
            cursorManager: cursorManager
        )
        
        let blocksConverter = BlockViewModelBuilder(
            document: document,
            handler: actionHandler,
            pasteboardService: pasteboardService,
            router: router,
            markdownListener: markdownListener,
            simpleTableDependenciesBuilder: simpleTableDependenciesBuilder,
            subjectsHolder: focusSubjectHolder,
            detailsService: serviceLocator.detailsService(),
            audioSessionService: serviceLocator.audioSessionService(),
            infoContainer: document.infoContainer,
            tableService: serviceLocator.blockTableService(),
            objectTypeProvider: serviceLocator.objectTypeProvider(),
            modelsHolder: modelsHolder,
            blockCollectionController: .init(viewInput: viewInput),
            accessoryStateManager: accessoryState.0,
            cursorManager: cursorManager,
            keyboardActionHandler: keyboardHandler,
            markupChanger: BlockMarkupChanger(),
            slashMenuActionHandler: slashMenuActionHandler,
            editorPageBlocksStateManager: blocksStateManager,
            output: output
        )
        
        blocksStateManager.blocksSelectionOverlayViewModel = blocksSelectionOverlayViewModel
        blocksStateManager.blocksOptionViewModel = blocksOptionViewModel
        
        let editorPageTemplatesHandler = EditorPageTemplatesHandler()
        
        let viewModel = EditorPageViewModel(
            document: document,
            viewInput: viewInput,
            router: router,
            modelsHolder: modelsHolder,
            blockBuilder: blocksConverter,
            actionHandler: actionHandler,
            headerModel: headerModel,
            blocksStateManager: blocksStateManager,
            cursorManager: cursorManager,
            objectActionsService: serviceLocator.objectActionsService(),
            searchService: serviceLocator.searchService(),
            editorPageTemplatesHandler: editorPageTemplatesHandler,
            configuration: configuration,
            templatesSubscriptionService: serviceLocator.templatesSubscription(),
            activeWorkspaceStorage: serviceLocator.activeWorkspaceStorage(),
            objectTypeProvider: serviceLocator.objectTypeProvider(),
            output: output
        )

        accessoryState.1.onTypeSelected = { [weak viewModel] typeSelection in
            Task {
                try await viewModel?.onChangeType(typeSelection: typeSelection)
            }
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
    
    private func setupHeaderModelActions(headerModel: ObjectHeaderViewModel, using router: ObjectHeaderRouterProtocol) {
        headerModel.onIconPickerTap = { [weak router] document in
            router?.showIconPicker(document: document)
        }
    }
}

