//
//  NotificationEventListener.swift
//  AnyType
//
//  Created by Batvinkin Denis on 22.03.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine

// TODO: I don't like how we handle middleware events, think how it could be improved
/// NotificationEventListener  will not captures its event handler and we could safely do following self.handler = NotificationEventListener.init(handler: self)
class NotificationEventListener<EventHandlerType: EventHandler>: EventListener where EventHandlerType.Event == Anytype_Event.Message.OneOf_Value {

    private var cancallableEvents: AnyCancellable?

    weak var handler: EventHandlerType?

    init(handler: EventHandlerType) {
        self.handler = handler
    }
    
    // TODO: Make it AnyPublisher?
    func process(messages: [Anytype_Event.Message]) {
        guard let handler = self.handler else { return }
        messages.compactMap(\.value).forEach(handler.handleEvent(event:))
    }
    
    func receive(contextId: String) {
        cancallableEvents = NotificationCenter.Publisher(center: .default, name: .middlewareEvent, object: nil)
            .compactMap { $0.object as? Anytype_Event }
            .filter( {$0.contextID == contextId} )
            .map(\.messages)
            .sink { [weak self] eventMessages in
                guard let handler = self?.handler else { return }
                eventMessages.compactMap(\.value).forEach(handler.handleEvent(event:))
        }
    }
    
    func receive() {
        cancallableEvents = NotificationCenter.Publisher(center: .default, name: .middlewareEvent, object: nil)
            .compactMap { $0.object as? Anytype_Event }
            .map(\.messages)
            .sink { [weak self] eventMessages in
                guard let handler = self?.handler else { return }
                eventMessages.compactMap(\.value).forEach(handler.handleEvent(event:))
        }
    }
}

extension EventListening {
    class NotificationEventListener<EventHandlerType: NewEventHandler>: NewEventListener where EventHandlerType.Event == Anytype_Event.Message.OneOf_Value {

        private var subscription: AnyCancellable?

        weak var handler: EventHandlerType?

        init(handler: EventHandlerType) {
            self.handler = handler
        }
        
        // TODO: Make it AnyPublisher?
        func process(messages: [Anytype_Event.Message]) {
            guard let handler = self.handler else { return }
            handler.handle(events: messages.compactMap(\.value))
        }
        
        func receive(contextId: String) {
            self.subscription = NotificationCenter.Publisher(center: .default, name: .middlewareEvent, object: nil)
                .compactMap { $0.object as? Anytype_Event }
                .filter( {$0.contextID == contextId} )
                .sink { [weak self] event in
                    // TODO: later pack them into PackOfEvents?
                    guard let handler = self?.handler else { return }
                    handler.handle(events: event.messages.compactMap(\.value))
            }
        }
    }
}
