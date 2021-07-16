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
    
    private var subscriptions: [AnyCancellable] = []
    
    init(eventHandler: EventHandler, objectId: String) {
        self.eventHandler = eventHandler
        self.objectId = objectId
    }
    
    func update(details: [DetailsKind: DetailsEntry<AnyHashable>]) {
        service.setDetails(
            contextID: objectId,
            details: details
        )
        .sinkWithDefaultCompletion("setDetails combletion") { [weak self] success in
            self?.eventHandler.handle(
                events: PackOfEvents(middlewareEvents: success.messages)
            )
        }
        .store(in: &subscriptions)
    }
}
