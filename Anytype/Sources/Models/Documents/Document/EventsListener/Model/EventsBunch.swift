import ProtobufMessages
import BlocksModels

struct EventsBunch {
    let contextId: BlockId
    
    let middlewareEvents: [Anytype_Event.Message]
    let localEvents: [LocalEvent]
    
    func send() {
        NotificationCenter.default.post(name: .middlewareEvent, object: self)
    }
    
}

extension EventsBunch {
    
    init(contextId: BlockId, middlewareEvents: [Anytype_Event.Message]) {
        self.contextId = contextId
        self.middlewareEvents = middlewareEvents
        self.localEvents = []
    }
    
    init(contextId: BlockId, localEvents: [LocalEvent]) {
        self.contextId = contextId
        self.middlewareEvents = []
        self.localEvents = localEvents
    }
    
    init(event: Anytype_Event) {
        self.init(contextId: event.contextID, middlewareEvents: event.messages)
    }
    
    init(event: Anytype_ResponseEvent) {
        self.init(contextId: event.contextID, middlewareEvents: event.messages)
    }
}

extension EventsBunch {

    func enrichedWith(localEvents: [LocalEvent]) -> EventsBunch {
        EventsBunch(
            contextId: self.contextId,
            middlewareEvents: self.middlewareEvents,
            localEvents: self.localEvents + localEvents
        )
    }
    
}
