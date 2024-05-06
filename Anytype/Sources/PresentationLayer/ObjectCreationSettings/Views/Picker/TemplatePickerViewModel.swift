import Services
import Combine
import SwiftUI

@MainActor
protocol TemplatePickerViewModuleOutput: AnyObject {
    func onTemplatesChanged(_ templates: [ObjectDetails], completion: ([TemplatePickerData]) -> Void)
    func onTemplateSettingsTap(_ model: TemplatePickerViewModel.Item.TemplateModel)
    func selectionOptionsView(_ provider: OptionsItemProvider) -> AnyView
    func setAsDefaultBlankTemplate()
    func onClose()
}

@MainActor
final class TemplatePickerViewModel: ObservableObject, OptionsItemProvider {    
    @Published var items = [Item]()
    @Published var selectedTab = 0
    @Published var showBlankSettings = false
    private let document: BaseDocumentProtocol
    
    @Injected(\.objectActionsService)
    private var objectService: ObjectActionsServiceProtocol
    @Injected(\.templatesSubscription)
    private var templatesSubscriptionService: TemplatesSubscriptionServiceProtocol
    
    private weak var output: TemplatePickerViewModuleOutput?
    
    // MARK: - OptionsItemProvider
    
    var optionsPublisher: AnyPublisher<[SelectionOptionsItemViewModel], Never> { $options.eraseToAnyPublisher() }
    @Published var options = [SelectionOptionsItemViewModel]()

    init(
        output: TemplatePickerViewModuleOutput?,
        document: BaseDocumentProtocol
    ) {
        self.output = output
        self.document = document
        self.options = buildBlankOptions()
        self.loadTemplates()
    }

    func onApplyButton() {
        let templateId = selectedTemplateId()
        Task { @MainActor in
            try await objectService.applyTemplate(objectId: document.objectId, templateId: templateId)
            output?.onClose()
        }
    }

    func onCloseButtonTap() {
        output?.onClose()
    }
    
    func onSettingsButtonTap() {
        if let model = templateModel() {
            output?.onTemplateSettingsTap(model)
        } else {
            showBlankSettings.toggle()
        }
    }
    
    func blankSettingsView() -> AnyView? {
        output?.selectionOptionsView(self)
    }
    
    func selectedItem() -> Item {
        let index = selectedTab >= items.count ? items.count - 1 : selectedTab
        return items[index]
    }
    
    private func buildBlankOptions() -> [SelectionOptionsItemViewModel] {
        BlankTemplateSetting.allCases.map { setting in
            SelectionOptionsItemViewModel(
                id: UUID().uuidString,
                title: setting.title,
                imageAsset: setting.imageAsset,
                action: { [weak self] in
                    self?.output?.setAsDefaultBlankTemplate()
                }
            )
        }
    }
    
    private func loadTemplates() {
        guard let objectTypeId = document.details?.objectType.id else { return }
        Task {
            await templatesSubscriptionService.startSubscription(
                objectType: objectTypeId,
                spaceId: document.spaceId
            ) { [weak self] templates in
                self?.updateItems(with: templates)
            }
        }
    }
    
    private func updateItems(with templates: [ObjectDetails]) {
        output?.onTemplatesChanged(templates, completion: { [weak self] models in
            guard let self else { return }
            var updatedItems = models.enumerated().map { info -> TemplatePickerViewModel.Item in
                let model = info.element
                return .template(
                    .init(
                        id: info.offset + 1,
                        view: model.editorView,
                        object: model.template
                    )
                )
            }
            
            updatedItems.insert(.blank(0), at: 0)
            items = updatedItems
        })
    }
    
    private func selectedTemplateId() -> String {
        let templateId: String
        if let model = templateModel() {
            templateId = model.object.id
            AnytypeAnalytics.instance().logTemplateSelection(
                objectType: model.object.templateIsBundled ? .object(typeId: model.object.id) : .custom,
                route: .navigation
            )
        } else {
            templateId = TemplateType.blank.id
            AnytypeAnalytics.instance().logTemplateSelection(
                objectType: nil,
                route: .navigation
            )
        }
        return templateId
    }
    
    private func templateModel() -> TemplatePickerViewModel.Item.TemplateModel? {
        let item = selectedItem()
        switch item {
        case let .template(model):
            return model
        case .blank:
            return nil
        }
    }
}

extension TemplatePickerViewModel {
    enum Item: Identifiable {
        case blank(Int)
        case template(TemplateModel)

        var id: Int {
            switch self {
            case let .blank(id):
                return id
            case let .template(model):
                return model.id
            }
        }

        struct TemplateModel {
            let id: Int
            let view: AnyView
            let object: ObjectDetails
        }
    }
}
