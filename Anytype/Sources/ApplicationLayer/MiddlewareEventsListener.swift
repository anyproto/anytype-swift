import ProtobufMessages
import Foundation
import Logger

/// receive events from middleware and broadcast throught notification center
final class MiddlewareEventsListener: NSObject {
    
    func startListening() {
        ServiceMessageHandlerAdapter.shared.addHandler(handler: self)
    }
}

extension MiddlewareEventsListener: ServiceEventsHandlerProtocol {
    
    func handle(_ event: Anytype_Event) async {
        await EventsBunch(event: event).send()
    }
}
