//
//  EventListening.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 20.05.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Lib
import Combine

enum EventListening {
    typealias ContextId = String
}

extension EventListening {
    /// Recive events from middleware and broadcast throught notification center
    class RawListener: NSObject {
        
        override init() {
            super.init()
            Lib.LibSetEventHandlerMobile(self)
        }
    }
}

extension EventListening.RawListener: LibMessageHandlerProtocol {
    
    func handle(_ b: Data?) {
        guard let rawEvent = b,
            let event = try? Anytype_Event(serializedData: rawEvent) else { return }
        
        print("event: \(event.messages)")
        
        // TODO: Add filter by messages here???
        NotificationCenter.default.post(name: .middlewareEvent, object: event)
    }
    
}

extension EventListening {
    struct PackOfEvents {
        var contextId: String
        var events: [Anytype_Event.Message] = []
        /// TODO: Maybe add initiator? (Account, who initiates events)
        /// Actually, whoever could send events. We should think about which events we should handle.
        /// Some events could come from other users.
        static func from(event: Anytype_Event) -> Self {
            .init(contextId: event.contextID, events: event.messages)
        }
    }
}

protocol NewEventHandler: class {
    associatedtype Event
    func handle(events: [Event])
}

protocol NewEventListener {
    associatedtype Handler: NewEventHandler
    typealias ContextID = String

    var handler: Self.Handler? { get }
    func receive(contextId: ContextID)
}

