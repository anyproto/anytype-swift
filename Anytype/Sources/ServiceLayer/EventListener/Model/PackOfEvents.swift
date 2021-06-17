import ProtobufMessages

typealias ContextId = String

struct PackOfEvents {
    var contextId: ContextId
    var events: [Anytype_Event.Message] = []
    
    /// TODO: Remove it later.
    var ourEvents: [OurEvent] = []
}
