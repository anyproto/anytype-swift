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

    private let objectId: String
        
    init(objectId: String) {
        self.objectId = objectId
    }
    
    func update(details: ObjectRawDetails) {
        let result = service.setDetails(contextID: objectId, details: details)
        
        guard let result = result else { return }

        NotificationCenter.default.post(
            name: .middlewareEvent,
            object: EventsBunch(objectId: objectId, middlewareEvents: result.messages)
        )
    }
}
