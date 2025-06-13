import Services
import AnytypeCore

@MainActor
final class CreateObjectViewModel: CreateObjectViewModelProtocol {
    let style = CreateObjectView.Style.default
    
    @Injected(\.propertiesService)
    private var propertiesService: any PropertiesServiceProtocol
    @Injected(\.textService)
    private var textServiceHandler: any TextServiceProtocol
    
    private let objectId: String
    private let titleInputType: CreateObjectTitleInputType
    private let debouncer = Debouncer()
    private let openToEditAction: () -> Void
    private let closeAction: () -> Void
    private var currentText: String = ""

    init(
        objectId: String,
        titleInputType: CreateObjectTitleInputType,
        openToEditAction: @escaping () -> Void,
        closeAction: @escaping () -> Void
    ) {
        self.objectId = objectId
        self.titleInputType = titleInputType
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
            switch titleInputType {
            case .writeToBlock(let blockId):
                let middlewareString = MiddlewareString(text: text)
                try await textServiceHandler.setText(contextId: objectId, blockId: blockId, middlewareString: middlewareString)
            case .writeToRelationName:
                try await propertiesService.updateRelation(
                    objectId: objectId,
                    relationKey: BundledRelationKey.name.rawValue,
                    value: text.protobufValue
                )
            case .none:
                break
            }
            
            completion?()
        }
    }
}
