import BlocksModels

final class EditorPageAssembly {
    private weak var browser: EditorBrowserController!
    
    init(browser: EditorBrowserController) {
        self.browser = browser
    }
    
    func buildEditorPage(pageId: BlockId) -> EditorPageController {
        buildEditorModule(pageId: pageId).0
    }
    
    func buildEditorModule(pageId: BlockId) -> (EditorPageController, EditorRouterProtocol) {
        let controller = EditorPageController()
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
            router: router
        )

        controller.viewModel = viewModel
        
        return (controller, router)
    }
    
    private func buildViewModel(
        viewInput: EditorPageViewInput,
        document: BaseDocumentProtocol,
        router: EditorRouter
    ) -> EditorPageViewModel {
        
        let objectSettinsViewModel = ObjectSettingsViewModel(
            objectId: document.objectId,
            detailsStorage: document.detailsStorage,
            objectDetailsService: ObjectDetailsService(
                objectId: document.objectId
            ),
            popScreenAction: router.goBack
        )
                
        let modelsHolder = BlockViewModelsHolder(
            objectId: document.objectId
        )
        
        let markupChanger = BlockMarkupChanger(
            blocksContainer: document.blocksContainer,
            detailsStorage: document.detailsStorage
        )
        
        
        let blockActionService = BlockActionService(documentId: document.objectId, modelsHolder: modelsHolder)
        let blockActionHandler = TextBlockActionHandler(
            contextId: document.objectId,
            service: blockActionService,
            modelsHolder: modelsHolder
        )
        
        let actionHandler = BlockActionHandler(
            document: document,
            markupChanger: markupChanger,
            service: blockActionService,
            actionHandler: blockActionHandler
        )
        
        let accessoryState = AccessoryViewBuilder.accessoryState(
            actionHandler: actionHandler,
            router: router,
            document: document
        )
        
        let markdownListener = MarkdownListenerImpl(handler: actionHandler, markupChanger: markupChanger)
        
        let blockDelegate = BlockDelegateImpl(
            viewInput: viewInput,
            accessoryState: accessoryState,
            markdownListener: markdownListener
        )
        
        let blocksConverter = BlockViewModelBuilder(
            document: document,
            handler: actionHandler,
            router: router,
            delegate: blockDelegate
        )
         
        let wholeBlockMarkupViewModel = MarkupViewModel(
            actionHandler: actionHandler,
            detailsStorage: document.detailsStorage
        )
        
        let headerBuilder = ObjectHeaderBuilder(
            settingsViewModel: objectSettinsViewModel,
            router: router
        )
        
        return EditorPageViewModel(
            document: document,
            viewInput: viewInput,
            blockDelegate: blockDelegate,
            objectSettinsViewModel: objectSettinsViewModel,
            router: router,
            modelsHolder: modelsHolder,
            blockBuilder: blocksConverter,
            actionHandler: actionHandler,
            wholeBlockMarkupViewModel: wholeBlockMarkupViewModel,
            headerBuilder: headerBuilder,
            blockActionsService: BlockActionsServiceSingle()
        )
    }
}
