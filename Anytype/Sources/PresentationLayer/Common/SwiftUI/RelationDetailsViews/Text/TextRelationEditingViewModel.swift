import Combine
import Services
import Foundation

struct TextRelationEditingViewData {
    let text: String?
    let type: TextRelationViewType
    let config: RelationModuleConfiguration
    let objectDetails: ObjectDetails
    let output: TextRelationActionButtonViewModelDelegate?
}

@MainActor
final class TextRelationEditingViewModel: ObservableObject {
    
    @Published var text: String
    @Published var dismiss = false
    @Published var textFocused = true
    @Published var actionsViewModels: [TextRelationActionViewModelProtocol] = []
    @Published var showPaste = false
    
    let config: RelationModuleConfiguration
    let type: TextRelationViewType
    
    @Injected(\.textRelationEditingService)
    private var service: TextRelationEditingServiceProtocol
    @Injected(\.pasteboardHelper)
    private var pasteboardHelper: PasteboardHelperProtocol
    @Injected(\.textRelationActionViewModelBuilder)
    private var builder: TextRelationActionViewModelBuilder
    
    init(data: TextRelationEditingViewData) {
        self.text = data.text ?? ""
        self.config = data.config
        self.type = data.type
        self.textFocused = data.config.isEditable
        
        self.actionsViewModels = builder.buildActionsViewModels(
            text: data.text,
            for: data.type,
            relationKey: data.config.relationKey,
            objectDetails: data.objectDetails,
            output: data.output
        )
        
        pasteboardHelper.startSubscription { [weak self] in
            self?.updatePasteState()
        }
        self.handleTextUpdate(text: self.text)
    }
    
    func onDisappear() {
        guard config.isEditable else { return }
        AnytypeAnalytics.instance().logChangeOrDeleteRelationValue(
            isEmpty: text.isEmpty,
            type: config.analyticsType,
            spaceId: config.spaceId
        )
    }
    
    func onClear() {
        text = ""
        updateText(with: "")
    }
    
    func onPaste() {
        text = pasteboardHelper.obtainTextSlot() ?? ""
        updateText(with: text)
    }
    
    func updatePasteState() {
        showPaste = pasteboardHelper.hasSlots && text.isEmpty
    }
    
    func onTextChanged(_ text: String) {
        updateText(with: text)
    }
    
    private func updateText(with text: String) {
        updateRelation(with: text)
        handleTextUpdate(text: text)
        updatePasteState()
    }
    
    private func updateRelation(with value: String) {
        service.saveRelation(
            objectId: config.objectId,
            value: value,
            key: config.relationKey,
            textType: type
        )
        logEvent()
    }
    
    func handleTextUpdate(text: String) {
        for actionViewModel in actionsViewModels {
            actionViewModel.inputText = text
        }
        self.actionsViewModels = actionsViewModels
    }
    
    private func logEvent() {
        switch type {
        case .url:
            AnytypeAnalytics.instance().logRelationUrlEditMobile()
        default:
            break
        }
    }
}
