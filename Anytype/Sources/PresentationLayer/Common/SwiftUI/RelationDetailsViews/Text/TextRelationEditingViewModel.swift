import Combine
import Services
import Foundation

@MainActor
final class TextRelationEditingViewModel: ObservableObject {
    
    @Published var text: String
    @Published var dismiss = false
    @Published var textFocused = true
    
    let config: RelationModuleConfiguration
    let type: TextRelationViewType
    private let service: TextRelationEditingServiceProtocol
    
    init(
        text: String?,
        type: TextRelationViewType,
        config: RelationModuleConfiguration,
        service: TextRelationEditingServiceProtocol
    ) {
        self.text = text ?? ""
        self.config = config
        self.type = type
        self.service = service
        self.textFocused = config.isEditable
    }
    
    func onClear() {
        text = ""
        updateRelation(with: "")
    }
    
    func onTextChanged(_ text: String) {
        updateRelation(with: text)
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
    
    private func logEvent() {
        switch type {
        case .url:
            AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.relationUrlEditMobile)
        default:
            break
        }
    }
}
