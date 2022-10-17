import Foundation
import BlocksModels
import Combine

class MarkupSimpleTableViewModelAdapter: MarkupViewModelAdapterProtocol {
    
    @Published private var selectedMarkups: [MarkupType: AttributeState]
    @Published private var selectedHorizontalAlignment: [LayoutAlignment: AttributeState]
    
    private let blockIds: [BlockId]
    private let actionHandler: BlockActionHandlerProtocol
    
    init(
        selectedMarkups: [MarkupType: AttributeState],
        selectedHorizontalAlignment: [LayoutAlignment: AttributeState],
        blockIds: [BlockId],
        actionHandler: BlockActionHandlerProtocol
    ) {
        self.selectedMarkups = selectedMarkups
        self.selectedHorizontalAlignment = selectedHorizontalAlignment
        self.blockIds = blockIds
        self.actionHandler = actionHandler
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
        case .toggleMarkup(let markupType):
            actionHandler.changeMarkup(blockIds: blockIds, markType: markupType)
        case .selectAlignment(let layoutAlignment):
            actionHandler.setAlignment(layoutAlignment, blockIds: blockIds)
        }
    }
}
