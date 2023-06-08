import ProtobufMessages
import Foundation
import Logger

/// receive events from middleware and broadcast throught notification center
final class MiddlewareEventsListener: NSObject {
    
    private let wrapper = ServiceMessageHandlerAdapter()

    func startListening() {
        _ = wrapper.with(value: self)
    }
}

extension MiddlewareEventsListener: ServiceEventsHandlerProtocol {
    
    func handle(_ event: Anytype_Event) {
        EventsBunch(event: event).send()
    }
}
