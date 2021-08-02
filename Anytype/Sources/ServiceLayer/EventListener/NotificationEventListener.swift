import Foundation
import Combine
import ProtobufMessages

final class NotificationEventListener {

    private var subscription: AnyCancellable?
    private weak var handler: EventHandlerProtocol?

    init(handler: EventHandlerProtocol) {
        self.handler = handler
    }
    
    func startListening(contextId: String) {
        subscription = NotificationCenter.Publisher(center: .default, name: .middlewareEvent, object: nil)
            .compactMap { $0.object as? Anytype_Event }
            .filter( {$0.contextID == contextId} )
            .sink { [weak self] event in
                guard let handler = self?.handler else { return }
                let event = PackOfEvents(middlewareEvents: event.messages)
                handler.handle(events: event)
        }
    }
}
