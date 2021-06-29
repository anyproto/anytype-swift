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

        let selectionHandler = EditorSelectionHandler()
        let modelsHolder = SharedBlockViewModelsHolder()
        let updateElementsSubject = PassthroughSubject<Set<BlockId>, Never>()
        
        let blockActionHandler = BlockActionHandler(
            documentId: blockId,
            modelsHolder: modelsHolder,
            selectionHandler: selectionHandler,
            document: document,
            router: router,
            updateElementsSubject: updateElementsSubject
        )
        
        let editorBlockActionHandler = EditorActionHandler(
            document: document,
            modelsHolder: modelsHolder,
            blockActionHandler: blockActionHandler
        )
        
        let blocksConverter = CompoundViewModelConverter(
            document: document,
            blockActionHandler: editorBlockActionHandler
        )
        
        let blockDelegate = BlockDelegateImpl(
            viewInput: viewInput,
            document: document
        )
        
        return DocumentEditorViewModel(
            documentId: blockId,
            document: document,
            viewInput: viewInput,
            blockDelegate: blockDelegate,
            settingsViewModel: settingsModel,
            selectionHandler: selectionHandler,
            router: router,
            modelsHolder: modelsHolder,
            updateElementsSubject: updateElementsSubject,
            blocksConverter: blocksConverter,
            blockActionHandler: editorBlockActionHandler
        )
    }
}
