import os
import Combine
import BlocksModels


final class ListBlockActionHandler {
    typealias ActionsPayload = DocumentEditorViewModel.Toolbar
    typealias ActionsPayloadToolbar = BlocksViews.Toolbar.UnderlyingAction

    private var documentId: String = ""
    private var subscription: AnyCancellable?

    private lazy var service: ListBlockActionService = ListBlockActionService(documentId: "") { [weak self] events in
        self?.reactionSubject.send(events)
    }

    private var reactionSubject: PassthroughSubject<PackOfEvents?, Never> = .init()
    lazy var reactionPublisher: AnyPublisher<PackOfEvents, Never> = reactionSubject.safelyUnwrapOptionals().eraseToAnyPublisher()



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

    func handlingToolbarAction(_ model: [BlockId], _ action: ActionsPayloadToolbar) {
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
