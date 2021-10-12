import ProtobufMessages
import Foundation
import AnytypeCore

private extension LoggerCategory {
    static let eventListening: Self = "EventListening"
}

/// receive events from middleware and broadcast throught notification center
final class MiddlewareEventsListener: NSObject {
    
    private let wrapper = ServiceMessageHandlerAdapter()
    
    override init() {
        super.init()
        
        _ = self.wrapper.with(value: self)
    }
}

extension MiddlewareEventsListener: ServiceEventsHandlerProtocol {
    
    func handle(_ data: Data?) {
        guard
            let rawEvent = data,
            let event = try? Anytype_Event(serializedData: rawEvent)
        else { return }
        
        let filteredEvents = event.messages.filter(isNotNoise)
        AnytypeLogger.create(.eventListening).debug("Middleware events:\n\(filteredEvents)")
        
        let events = PackOfEvents(
            objectId: event.contextID,
            middlewareEvents: event.messages
        )
        NotificationCenter.default.post(name: .middlewareEvent, object: events)
    }
    
    
    // TODO: Don't forget to remove it. We only add this method to hide logs from thread status.
    private func isNotNoise(_ event: Anytype_Event.Message) -> Bool {
        guard let value = event.value else { return false }
        switch value {
        case .threadStatus: return false
        default: return true
        }
    }
}
