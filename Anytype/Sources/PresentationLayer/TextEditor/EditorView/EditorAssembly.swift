import SwiftUI
import BlocksModels
import Combine

final class EditorAssembly {
    
    func documentView(blockId: BlockId) -> some View {
        EditorViewRepresentable(documentId: blockId).eraseToAnyView()
    }
    
    static func buildEditor(blockId: BlockId) -> DocumentEditorViewController {
        let controller = DocumentEditorViewController()
        let document = BaseDocument()
        let router = EditorRouter(viewController: controller, document: document)
        
        let viewModel = buildViewModel(
            blockId: blockId,
            viewInput: controller,
            document: document,
            router: router
        )
        
        controller.viewModel = viewModel
        
        return controller
    }
    
    private static func buildViewModel(
        blockId: BlockId,
        viewInput: DocumentEditorViewInput,
        document: BaseDocumentProtocol,
        router: EditorRouter
    ) -> DocumentEditorViewModel {
        
        let objectSettinsViewModel = ObjectSettingsViewModel(
            objectId: blockId,
            objectDetailsService: ObjectDetailsService(
                eventHandler: document.eventHandler,
                objectId: blockId
            )
        )
                
        let modelsHolder = ObjectContentViewModelsSharedHolder(objectId: blockId)
        
        let markupChanger = BlockMarkupChanger(
            document: document,
            documentId: blockId
        )
        
        let blockActionHandler = BlockActionHandler(
            documentId: blockId,
            modelsHolder: modelsHolder,
            document: document,
            markupChanger: markupChanger
        )
        
        let eventProcessor = EventProcessor(document: document, modelsHolder: modelsHolder)
        let editorBlockActionHandler = EditorActionHandler(
            document: document,
            blockActionHandler: blockActionHandler,
            eventProcessor: eventProcessor,
            router: router
        )
        
        markupChanger.handler = editorBlockActionHandler
        
        let blockDelegate = BlockDelegateImpl(
            viewInput: viewInput,
            document: document
        )
        
        let accessorySwitcher = AccessoryViewSwitcherBuilder()
            .accessoryViewSwitcher(actionHandler: editorBlockActionHandler, router: router)
        let blocksConverter = BlockViewModelBuilder(
            document: document,
            blockActionHandler: editorBlockActionHandler,
            router: router,
            delegate: blockDelegate,
            accessorySwitcher: accessorySwitcher
        )
        
        let wholeBlockMarkupViewModel = MarkupViewModel(actionHandler: editorBlockActionHandler)
        
        let headerBuilder = ObjectHeaderBuilder()
        
        return DocumentEditorViewModel(
            documentId: blockId,
            document: document,
            viewInput: viewInput,
            blockDelegate: blockDelegate,
            objectSettinsViewModel: objectSettinsViewModel,
            router: router,
            modelsHolder: modelsHolder,
            blockBuilder: blocksConverter,
            blockActionHandler: editorBlockActionHandler,
            wholeBlockMarkupViewModel: wholeBlockMarkupViewModel,
            headerBuilder: headerBuilder
        )
    }
}
