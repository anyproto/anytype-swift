import Services
@preconcurrency import Combine
import SwiftUI

@MainActor
protocol TemplatePickerViewModuleOutput: AnyObject {
    func onTemplatesChanged(_ templates: [ObjectDetails], completion: ([TemplatePickerData]) -> Void)
    func onTemplateSettingsTap(_ model: TemplatePickerViewModel.Item)
    func selectionOptionsView(_ provider: some OptionsItemProvider) -> AnyView
    func onClose()
}

struct TemplatePickerViewModelData {
    enum Mode {
        case objectTemplate(objectId: String)
        case typeTemplate
    }
    
    let mode: Mode
    let typeId: String?
    let spaceId: String
    let defaultTemplateId: String?
    
    var objectId: String? {
        switch mode {
        case .objectTemplate(let objectId):
            return objectId
        case .typeTemplate:
            return nil
        }
    }
}

@MainActor
final class TemplatePickerViewModel: ObservableObject, OptionsItemProvider {    
    @Published var items = [Item]()
    @Published var selectedTab = 0
    
    var showApplyButton: Bool {
        if case .objectTemplate = data.mode { return true }
        return false
    }
    
    private let data: TemplatePickerViewModelData
    private var didSetupDefaultItem = false
    
    @Injected(\.objectActionsService)
    private var objectService: any ObjectActionsServiceProtocol
    @Injected(\.templatesSubscription)
    private var templatesSubscriptionService: any TemplatesSubscriptionServiceProtocol
    
    private weak var output: (any TemplatePickerViewModuleOutput)?
    
    // MARK: - OptionsItemProvider
    
    var optionsPublisher: AnyPublisher<[SelectionOptionsItemViewModel], Never> { $options.eraseToAnyPublisher() }
    @Published var options = [SelectionOptionsItemViewModel]()

    init(
        data: TemplatePickerViewModelData,
        output: (any TemplatePickerViewModuleOutput)?
    ) {
        self.data = data
        self.output = output
    }

    func onApplyButton() {
        guard let objectId = data.objectId else { return }
        
        let templateId = selectedTemplateId()
        Task { @MainActor in
            try await objectService.applyTemplate(objectId: objectId, templateId: templateId)
            output?.onClose()
        }
    }

    func onCloseButtonTap() {
        output?.onClose()
    }
    
    func onSettingsButtonTap() {
        let model = templateModel()
        output?.onTemplateSettingsTap(model)
    }
    
    func selectedItem() -> Item {
        let index = selectedTab >= items.count ? items.count - 1 : selectedTab
        return items[index]
    }
    
    func startTemplateSubscription() async {
        guard let typeId = data.typeId else { return }
        let publisher = await templatesSubscriptionService.startSubscription(
            objectType: typeId,
            spaceId: data.spaceId,
            update: nil
        )
        for await templates in publisher.values {
            updateItems(with: templates)
            setupDefaultItem()
        }
    }
    
    private func setupDefaultItem() {
        guard !didSetupDefaultItem else { return }
        
        if let defaultIndex = items.firstIndex(where: { $0.templateId == data.defaultTemplateId}) {
            selectedTab = defaultIndex
        }
        
        didSetupDefaultItem = true
    }
    
    private func updateItems(with templates: [ObjectDetails]) {
        output?.onTemplatesChanged(templates, completion: { [weak self] models in
            guard let self else { return }
            items = models.enumerated().map { info -> TemplatePickerViewModel.Item in
                let model = info.element
                return .init(
                    id: info.offset + 1,
                    view: model.editorView,
                    object: model.template,
                    templateId: model.template.id
                )
            }
        })
    }
    
    private func selectedTemplateId() -> String {
        let model = templateModel()
        let templateId = model.object.id
        AnytypeAnalytics.instance().logTemplateSelection(
            objectType: model.object.templateIsBundled ? .object(typeId: model.object.id) : .custom,
            route: .navigation
        )

        return templateId
    }
    
    private func templateModel() -> TemplatePickerViewModel.Item {
        selectedItem()
    }
}

extension TemplatePickerViewModel {
    struct Item: Identifiable {
        let id: Int
        let view: AnyView
        let object: ObjectDetails
        let templateId: String
    }
}
