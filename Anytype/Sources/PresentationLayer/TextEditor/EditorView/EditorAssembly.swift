import SwiftUI
import BlocksModels
import Combine

final class EditorAssembly {
    
    func documentView(blockId: BlockId) -> some View {
        EditorViewRepresentable(documentId: blockId).eraseToAnyView()
    }
    
    static func build(blockId: BlockId) -> DocumentEditorViewController {
        let controller = DocumentEditorViewController()
        let router = EditorRouter(viewController: controller)
        
        let viewModel = buildViewModel(blockId: blockId, viewInput: controller, router: router)
        
        controller.viewModel = viewModel
        
        return controller
    }
    
    private static func buildViewModel(
        blockId: BlockId, viewInput: EditorModuleDocumentViewInput, router: EditorRouter
    ) -> DocumentEditorViewModel {
        let document: BaseDocumentProtocol = BaseDocument()
        
        let settingsModel = DocumentSettingsViewModel(activeModel: document.defaultDetailsActiveModel)
        let detailsViewModel = DocumentDetailsViewModel {
            viewInput.updateHeader()
        }
        
        let selectionHandler = EditorSelectionHandler()
        let modelsHolder = SharedBlockViewModelsHolder()
        
        let blockActionHandler = BlockActionHandler(
            documentId: blockId,
            modelsHolder: modelsHolder,
            selectionHandler: selectionHandler,
            document: document,
            router: router
        )
        
        let editorBlockActionHandler = EditorActionHandler(
            document: document,
            modelsHolder: modelsHolder,
            blockActionHandler: blockActionHandler
        )
        
        let blockDelegate = BlockDelegateImpl(
            viewInput: viewInput,
            document: document
        )
        
        let blocksConverter = BlockViewModelBuilder(
            document: document,
            blockActionHandler: editorBlockActionHandler,
            router: router,
            delegate: blockDelegate, mentionsConfigurator: MentionsTextViewConfigurator(didSelectMention: { pageId in
                router.showPage(with: pageId)
            })
        )
        
        return DocumentEditorViewModel(
            documentId: blockId,
            document: document,
            viewInput: viewInput,
            blockDelegate: blockDelegate,
            settingsViewModel: settingsModel,
            detailsViewModel: detailsViewModel,
            selectionHandler: selectionHandler,
            router: router,
            modelsHolder: modelsHolder,
            blockBuilder: blocksConverter,
            blockActionHandler: editorBlockActionHandler
        )
    }
}
