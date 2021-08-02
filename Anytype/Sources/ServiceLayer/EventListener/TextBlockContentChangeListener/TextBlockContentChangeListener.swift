import BlocksModels
import ProtobufMessages

/// Entity to listen defined block updates
final class TextBlockContentChangeListener {
    
    private lazy var notificationListener = NotificationEventListener(handler: self)
    private let blockId: BlockId
    private let options: TextBlockContentChangeListenerOptions
    private let blockInformationCreator: BlockInformationCreator
    private weak var delegate: TextBlockContentChangeListenerDelegate?
    
    init(
        contenxtId: String,
         options: TextBlockContentChangeListenerOptions,
         blockId: BlockId,
         blockInformationCreator: BlockInformationCreator,
         delegate: TextBlockContentChangeListenerDelegate
    ) {
        self.blockId = blockId
        self.options = options
        self.blockInformationCreator = blockInformationCreator
        self.delegate = delegate
        notificationListener.startListening(contextId: contenxtId)
    }
    
    private func handleBlockSetTextIfNeeded(_ newData: Anytype_Event.Block.Set.Text) {
        guard newData.id == blockId,
              options.contains(.blockSetText),
              let information = blockInformationCreator.createBlockInformation(from: newData) else {
            return
        }
        delegate?.blockInformationDidChange(information)
    }
    
    private func handleBlockSetAlignIfNeeded(_ newData: Anytype_Event.Block.Set.Align) {
        guard newData.id == blockId,
              options.contains(.blockSetAlign),
              let information = blockInformationCreator.createBlockInformation(newAlignmentData: newData) else {
            return
        }
        delegate?.blockInformationDidChange(information)
    }
}

extension TextBlockContentChangeListener: EventHandlerProtocol {
    
    func handle(events: PackOfEvents) {
        events.middlewareEvents.forEach { [weak self] in
            switch $0.value {
            case let .blockSetText(newData):
                self?.handleBlockSetTextIfNeeded(newData)
            case let .blockSetAlign(newData):
                self?.handleBlockSetAlignIfNeeded(newData)
            default:
                return
            }
        }
    }
}
