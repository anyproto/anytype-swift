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
    func buildStateModel(data: EditorPageObject, output: EditorPageModuleOutput?, showHeader: Bool) -> EditorPageViewState
}

@MainActor
final class EditorPageModuleAssembly: EditorPageModuleAssemblyProtocol {
    
    @Injected(\.documentService)
    private var documentService: OpenedDocumentsProviderProtocol
    
    nonisolated init() {}
    
    func buildStateModel(data: EditorPageObject, output: EditorPageModuleOutput?, showHeader: Bool) -> EditorPageViewState {
        let simpleTableMenuViewModel = SimpleTableMenuViewModel()
        let blocksOptionViewModel = SelectionOptionsViewModel(itemProvider: nil)
        
        let blocksSelectionOverlayView = buildBlocksSelectionOverlayView(
            simleTableMenuViewModel: simpleTableMenuViewModel,
            blockOptionsViewViewModel: blocksOptionViewModel
        )

        let bottomNavigationManager = EditorBottomNavigationManager()
        
        let controller = EditorPageController(
            blocksSelectionOverlayView: blocksSelectionOverlayView,
            bottomNavigationManager: bottomNavigationManager,
            showHeader: showHeader
        )

        let document = documentService.document(
            objectId: data.objectId,
            forPreview: data.isOpenedForPreview
        )
        let router = EditorRouter(
            viewController: controller,
            document: document,
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
                blockId: data.blockId,
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
        let blockActionService = BlockActionService(
            documentId: document.objectId,
            modelsHolder: modelsHolder,
            cursorManager: cursorManager
        )
        let keyboardHandler = KeyboardActionHandler(
            documentId: document.objectId,
            spaceId: document.spaceId,
            service: blockActionService,
            toggleStorage: ToggleStorage.shared,
            container: document.infoContainer,
            modelsHolder: modelsHolder,
            editorCollectionController: .init(viewInput: viewInput)
        )
        
        let actionHandler = BlockActionHandler(
            document: document,
            markupChanger: markupChanger,
            service: blockActionService
        )
        
        let blocksStateManager = EditorPageBlocksStateManager(
            document: document,
            modelsHolder: modelsHolder,
            blocksSelectionOverlayViewModel: blocksSelectionOverlayViewModel,
            actionHandler: actionHandler,
            router: router,
            initialEditingState: configuration.isOpenedForPreview ? .readonly : .editing,
            viewInput: viewInput,
            bottomNavigationManager: bottomNavigationManager
        )
 
        let accessoryState = AccessoryViewBuilder.accessoryState(
            actionHandler: actionHandler,
            router: router,
            document: document
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
        
        let responderScrollViewHelper = ResponderScrollViewHelper(scrollView: scrollView)
        
        let simpleTableDependenciesBuilder = SimpleTableDependenciesBuilder(
            document: document,
            router: router,
            handler: actionHandler,
            markdownListener: markdownListener,
            focusSubjectHolder: focusSubjectHolder,
            mainEditorSelectionManager: blocksStateManager,
            responderScrollViewHelper: responderScrollViewHelper,
            accessoryStateManager: accessoryState.0,
            moduleOutput: output
        )
        
        let slashMenuActionHandler = SlashMenuActionHandler(
            document: document,
            actionHandler: actionHandler,
            router: router,
            cursorManager: cursorManager
        )
        
        let blocksConverter = BlockViewModelBuilder(
            document: document,
            handler: actionHandler,
            router: router,
            markdownListener: markdownListener,
            simpleTableDependenciesBuilder: simpleTableDependenciesBuilder,
            subjectsHolder: focusSubjectHolder,
            infoContainer: document.infoContainer,
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
            editorPageTemplatesHandler: editorPageTemplatesHandler,
            configuration: configuration,
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

