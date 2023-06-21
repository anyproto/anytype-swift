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
    private let onSkip: () -> Void

    init(
        items: [Item],
        document: BaseDocumentProtocol,
        objectService: ObjectActionsServiceProtocol,
        onSkip: @escaping () -> Void
    ) {
        self.items = items
        self.document = document
        self.objectService = objectService
        self.onSkip = onSkip
    }

    func onTabChange(selectedTab: Int) {
        self.selectedTab = selectedTab
    }

    func onApplyButton() {
        let objectId = items[selectedTab].object.id
        
        Task { @MainActor in
            try await objectService.applyTemplate(objectId: document.objectId, templateId: objectId)
            onSkip()
        }
    }

    func onSkipButton() {
        onSkip()
    }
}
