//
//  EventListening+NotificationEventListener.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 28.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import ProtobufMessages

extension EventListening {
    class NotificationEventListener<EventHandlerType: EventHandlerProtocol>: NewEventListener where EventHandlerType.EventsContainer == EventListening.PackOfEvents {

        private var subscription: AnyCancellable?

        weak var handler: EventHandlerType?

        init(handler: EventHandlerType) {
            self.handler = handler
        }
        
        // TODO: Make it AnyPublisher?
        func process(messages: [Anytype_Event.Message]) {
            guard let handler = self.handler else { return }
            let event: PackOfEvents = .init(contextId: "", events: messages, ourEvents: [])
            handler.handle(events: event)
        }
        
        func receive(contextId: String) {
            self.subscription = NotificationCenter.Publisher(center: .default, name: .middlewareEvent, object: nil)
                .compactMap { $0.object as? Anytype_Event }
                .filter( {$0.contextID == contextId} )
                .sink { [weak self] event in
                    // TODO: later pack them into PackOfEvents?
                    guard let handler = self?.handler else { return }
                    let event: PackOfEvents = .init(contextId: contextId, events: event.messages, ourEvents: [])
                    handler.handle(events: event)
            }
        }
    }
}
