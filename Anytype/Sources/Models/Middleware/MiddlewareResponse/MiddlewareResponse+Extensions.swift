import ProtobufMessages
import AnytypeCore

extension MiddlewareResponse {
    
    var asEventsBunch: EventsBunch {
        EventsBunch(
            objectId: self.contextId,
            middlewareEvents: self.messages
        )
    }
    
}

extension MiddlewareResponse {
    
    var addEvent: EventsBunch {
        let addEntryMessage = messages.first { $0.value == .blockAdd($0.blockAdd) }
        let localEvents: [LocalEvent] = addEntryMessage?.blockAdd.blocks.first.flatMap {
            [.setFocus(blockId: $0.id, position: .beginning)]
        } ?? []
        
        return EventsBunch(
            objectId: self.contextId,
            middlewareEvents: self.messages,
            localEvents: localEvents
        )
    }
    
}

