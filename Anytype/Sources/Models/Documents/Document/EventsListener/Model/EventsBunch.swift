import ProtobufMessages
import BlocksModels

struct EventsBunch {
    let objectId: BlockId
    
    let middlewareEvents: [Anytype_Event.Message]
    let localEvents: [LocalEvent]
    
    func enrichedWith(localEvents: [LocalEvent]) -> EventsBunch {
        EventsBunch(
            objectId: self.objectId,
            middlewareEvents: self.middlewareEvents,
            localEvents: self.localEvents + localEvents
        )
    }
    
}

extension EventsBunch {
    
    init(objectId: BlockId, middlewareEvents: [Anytype_Event.Message]) {
        self.objectId = objectId
        self.middlewareEvents = middlewareEvents
        self.localEvents = []
    }
    
    init(objectId: BlockId, localEvents: [LocalEvent]) {
        self.objectId = objectId
        self.middlewareEvents = []
        self.localEvents = localEvents
    }
}
