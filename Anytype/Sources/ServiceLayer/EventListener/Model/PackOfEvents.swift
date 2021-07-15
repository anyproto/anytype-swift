import ProtobufMessages

struct PackOfEvents {
    let middlewareEvents: [Anytype_Event.Message]
    let localEvents: [LocalEvent]
    
    init(
        middlewareEvents: [Anytype_Event.Message] = [],
        localEvents: [LocalEvent] = []
    ) {
        self.middlewareEvents = middlewareEvents
        self.localEvents = localEvents
    }
    
    func enrichedWith(localEvents: [LocalEvent]) -> PackOfEvents {
        return PackOfEvents(
            middlewareEvents: middlewareEvents,
            localEvents: self.localEvents + localEvents
        )
    }
}
