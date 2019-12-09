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

enum EventListenerFilter {
    case all
    case account
}

class EventListener: NSObject {
    
    init(filter: EventListenerFilter) {
        super.init()
        Lib.LibSetEventHandlerMobile(self)
    }
}

extension EventListener: LibMessageHandlerProtocol {
    
    func handle(_ b: Data?) {
        guard let rawEvent = b,
            let event = try? Anytype_Event(serializedData: rawEvent)
        else { return }
        
//        event.messages.first(where: { $0.accountShow.})
    }
    
}
