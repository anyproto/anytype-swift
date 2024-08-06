import ProtobufMessages
import Foundation
import Logger

protocol MiddlewareEventsListenerProtocol: AnyObject {
    func startListening()
}

/// receive events from middleware and broadcast throught notification center
final class MiddlewareEventsListener: NSObject, MiddlewareEventsListenerProtocol, ServiceEventsHandlerProtocol {
    
    func startListening() {
        ServiceMessageHandlerAdapter.shared.addHandler(handler: self)
    }
    
    // MARK: - ServiceEventsHandlerProtocol
    
    func handle(_ event: Anytype_Event) async {
        await EventsBunch(event: event).send()
    }
}
