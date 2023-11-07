import Services
import Combine

struct TemplatePickerModel {
    let template: ObjectDetails
    let editorController: EditorPageController
}

@MainActor
protocol TemplatePickerViewModuleOutput: AnyObject {
    func onTemplatesChanged(_ templates: [ObjectDetails], completion: ([TemplatePickerModel]) -> Void)
}

@MainActor
final class TemplatePickerViewModel: ObservableObject {
    @Published var items = [Item]()
    @Published var selectedTab = 0
    private var templatesDetails = [ObjectDetails]()
    private let document: BaseDocumentProtocol
    private let objectService: ObjectActionsServiceProtocol
    private let templatesSubscriptionService: TemplatesSubscriptionServiceProtocol
    private let onClose: () -> Void
    private let onSettingsTap: (TemplatePickerViewModel.Item.TemplateModel) -> Void
    
    private weak var output: TemplatePickerViewModuleOutput?

    init(
        output: TemplatePickerViewModuleOutput?,
        document: BaseDocumentProtocol,
        objectService: ObjectActionsServiceProtocol,
        templatesSubscriptionService: TemplatesSubscriptionServiceProtocol,
        onClose: @escaping () -> Void,
        onSettingsTap: @escaping (TemplatePickerViewModel.Item.TemplateModel) -> Void
    ) {
        self.output = output
        self.document = document
        self.objectService = objectService
        self.templatesSubscriptionService = templatesSubscriptionService
        self.onClose = onClose
        self.onSettingsTap = onSettingsTap
        self.loadTemplates()
    }

    func onApplyButton() {
        let templateId = selectedTemplateId()
        Task { @MainActor in
            try await objectService.applyTemplate(objectId: document.objectId, templateId: templateId)
            onClose()
        }
    }

    func onCloseButtonTap() {
        onClose()
    }
    
    func onSettingsButtonTap() {
        guard let model = templateModel() else { return }
        onSettingsTap(model)
    }
    
    func selectedItem() -> Item {
        let index = selectedTab >= items.count ? items.count - 1 : selectedTab
        return items[index]
    }
    
    private func loadTemplates() {
        guard let objectTypeId = document.details?.objectType.id else { return }
        Task {
            await templatesSubscriptionService.startSubscription(
                objectType: objectTypeId,
                spaceId: document.spaceId
            ) { [weak self] details in
                guard let self else { return }
                templatesDetails = details
                updateItems()
            }
        }
    }
    
    private func updateItems() {
        output?.onTemplatesChanged(templatesDetails, completion: { [weak self] models in
            guard let self else { return }
            var updatedItems = models.enumerated().map { info -> TemplatePickerViewModel.Item in
                let model = info.element
                return .template(
                    .init(
                        id: info.offset + 1,
                        viewController: GenericUIKitToSwiftUIView(viewController: model.editorController),
                        viewModel: model.editorController.viewModel,
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
            let viewController: GenericUIKitToSwiftUIView
            let viewModel: EditorPageViewModelProtocol
            let object: ObjectDetails
        }
    }
}
