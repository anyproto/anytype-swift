import ProtobufMessages
import Services
import Foundation

struct EventsBunch {
    let contextId: BlockId
    let middlewareEvents: [Anytype_Event.Message]
    let localEvents: [LocalEvent]

    func send() async {
        await EventBunchSubscribtion.default.sendEvent(events: self)
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
