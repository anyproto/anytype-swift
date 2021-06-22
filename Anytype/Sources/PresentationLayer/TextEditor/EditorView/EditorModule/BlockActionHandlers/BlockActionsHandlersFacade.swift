import Combine
import BlocksModels
import os


private extension LoggerCategory {
    static let blockActionsHandlersFacade: Self = "BlockActionsHandlersFacade"
}

final class BlockActionsHandlersFacade {
    private var subscription: AnyCancellable?
    private let service: BlockActionServiceProtocol = BlockActionService(documentId: "")
    private var documentId: String = ""
    private var indexWalker: LinearIndexWalker?
    private weak var documentViewInteraction: DocumentViewInteraction?
    
    private weak var newBlockActionHandler: NewBlockActionHandler?
    private lazy var textBlockActionHandler = TextBlockActionHandler(
        contextId: self.documentId,
        service: service,
        indexWalker: indexWalker
    )
    
    private lazy var toolbarBlockActionHandler = ToolbarBlockActionHandler(
        service: service,
        indexWalker: indexWalker
    )
    
    private lazy var buttonBlockActionHandler: ButtonBlockActionHandler = .init(service: service)

    private let reactionSubject: PassthroughSubject<PackOfEvents?, Never> = .init()
    lazy var reactionPublisher: AnyPublisher<PackOfEvents, Never> = reactionSubject.safelyUnwrapOptionals().eraseToAnyPublisher()

    init(
        newBlockActionHandler: NewBlockActionHandler,
        publisher: AnyPublisher<ActionPayload, Never>,
        documentViewInteraction: DocumentViewInteraction
    ) {
        self.documentViewInteraction = documentViewInteraction
        self.newBlockActionHandler = newBlockActionHandler
        
        
        self.subscription = publisher.sink { [weak self] action in
            self?.didReceiveAction(action: action)
        }
        
        // config block action service with completion that send value to subscriber (EditorModule.Document.ViewController.ViewModel)
        _ = self.service.configured { [weak self] events in
            self?.reactionSubject.send(events)
        }
    }

    func configured(documentId: String) -> Self {
        self.documentId = documentId
        _ = service.configured(documentId: documentId)
        return self
    }

    func configured(_ model: DocumentEditorViewModel) {
        indexWalker = LinearIndexWalker(model)
        textBlockActionHandler.router = model.editorRouter
    }

    func didReceiveAction(action: ActionPayload) {
        switch action {
        case let .toolbar(model, action): toolbarBlockActionHandler.handlingToolbarAction(model, action)
        case let .textView(model, action):
            switch action {
            case let .textView(action):
                guard case let .changeTextStyle(styleAction, range) = action else {
                    textBlockActionHandler.handlingTextViewAction(model, action)
                    return
                }
                
                newBlockActionHandler?.handleActionWithoutCompletion(
                    .toggleFontStyle(styleAction.asActionType, range),
                    model: model.blockModel
                )
                
            case let .buttonView(action):
                self.buttonBlockActionHandler.handlingButtonViewAction(model, action)
            }
        case let .uploadFile(model, filePath):
            service.upload(block: model.blockModel.information, filePath: filePath)
        case .showCodeLanguageView: return
        case .showStyleMenu: return
        }
    }
}

extension BlockActionsHandlersFacade {
    func createEmptyBlock() {
        service.addChild(
            childBlock: BlockBuilder.createDefaultInformation(),
            parentBlockId: self.documentId
        )
    }
}
