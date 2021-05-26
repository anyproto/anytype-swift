import Foundation
import ProtobufMessages
import BlocksModels
import Combine
import os

typealias ContextId = String

/// Default model of events.
struct PackOfEvents {
    var contextId: ContextId
    var events: [Anytype_Event.Message] = []
    
    /// TODO: Remove it later.
    var ourEvents: [OurEvent] = []
}
