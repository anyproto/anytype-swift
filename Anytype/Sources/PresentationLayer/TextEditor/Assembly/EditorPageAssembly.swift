import BlocksModels
import UIKit

final class EditorAssembly {
    private weak var browser: EditorBrowserController!
    
    init(browser: EditorBrowserController) {
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
            let module = buildPageModule(pageId: data.pageId)
            module.0.browserViewInput = editorBrowserViewInput
            return module
        case .set:
            return buildSetModule(pageId: data.pageId)
        }
    }
    
    // MARK: - Set
    private func buildSetModule(pageId: BlockId) -> (EditorSetHostingController, EditorRouterProtocol) {
        let document = BaseDocument(objectId: pageId)
        let model = EditorSetViewModel(document: document)
        let controller = EditorSetHostingController(objectId: pageId, model: model)
        
        let router = EditorRouter(
            rootController: browser,
            viewController: controller,
            document: document,
            assembly: self
        )
        
        model.setup(router: router)
        
        return (controller, router)
    }
    
    // MARK: - Page
    
    private func buildPageModule(pageId: BlockId) -> (EditorPageController, EditorRouterProtocol) {
        let blocksSelectionOverlayView = buildBlocksSelectionOverlayView()

        let controller = EditorPageController(blocksSelectionOverlayView: blocksSelectionOverlayView)
        let document = BaseDocument(objectId: pageId)
        let router = EditorRouter(
            rootController: browser,
            viewController: controller,
            document: document,
            assembly: self
        )

        let viewModel = buildViewModel(
            viewInput: controller,
            document: document,
            router: router,
            blocksSelectionOverlayViewModel: blocksSelectionOverlayView.viewModel
        )

        controller.viewModel = viewModel
        
        return (controller, router)
    }
    
    private func buildViewModel(
        viewInput: EditorPageViewInput,
        document: BaseDocumentProtocol,
        router: EditorRouter,
        blocksSelectionOverlayViewModel: BlocksSelectionOverlayViewModel
    ) -> EditorPageViewModel {                
        let modelsHolder = EditorMainItemModelsHolder()
        
        let markupChanger = BlockMarkupChanger(infoContainer: document.infoContainer)
        let cursorManager = EditorCursorManager()
        let listService = BlockListService(contextId: document.objectId)
        let blockActionService = BlockActionService(
            documentId: document.objectId,
            listService: listService,
            modelsHolder: modelsHolder,
            cursorManager: cursorManager
        )
        let keyboardHandler = KeyboardActionHandler(
            service: blockActionService,
            listService: listService,
            toggleStorage: ToggleStorage.shared,
            container: document.infoContainer
        )
        
        let actionHandler = BlockActionHandler(
            document: document,
            markupChanger: markupChanger,
            service: blockActionService,
            listService: listService,
            keyboardHandler: keyboardHandler
        )
        
        let accessoryState = AccessoryViewBuilder.accessoryState(
            actionHandler: actionHandler,
            router: router,
            document: document
        )
        
        let markdownListener = MarkdownListenerImpl()
        
        let blockDelegate = BlockDelegateImpl(
            viewInput: viewInput,
            accessoryState: accessoryState
        )
        
        let blocksConverter = BlockViewModelBuilder(
            document: document,
            handler: actionHandler,
            router: router,
            delegate: blockDelegate,
            markdownListener: markdownListener
        )
         
        let wholeBlockMarkupViewModel = MarkupViewModel(
            actionHandler: actionHandler
        )
        
        let headerBuilder = ObjectHeaderBuilder(document: document, router: router)
        let blockActionsServiceSingle = ServiceLocator.shared.blockActionsServiceSingle()

        let blocksStateManager = EditorPageBlocksStateManager(
            document: document,
            modelsHolder: modelsHolder,
            blocksSelectionOverlayViewModel: blocksSelectionOverlayViewModel,
            blockActionsServiceSingle: blockActionsServiceSingle,
            actionHandler: actionHandler,
            router: router
        )

        actionHandler.blockSelectionHandler = blocksStateManager
        
        return EditorPageViewModel(
            document: document,
            viewInput: viewInput,
            blockDelegate: blockDelegate,
            router: router,
            modelsHolder: modelsHolder,
            blockBuilder: blocksConverter,
            actionHandler: actionHandler,
            wholeBlockMarkupViewModel: wholeBlockMarkupViewModel,
            headerBuilder: headerBuilder,
            blockActionsService: blockActionsServiceSingle,
            blocksStateManager: blocksStateManager,
            cursorManager: cursorManager
        )
    }

    private func buildBlocksSelectionOverlayView() -> BlocksSelectionOverlayView {
        let blocksOptionViewModel = BlocksOptionViewModel()
        let blocksOptionView = BlocksOptionView(viewModel: blocksOptionViewModel)
        let blocksSelectionOverlayViewModel = BlocksSelectionOverlayViewModel()

        blocksSelectionOverlayViewModel.blocksOptionViewModel = blocksOptionViewModel

        return BlocksSelectionOverlayView(
            viewModel: blocksSelectionOverlayViewModel,
            blocksOptionView: blocksOptionView
        )
    }
}
