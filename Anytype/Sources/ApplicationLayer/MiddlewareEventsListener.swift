import ProtobufMessages
import Foundation
import AnytypeCore

private extension LoggerCategory {
    static let eventListening: Self = "EventListening"
}

/// receive events from middleware and broadcast throught notification center
final class MiddlewareEventsListener: NSObject {
    
    private let wrapper = ServiceMessageHandlerAdapter()

    func startListening() {
        _ = wrapper.with(value: self)
    }
}

extension MiddlewareEventsListener: ServiceEventsHandlerProtocol {
    
    func handle(_ data: Data?) {
        guard
            let rawEvent = data,
            let event = try? Anytype_Event(serializedData: rawEvent)
        else { return }
        
        logEvent(event: event)
        
        EventsBunch(event: event).send()
    }
    
    
    private func logEvent(event: Anytype_Event) {
        guard FeatureFlags.middlewareLogs else { return }
        
        let filteredEvents = event.messages.filter(isNotNoise)
        AnytypeLogger.create(.eventListening).debug("Middleware events:\n\(filteredEvents)")
    }
     
    private func isNotNoise(_ event: Anytype_Event.Message) -> Bool {
        guard let value = event.value else { return false }
        switch value {
        case .threadStatus: return false
        default: return true
        }
    }
}
