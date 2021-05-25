import Foundation
import ProtobufMessages
import BlocksModels
import Combine
import os

enum EventListening {
    typealias ContextId = String
}

extension EventListening {
    /// Default model of events.
    /// Use it when you would like to handle events.
    /// Plain `Anytype_Event*` events are deprecated.
    struct PackOfEvents {
        var contextId: String
        var events: [Anytype_Event.Message] = []
        /// TODO: Remove it later.
        /// Only for a shit.
        var ourEvents: [OurEvent] = []
        /// TODO: Maybe add initiator? (Account, who initiates events)
        /// Actually, whoever could send events. We should think about which events we should handle.
        /// Some events could come from other users.
        static func from(event: Anytype_Event) -> Self {
            .init(contextId: event.contextID, events: event.messages)
        }
    }
}

extension EventListening.OurEvent {
    struct Focus {
        var blockId: String
        var position: BlockFocusPosition?
    }
    
    struct Text {
        var blockId: String
        var attributedString: NSAttributedString?
    }
    
    struct TextMerge {
        var blockId: String
    }

    struct Toggled {
        var blockId: String
    }
}

extension EventListening {
    enum OurEvent {
        case setFocus(Focus)
        case setText(Text)
        case setTextMerge(TextMerge)
        case setToggled(Toggled)
    }
}

protocol EventHandlerProtocol: AnyObject {
    func handle(events: EventListening.PackOfEvents)
}
