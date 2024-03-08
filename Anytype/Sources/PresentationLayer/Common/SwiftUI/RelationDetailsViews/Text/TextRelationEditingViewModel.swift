import Combine
import Services
import Foundation

@MainActor
final class TextRelationEditingViewModel: ObservableObject {
    
    @Published var text: String
    @Published var dismiss = false
    @Published var textFocused = true
    @Published var actionsViewModel: [TextRelationActionViewModelProtocol]
    
    let config: RelationModuleConfiguration
    let type: TextRelationViewType
    private let service: TextRelationEditingServiceProtocol
    
    init(
        text: String?,
        type: TextRelationViewType,
        config: RelationModuleConfiguration,
        actionsViewModel: [TextRelationActionViewModelProtocol],
        service: TextRelationEditingServiceProtocol
    ) {
        self.text = text ?? ""
        self.config = config
        self.type = type
        self.actionsViewModel = actionsViewModel
        self.service = service
        self.textFocused = config.isEditable
        
        self.handleTextUpdate(text: self.text)
    }
    
    func onClear() {
        text = ""
        updateRelation(with: "")
    }
    
    func onTextChanged(_ text: String) {
        updateRelation(with: text)
        handleTextUpdate(text: text)
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
