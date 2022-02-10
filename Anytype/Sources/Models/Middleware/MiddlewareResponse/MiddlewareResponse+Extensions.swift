import ProtobufMessages
import AnytypeCore

extension MiddlewareResponse {
    
    var asEventsBunch: EventsBunch {
        EventsBunch(
            contextId: self.contextId,
            middlewareEvents: self.messages
        )
    }
    
}

