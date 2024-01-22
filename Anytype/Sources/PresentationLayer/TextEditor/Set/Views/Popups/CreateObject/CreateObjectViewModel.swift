import Services
import AnytypeCore

@MainActor
final class CreateObjectViewModel: CreateObjectViewModelProtocol {
    let style = CreateObjectView.Style.default
    
    private let objectId: String
    private let blockId: String?
    private let relationService: RelationsServiceProtocol
    private let textServiceHandler: TextServiceProtocol
    private let debouncer = Debouncer()
    private let openToEditAction: () -> Void
    private let closeAction: () -> Void
    private var currentText: String = .empty

    init(
        objectId: String,
        blockId: String?,
        relationService: RelationsServiceProtocol,
        textServiceHandler: TextServiceProtocol,
        openToEditAction: @escaping () -> Void,
        closeAction: @escaping () -> Void
    ) {
        self.objectId = objectId
        self.blockId = blockId
        self.relationService = relationService
        self.textServiceHandler = textServiceHandler
        self.openToEditAction = openToEditAction
        self.closeAction = closeAction
    }
    
    func textDidChange(_ text: String) {
        currentText = text

        debouncer.debounce(milliseconds: 100) { [weak self] in
            self?.changeText(text)
        }
    }

    func actionButtonTapped(with text: String) {
        debouncer.cancel()
        
        guard currentText != text else {
            openToEditAction()
            return
        }
        
        changeText(text, completion: { [weak self] in
            self?.openToEditAction()
        })
    }

    func returnDidTap() {
        closeAction()
    }
    
    private func changeText(_ text: String, completion: (() -> Void)? = nil) {
        Task {
            if let blockId {
                let middlewareString = MiddlewareString(text: text)
                try await textServiceHandler.setText(contextId: objectId, blockId: blockId, middlewareString: middlewareString)
            } else {
                try await relationService.updateRelation(
                    relationKey: BundledRelationKey.name.rawValue,
                    value: text.protobufValue
                )
            }
            completion?()
        }
    }
}
