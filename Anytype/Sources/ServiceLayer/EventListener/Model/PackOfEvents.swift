import ProtobufMessages

struct PackOfEvents {
    let events: [Anytype_Event.Message]
    let localEvents: [LocalEvent]
    
    init(
        events: [Anytype_Event.Message] = [],
        localEvents: [LocalEvent] = []
    ) {
        self.events = events
        self.localEvents = localEvents
    }
    
    func enrichedWith(localEvents: [LocalEvent]) -> PackOfEvents {
        return PackOfEvents(
            events: events,
            localEvents: self.localEvents + localEvents
        )
    }
}
