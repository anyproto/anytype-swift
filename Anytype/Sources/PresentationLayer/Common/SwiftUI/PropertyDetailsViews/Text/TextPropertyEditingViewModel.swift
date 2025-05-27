import Combine
import Services
import Foundation

struct TextPropertyEditingViewData {
    let text: String?
    let type: TextPropertyViewType
    let config: PropertyModuleConfiguration
    let objectDetails: ObjectDetails
    let output: (any TextPropertyActionButtonViewModelDelegate)?
}

@MainActor
final class TextPropertyEditingViewModel: ObservableObject {
    
    @Published var text: String
    @Published var dismiss = false
    @Published var textFocused = true
    @Published var actionsViewModels: [any TextPropertyActionViewModelProtocol] = []
    @Published var showPaste = false
    
    let config: PropertyModuleConfiguration
    let type: TextPropertyViewType
    
    @Injected(\.textRelationEditingService)
    private var service: any TextPropertyEditingServiceProtocol
    @Injected(\.pasteboardHelper)
    private var pasteboardHelper: any PasteboardHelperProtocol
    @Injected(\.textRelationActionViewModelBuilder)
    private var builder: TextPropertyActionViewModelBuilder
    @Injected(\.propertyDetailsStorage)
    private var propertyDetailsStorage: any PropertyDetailsStorageProtocol
    
    private let initialText: String
    
    init(data: TextPropertyEditingViewData) {
        let initialText = data.text ?? ""
        self.text = initialText
        self.initialText = initialText
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
        self.handleTextUpdate(text: self.text)
    }
    
    func onDisappear() {
        guard config.isEditable else { return }
        logChangeOrDeleteRelationValue()
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
    
    func handlePasteboard() async {
        for await _ in pasteboardHelper.pasteboardChangePublisher().values {
            updatePasteState()
        }
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
    
    private func logChangeOrDeleteRelationValue() {
        guard initialText != text else { return }
        Task {
            let relationDetails = try propertyDetailsStorage.relationsDetails(key: config.relationKey, spaceId: config.spaceId)
            AnytypeAnalytics.instance().logChangeOrDeleteRelationValue(
                isEmpty: text.isEmpty,
                format: relationDetails.format,
                type: config.analyticsType,
                key: relationDetails.analyticsKey,
                spaceId: config.spaceId
            )
        }
    }
}
