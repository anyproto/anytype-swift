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
    private lazy var userActionHandler: UserActionHandler = .init(service: service)

    private let reactionSubject: PassthroughSubject<BlockActionServiceReaction?, Never> = .init()
    private(set) var reactionPublisher: AnyPublisher<BlockActionServiceReaction, Never> = .empty()

    init(newTextBlockActionHandler: @escaping (BlockActionHandler.ActionType, BlockModelProtocol) -> Void,
         documentViewInteraction: DocumentViewInteraction) {
        self.newTextBlockActionHandler = newTextBlockActionHandler
        self.documentViewInteraction = documentViewInteraction
        self.setup()
    }

    func setup() {
        self.reactionPublisher = self.reactionSubject.safelyUnwrapOptionals().eraseToAnyPublisher()
        // config block action service with completion that send value to subscriber (EditorModule.Document.ViewController.ViewModel)
        _ = self.service.configured { [weak self] (actionType, events) in
            self?.reactionSubject.send(.shouldHandleEvent(.init(actionType: actionType, events: events)))
        }
    }

    /// Attaches subscriber to base blocks views (BlocksViews.Base) publisher
    /// - Parameter publisher: Publisher that send action from block view to this handler
    /// - Returns: self
    func configured(_ publisher: AnyPublisher<ActionsPayload, Never>) -> Self {
        self.subscription = publisher
            .sink { [weak self] (value) in
            self?.didReceiveAction(action: value)
        }
        return self
    }

    func configured(documentId: String) -> Self {
        self.documentId = documentId
        _ = self.service.configured(documentId: documentId)
        return self
    }

    func configured(_ model: DocumentEditorViewModel) -> Self {
        self.indexWalker = .init(DocumentModelListProvider.init(model: model))
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
        case let .userAction(value): self.userActionHandler.handlingUserAction(value.model, value.action)
        case .showCodeLanguageView: return
        case .showStyleMenu: return
        case .becomeFirstResponder: return
        }
    }
}

extension BlockActionsHandlersFacade {
    func createEmptyBlock() {
        self.service.addChild(
            childBlock: BlockBuilder.createDefaultInformation(),
            parentBlockId: self.documentId
        )
    }
}
