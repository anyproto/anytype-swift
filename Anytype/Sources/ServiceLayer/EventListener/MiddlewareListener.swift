import ProtobufMessages
import Foundation
import os
import AnytypeCore

private extension LoggerCategory {
    static let eventListening: Self = "EventListening"
}

/// receive events from middleware and broadcast throught notification center
class MiddlewareListener: NSObject {
    private let wrapper = ServiceMessageHandlerAdapter()
    override init() {
        super.init()
        _ = self.wrapper.with(value: self)
    }
}

extension MiddlewareListener: ServiceEventsHandlerProtocol {
    func handle(_ data: Data?) {
        guard let rawEvent = data,
            let event = try? Anytype_Event(serializedData: rawEvent) else { return }
        
        let filteredEvents = event.messages.filter(isNotNoise)
        Logger.create(.eventListening).debug("Middleware events:\n\(filteredEvents)")
        
        NotificationCenter.default.post(name: .middlewareEvent, object: event)
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
