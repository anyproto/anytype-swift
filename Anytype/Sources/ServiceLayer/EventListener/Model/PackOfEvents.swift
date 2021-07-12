import ProtobufMessages

struct PackOfEvents {
    let contextId: String
    let events: [Anytype_Event.Message]
    let localEvents: [LocalEvent]
    
    init(
        contextId: String,
        events: [Anytype_Event.Message],
        localEvents: [LocalEvent] = []
    ) {
        self.contextId = contextId
        self.events = events
        self.localEvents = localEvents
    }
    
    func enrichedWith(localEvents: [LocalEvent]) -> PackOfEvents {
        return PackOfEvents(
            contextId: contextId,
            events: events,
            localEvents: self.localEvents + localEvents
        )
    }
}
