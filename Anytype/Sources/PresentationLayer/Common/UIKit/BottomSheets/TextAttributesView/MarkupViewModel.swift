import AnytypeCore
import BlocksModels
import Foundation
import Combine

final class MarkupViewModel: MarkupViewModelProtocol {
    weak var view: MarkupViewProtocol?

    private var cancellable: AnyCancellable? = nil
    
    private let blockIds: [BlockId]
    private let actionHandler: BlockActionHandlerProtocol
    private let document: BaseDocumentProtocol
    
    init(
        document: BaseDocumentProtocol,
        blockIds: [BlockId],
        actionHandler: BlockActionHandlerProtocol
    ) {
        self.document = document
        self.blockIds = blockIds
        self.actionHandler = actionHandler
    }

    private func subscribeToPublishers() {
        cancellable =  document.updatePublisher.sink { [weak self] _ in
            self?.updateState()
        }
    }
    
    private func updateState() {
        let info = blockIds.compactMap { document.infoContainer.get(id: $0) }
    
        displayCurrentState(
            selectedMarkups: AttributeState.markupAttributes(from: info),
            selectedHorizontalAlignment: AttributeState.alignmentAttributes(from: info)
        )
    }

    private func displayCurrentState(
        selectedMarkups: [MarkupType: AttributeState],
        selectedHorizontalAlignment: [LayoutAlignment: AttributeState]
    ) {
        let displayMarkups: [MarkupViewType: AttributeState] = selectedMarkups.reduce(into: [:])
        { partialResult, item in
            if let key = item.key.markupViewType {
                partialResult[key] = item.value
            }
        }
        
        let displayHorizontalAlignment = selectedHorizontalAlignment.reduce(into: [:]) { partialResult, item in
            partialResult[item.key.layoutAlignmentViewType] = item.value
        }
        
        let displayState = MarkupViewsState(
            markup: displayMarkups,
            alignment: displayHorizontalAlignment
        )
        
        view?.setMarkupState(displayState)
    }

    // MARK: - MarkupViewModelProtocol
    
    func handle(action: MarupViewAction) {
        switch action {
        case .toggleMarkup(let markupType):
            actionHandler.changeMarkup(blockIds: blockIds, markType: markupType.markupType)
        case .selectAlignment(let layoutAlignment):
            actionHandler.setAlignment(layoutAlignment.layoutAlignment, blockIds: blockIds)
        }
    }

    func viewLoaded() {
        subscribeToPublishers()
        updateState()
    }
}
