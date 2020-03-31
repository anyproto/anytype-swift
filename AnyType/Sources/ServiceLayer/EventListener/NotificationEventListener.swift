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
}
