import BlocksModels
import UIKit

final class EditorAssembly {
    private weak var browser: EditorBrowserController!
    
    init(browser: EditorBrowserController) {
        self.browser = browser
    }
    
    func buildEditorController(pageId: BlockId, type: EditorViewType) -> UIViewController {
        buildEditorModule(pageId: pageId, type: type).0
    }
    
    func buildEditorModule(pageId: BlockId, type: EditorViewType) -> (UIViewController, EditorRouterProtocol) {
        switch type {
        case .page:
            return buildPageModule(pageId: pageId)
        case .set:
            return buildSetModule(pageId: pageId)
        }
    }
    
    // MARK: - Set
    private func buildSetModule(pageId: BlockId) -> (EditorSetHostingController, EditorRouterProtocol) {
        let document = BaseDocument(objectId: pageId)
        let model = EditorSetViewModel(document: document)
        let controller = EditorSetHostingController(documentId: pageId, model: model)
        
        let router = EditorRouter(
            rootController: browser,
            viewController: controller,
            document: document,
            assembly: self
        )
        
        model.router = router
        
        return (controller, router)
    }
    
    // MARK: - Page
    
    private func buildPageModule(pageId: BlockId) -> (EditorPageController, EditorRouterProtocol) {
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
