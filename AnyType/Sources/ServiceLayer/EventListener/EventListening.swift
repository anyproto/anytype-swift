import Foundation
import ProtobufMessages
import Combine
import os

private extension LoggerCategory {
    static let eventListening: Self = "EventListening"
}

enum EventListening {
    typealias ContextId = String
}

extension EventListening {
    /// Recive events from middleware and broadcast throught notification center
    class RawListener: NSObject {
        private var wrapper: ProtobufMessages.ServiceMessageHandlerAdapter = .init()
        override init() {
            super.init()
            _ = self.wrapper.with(value: self)
        }
    }
}

extension EventListening.RawListener: ProtobufMessages.ServiceEventsHandlerProtocol {
    // TODO: Don't forget to remove it. We only add this method to hide logs from thread status.
    private func filterNecessary(_ event: Anytype_Event.Message) -> Bool {
        guard let value = event.value else { return false }
        switch value {
        case .threadStatus: return false
        default: return true
        }
    }
    
    func handle(_ data: Data?) {
        guard let rawEvent = data,
            let event = try? Anytype_Event(serializedData: rawEvent) else { return }
        
        let necessaryEvents = event.messages.filter(self.filterNecessary)
        Logger.create(.eventListening).debug("handleEvents. Necessary events are \(necessaryEvents)")
        
        // TODO: Add filter by messages here???
        NotificationCenter.default.post(name: .middlewareEvent, object: event)
    }
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
    // TODO: remove all payload as it unnecessary struct
    struct Focus {
        struct Payload {
            enum Position {
                case beginning
                case end
                case at(Int)
            }
            var blockId: String
            var position: Position?
        }
        var payload: Payload
    }
    
    struct Text {
        struct Payload {
            var blockId: String
            var attributedString: NSAttributedString?
        }
        var payload: Payload
    }
    
    struct TextMerge {
        struct Payload {
            var blockId: String
        }
        var payload: Payload
    }
    struct Toggled {
        struct Payload {
            var blockId: String
        }
        var payload: Payload
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
    associatedtype EventsContainer
    func handle(events: EventsContainer)
}

protocol NewEventListener {
    associatedtype Handler: EventHandlerProtocol
    typealias ContextID = String

    var handler: Self.Handler? { get }
    func receive(contextId: ContextID)
}
