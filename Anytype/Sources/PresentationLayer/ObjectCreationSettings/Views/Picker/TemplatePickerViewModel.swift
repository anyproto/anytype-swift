import Services

final class TemplatePickerViewModel {
    struct Item: Identifiable {
        let id: Int
        let viewController: GenericUIKitToSwiftUIView
        let object: ObjectDetails
    }

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
        let objectId = items[selectedTab].object.id
        
        Task { @MainActor in
            try await objectService.applyTemplate(objectId: document.objectId, templateId: objectId)
            onClose()
        }
    }

    func onCloseButton() {
        onClose()
    }
}
