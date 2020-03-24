//
//  EventListener.swift
//  AnyType
//
//  Created by Denis Batvinkin on 08.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import Lib
import Combine


/// Middleware event handler
protocol EventHandler: class {
    associatedtype Event
    func handleEvent(event: Event)
}

/// Middleware events listener
protocol EventListener {
    associatedtype Handler: EventHandler
    typealias ContextID = String

    var handler: Self.Handler? { get }
    func receive(contextId: ContextID)
}

/// Recive events from middleware and broadcast throught notification center
class RawEventListener: NSObject {
    
    override init() {
        super.init()
        Lib.LibSetEventHandlerMobile(self)
    }
}

extension RawEventListener: LibMessageHandlerProtocol {
    
    func handle(_ b: Data?) {
        guard let rawEvent = b,
            let event = try? Anytype_Event(serializedData: rawEvent) else { return }
        
        print("event: \(event.messages)")
        
        // TODO: Add filter by messages here???
        NotificationCenter.default.post(name: .middlewareEvent, object: event)
    }
    
}
