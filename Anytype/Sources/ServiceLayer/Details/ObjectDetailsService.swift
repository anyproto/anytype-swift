//
//  ObjectDetailsService.swift
//  Anytype
//
//  Created by Konstantin Mordan on 15.07.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import BlocksModels
import Combine

final class ObjectDetailsService {
    
    private let service = ObjectActionsService()
    private let eventHandler: EventHandler

    private let objectId: String
        
    init(eventHandler: EventHandler, objectId: String) {
        self.eventHandler = eventHandler
        self.objectId = objectId
    }
    
    func update(details: RawDetailsData) {
        let result = service.syncSetDetails(contextID: objectId, details: details)
        
        guard let result = result else { return }

        eventHandler.handle(
            events: PackOfEvents(middlewareEvents: result.messages)
        )
    }
}
