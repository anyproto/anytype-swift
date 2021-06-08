import Combine
import BlocksModels
import os


private extension LoggerCategory {
    static let blockActionsHandlersFacade: Self = "BlockActionsHandlersFacade"
}

final class BlockActionsHandlersFacade {
    typealias ActionsPayload = BaseBlockViewModel.ActionsPayload

    private var subscription: AnyCancellable?
    private let service: BlockActionService = .init(documentId: "")
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

    private let reactionSubject: PassthroughSubject<BlockActionService.Reaction?, Never> = .init()
    private(set) var reactionPublisher: AnyPublisher<BlockActionService.Reaction, Never> = .empty()

    init(newTextBlockActionHandler: @escaping (BlockActionHandler.ActionType, BlockModelProtocol) -> Void,
         documentViewInteraction: DocumentViewInteraction) {
        self.newTextBlockActionHandler = newTextBlockActionHandler
        self.documentViewInteraction = documentViewInteraction
        self.setup()
    }

    func setup() {
        self.reactionPublisher = self.reactionSubject.safelyUnwrapOptionals().eraseToAnyPublisher()
        // config block action service with completion that send value to subscriber (EditorModule.Document.ViewController.ViewModel)
        _ = self.service.configured { [weak self] (actionType, value) in
            self?.reactionSubject.send(.shouldHandleEvent(.init(actionType: actionType, events: value)))
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

// MARK: TODO - Move to enum or wrap in another protocol
extension BlockActionsHandlersFacade {
    func createEmptyBlock(listIsEmpty: Bool, parentModel: BlockActiveRecordModelProtocol?) {
        if listIsEmpty {
            if let defaultBlock = BlockBuilder.createDefaultInformation() {
                self.service.addChild(childBlock: defaultBlock, parentBlockId: self.documentId)
            }
        }
        else {
            // Unknown for now.
            // Check that previous ( last block ) is not nil.
            // We must provide a smartblock of page to solve it.
            //
            guard let parentModel = parentModel else {
                // We don't have parentModel, so, we can't proceed.
                assertionFailure("createEmptyBlock.listIsEmpty. We don't have parent model.")
                return
            }
            guard let lastChildId = parentModel.childrenIds().last else {
                // We don't have children, let's do nothing.
                assertionFailure("createEmptyBlock.listIsEmpty. Children are empty.")
                return
            }
            guard let lastChild = parentModel.container?.choose(by: lastChildId) else {
                // No child - nothing to do.
                assertionFailure("createEmptyBlock.listIsEmpty. Last child doesn't exist.")
                return
            }

            switch lastChild.content {
            case let .text(value) where value.attributedText.length == 0:
                // TODO: Add assertionFailure for debug when all converters will be added
                // TASK: https://app.clickup.com/t/h138gt
                Logger.create(.blockActionsHandlersFacade).error("createEmptyBlock.listIsEmpty. Last block is text and it is empty. Skipping..")
//                assertionFailure("createEmptyBlock.listIsEmpty. Last block is text and it is empty. Skipping..")
                return
            default:
                if let defaultBlock = BlockBuilder.createDefaultInformation() {
                    self.service.addChild(childBlock: defaultBlock, parentBlockId: self.documentId)
                }
            }
        }
    }
}

// MARK: - BlockTextView.ContextMenuAction

private extension BlockTextView.ContextMenuAction {
    
    var asActionType: BlockActionHandler.ActionType.TextAttributesType {
        switch self {
        case .bold:
            return .bold
        case .italic:
            return .italic
        case .strikethrough:
            return .strikethrough
        }
    }
    
}
