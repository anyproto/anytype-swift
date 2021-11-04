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
        
        let blockActionHandler = BlockActionHandler(
            modelsHolder: modelsHolder,
            document: document,
            markupChanger: markupChanger
        )
        
        let editorBlockActionHandler = EditorActionHandler(
            document: document,
            blockActionHandler: blockActionHandler,
            router: router
        )
        
        markupChanger.handler = editorBlockActionHandler
        
        let accessoryDelegate = AccessoryViewBuilder.accessoryDelegate (
            actionHandler: editorBlockActionHandler,
            router: router,
            document: document
        )
        
        let blockDelegate = BlockDelegateImpl(
            viewInput: viewInput,
            accessoryDelegate: accessoryDelegate
        )
        
        let blocksConverter = BlockViewModelBuilder(
            document: document,
            editorActionHandler: editorBlockActionHandler,
            router: router,
            delegate: blockDelegate
        )
         
        let wholeBlockMarkupViewModel = MarkupViewModel(
            actionHandler: editorBlockActionHandler,
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
            blockActionHandler: editorBlockActionHandler,
            wholeBlockMarkupViewModel: wholeBlockMarkupViewModel,
            headerBuilder: headerBuilder,
            blockActionsService: BlockActionsServiceSingle()
        )
    }
}
