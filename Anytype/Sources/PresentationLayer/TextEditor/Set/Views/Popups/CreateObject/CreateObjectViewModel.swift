import Services
import AnytypeCore

final class CreateObjectViewModel: CreateObjectViewModelProtocol {
    let style = CreateObjectView.Style.default
    
    private let relationService: RelationsServiceProtocol
    private let debouncer = Debouncer()
    private let openToEditAction: () -> Void
    private let closeAction: () -> Void
    private var currentText: String = .empty

    init(relationService: RelationsServiceProtocol,
         openToEditAction: @escaping () -> Void,
         closeAction: @escaping () -> Void) {
        self.relationService = relationService
        self.openToEditAction = openToEditAction
        self.closeAction = closeAction
    }
    
    func textDidChange(_ text: String) {
        currentText = text

        debouncer.debounce(milliseconds: 100) { [weak self] in
            Task { [weak self] in
                try await self?.relationService.updateRelation(
                    relationKey: BundledRelationKey.name.rawValue,
                    value: text.protobufValue
                )
            }
        }
    }

    func actionButtonTapped(with text: String) {
        debouncer.cancel()
        
        Task { @MainActor in
            if currentText != text {
                try await relationService.updateRelation(relationKey: BundledRelationKey.name.rawValue, value: text.protobufValue)
            }
            openToEditAction()
        }
    }

    func returnDidTap() {
        closeAction()
    }
}
