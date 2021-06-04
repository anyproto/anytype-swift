import os
import Combine
import BlocksModels


final class ListBlockActionHandler {
    enum Reaction {
        struct ShouldHandleEvent {
            var payload: Payload
            struct Payload {
                var events: PackOfEvents
            }
        }

        case shouldHandleEvent(ShouldHandleEvent)
    }

    typealias ActionsPayload = DocumentEditorViewModel.Toolbar
    typealias ActionsPayloadToolbar = BlocksViews.Toolbar.UnderlyingAction

    typealias ListModel = [BlockId]

    private var documentId: String = ""
    private var subscription: AnyCancellable?

    private let service: ListBlockActionService = .init(documentId: "")

    private var reactionSubject: PassthroughSubject<Reaction?, Never> = .init()
    var reactionPublisher: AnyPublisher<Reaction, Never> = .empty()

    init() {
        self.setup()
    }

    func setup() {
        self.reactionPublisher = self.reactionSubject.safelyUnwrapOptionals().eraseToAnyPublisher()
        _ = self.service.configured { [weak self] (value) in
            self?.reactionSubject.send(.shouldHandleEvent(.init(payload: .init(events: value))))
        }
    }

    func configured(documentId: String) -> Self {
        self.documentId = documentId
        _ = self.service.configured(documentId: documentId)
        return self
    }

    func configured(_ publisher: AnyPublisher<ActionsPayload, Never>) -> Self {
        self.subscription = publisher.sink { [weak self] (value) in
            self?.didReceiveAction(action: value)
        }
        return self
    }

    func didReceiveAction(action: ActionsPayload) {
        handlingToolbarAction(
            action.model,
            action.action
        )
    }

    func handlingToolbarAction(_ model: ListModel, _ action: ActionsPayloadToolbar) {
        switch action {
        case .addBlock: break
        case let .turnIntoBlock(value):
            // TODO: Add turn into
            switch value {
            case let .text(value): // Set Text Style
                let type: BlockContent
                switch value {
                case .text: type = .text(.empty())
                case .h1: type = .text(.init(contentType: .header))
                case .h2: type = .text(.init(contentType: .header2))
                case .h3: type = .text(.init(contentType: .header3))
                case .highlighted: type = .text(.init(contentType: .quote))
                }
                self.service.turnInto(blocks: model, type: type)

            case let .list(value): // Set Text Style
                let type: BlockContent
                switch value {
                case .bulleted: type = .text(.init(contentType: .bulleted))
                case .checkbox: type = .text(.init(contentType: .checkbox))
                case .numbered: type = .text(.init(contentType: .numbered))
                case .toggle: type = .text(.init(contentType: .toggle))
                }
                self.service.turnInto(blocks: model, type: type)

            case .other: // Change divider style.
                break
            case .objects(.page): // Convert children to pages.
                let type: BlockContent = .smartblock(.init(style: .page))
                self.service.turnInto(blocks: model, type: type)
            default:
                assertionFailure("TurnInto for that style is not implemented \(action)")
            }

        case let .editBlock(value):
            switch value {
            case .delete: self.service.delete(model)
            default: return
            }
        default: return
        }
    }
}
