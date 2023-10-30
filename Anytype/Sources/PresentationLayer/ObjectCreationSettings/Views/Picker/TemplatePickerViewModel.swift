import Services

final class TemplatePickerViewModel {
    let items: [Item]
    private var selectedTab = 0
    private let document: BaseDocumentProtocol
    private let objectService: ObjectActionsServiceProtocol
    private let onClose: () -> Void
    private let onSettingsTap: (TemplatePickerViewModel.Item.TemplateModel) -> Void

    init(
        items: [Item],
        document: BaseDocumentProtocol,
        objectService: ObjectActionsServiceProtocol,
        onClose: @escaping () -> Void,
        onSettingsTap: @escaping (TemplatePickerViewModel.Item.TemplateModel) -> Void
    ) {
        self.items = items
        self.document = document
        self.objectService = objectService
        self.onClose = onClose
        self.onSettingsTap = onSettingsTap
    }

    func onTabChange(selectedTab: Int) {
        self.selectedTab = selectedTab
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
        let item = items[selectedTab]
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
