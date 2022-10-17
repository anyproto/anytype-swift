import Foundation
import BlocksModels
import Combine

class MarkupEditorViewModelAdapter: MarkupViewModelAdapterProtocol {
    
    @Published private var selectedMarkups: [MarkupType: AttributeState] = [:]
    @Published private var selectedHorizontalAlignment: [LayoutAlignment: AttributeState] = [:]
    
    private let blockIds: [BlockId]
    private let actionHandler: BlockActionHandlerProtocol
    private let document: BaseDocumentProtocol
    
    private var subscription: AnyCancellable?
    
    init(
        document: BaseDocumentProtocol,
        blockIds: [BlockId],
        actionHandler: BlockActionHandlerProtocol
    ) {
        self.document = document
        self.blockIds = blockIds
        self.actionHandler = actionHandler
        
        self.subscription = document.updatePublisher.sink { [weak self] _ in
            self?.updateState()
        }
        updateState()
    }
    
    // MARK: - MarkupViewModelAdapterProtocol
    
    var selectedMarkupsPublisher: AnyPublisher<[MarkupType : AttributeState], Never> {
        $selectedMarkups.eraseToAnyPublisher()
    }
    
    var selectedHorizontalAlignmentPublisher: AnyPublisher<[BlocksModels.LayoutAlignment : AttributeState], Never> {
        $selectedHorizontalAlignment.eraseToAnyPublisher()
    }
    
    func onMarkupAction(_ action: MarkupViewModelAction) {
        switch action {
        case let .selectAlignment(alignment):
            actionHandler.setAlignment(alignment, blockIds: blockIds)
        case let .toggleMarkup(markup):
            actionHandler.changeMarkup(blockIds: blockIds, markType: markup)
//            actionHandler.toggleWholeBlockMarkup(markup, blockId: blockId)
        }
//        updateState()
    }
    
    private func updateState() {
        let info = blockIds.compactMap { document.infoContainer.get(id: $0) }
    
        selectedMarkups = AttributeState.markupAttributes(from: info)
        selectedHorizontalAlignment =  AttributeState.alignmentAttributes(from: info)
    }
}
