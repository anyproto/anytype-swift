import Services

final class TemplatePickerViewModel {
    let items: [Item]
    private var selectedTab = 0
    private let document: BaseDocumentProtocol
    private let objectService: ObjectActionsServiceProtocol
    private let onClose: () -> Void

    init(
        items: [Item],
        document: BaseDocumentProtocol,
        objectService: ObjectActionsServiceProtocol,
        onClose: @escaping () -> Void
    ) {
        self.items = items
        self.document = document
        self.objectService = objectService
        self.onClose = onClose
    }

    func onTabChange(selectedTab: Int) {
        self.selectedTab = selectedTab
    }

    func onApplyButton() {
        let item = items[selectedTab]
        let templateId: String
        switch item {
        case let .template(model):
            templateId = model.object.id
            AnytypeAnalytics.instance().logTemplateSelection(
                objectType: model.object.templateIsBundled ? .object(typeId: model.object.id) : .custom,
                route: .navigation
            )
        case .blank:
            templateId = TemplateType.blank.id
            AnytypeAnalytics.instance().logTemplateSelection(
                objectType: nil,
                route: .navigation
            )
        }
        
        Task { @MainActor in
            try await objectService.applyTemplate(objectId: document.objectId, templateId: templateId)
            onClose()
        }
    }

    func onCloseButton() {
        onClose()
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
            let object: ObjectDetails
        }
    }
}
