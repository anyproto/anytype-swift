import ProtobufMessages
import BlocksModels

struct PackOfEvents {
    let objectId: BlockId
    
    let middlewareEvents: [Anytype_Event.Message]
    let localEvents: [LocalEvent]
    
    func enrichedWith(localEvents: [LocalEvent]) -> PackOfEvents {
        PackOfEvents(
            objectId: self.objectId,
            middlewareEvents: self.middlewareEvents,
            localEvents: self.localEvents + localEvents
        )
    }
    
}

extension PackOfEvents {
    
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
