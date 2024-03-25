import Combine
import Services
import Foundation

@MainActor
final class TextRelationEditingViewModel: ObservableObject {
    
    @Published var text: String
    @Published var dismiss = false
    @Published var textFocused = true
    @Published var actionsViewModel: [TextRelationActionViewModelProtocol]
    @Published var showPaste = false
    
    let config: RelationModuleConfiguration
    let type: TextRelationViewType
    private let service: TextRelationEditingServiceProtocol
    private let pasteboardHelper: PasteboardHelperProtocol
    
    init(
        text: String?,
        type: TextRelationViewType,
        config: RelationModuleConfiguration,
        actionsViewModel: [TextRelationActionViewModelProtocol],
        service: TextRelationEditingServiceProtocol,
        pasteboardHelper: PasteboardHelperProtocol
    ) {
        self.text = text ?? ""
        self.config = config
        self.type = type
        self.actionsViewModel = actionsViewModel
        self.service = service
        self.pasteboardHelper = pasteboardHelper
        self.textFocused = config.isEditable
        
        pasteboardHelper.startSubscription { [weak self] in
            self?.updatePasteState()
        }
        self.handleTextUpdate(text: self.text)
    }
    
    func onDisappear() {
        guard config.isEditable else { return }
        AnytypeAnalytics.instance().logChangeRelationValue(isEmpty: text.isEmpty, type: config.analyticsType)
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
        for actionViewModel in actionsViewModel {
            actionViewModel.inputText = text
        }
        self.actionsViewModel = actionsViewModel
    }
    
    private func logEvent() {
        switch type {
        case .url:
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.relationUrlEditMobile)
        default:
            break
        }
    }
}
