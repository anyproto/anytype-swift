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
    
    private let newTextBlockActionHandler: ((BlockActionHandler.ActionType, BlockModelProtocol) -> Void)
    private lazy var textBlockActionHandler = TextBlockActionHandler(
        contextId: self.documentId,
        service: service,
        indexWalker: indexWalker
    )
    
    private lazy var toolbarBlockActionHandler = ToolbarBlockActionHandler(
        service: service,
        indexWalker: indexWalker
    )
    
    private lazy var marksPaneBlockActionHandler = MarksPaneBlockActionHandler(
        documentViewInteraction: self.documentViewInteraction,
        service: service,
        contextId: self.documentId,
        subject: reactionSubject
    )
    
    private lazy var buttonBlockActionHandler: ButtonBlockActionHandler = .init(service: service)

    private let reactionSubject: PassthroughSubject<PackOfEvents?, Never> = .init()
    lazy var reactionPublisher: AnyPublisher<PackOfEvents, Never> = reactionSubject.safelyUnwrapOptionals().eraseToAnyPublisher()

    init(
        newTextBlockActionHandler: @escaping (BlockActionHandler.ActionType, BlockModelProtocol) -> Void,
        publisher: AnyPublisher<ActionsPayload, Never>,
        documentViewInteraction: DocumentViewInteraction
    ) {
        self.newTextBlockActionHandler = newTextBlockActionHandler
        self.documentViewInteraction = documentViewInteraction
        
        
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

    func configured(_ model: DocumentEditorViewModel) -> Self {
        indexWalker = LinearIndexWalker(model)
        return self
    }

    func didReceiveAction(action: ActionsPayload) {
        switch action {
        case let .toolbar(value): self.toolbarBlockActionHandler.handlingToolbarAction(value.model, value.action)
        case let .marksPane(value): self.marksPaneBlockActionHandler.handlingMarksPaneAction(value.model, value.action)
        case let .textView(value):
            switch value.action {
            case let .textView(action):
                guard case let .inputAction(.changeTextStyle(styleAction, range)) = action else {
                    textBlockActionHandler.handlingTextViewAction(value.model, action)
                    return
                }
                
                newTextBlockActionHandler(
                    .toggleFontStyle(styleAction.asActionType, range),
                    value.model.blockModel
                )
                
            case let .buttonView(action):
                self.buttonBlockActionHandler.handlingButtonViewAction(value.model, action)
            }
        case let .userAction(userAction):
            if case let .specific(.file(.shouldUploadFile(uploadData))) = userAction.action {
                service.upload(block: userAction.model.blockModel.information, filePath: uploadData.filePath)
            }
        case .showCodeLanguageView: return
        case .showStyleMenu: return
        case .becomeFirstResponder: return
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
