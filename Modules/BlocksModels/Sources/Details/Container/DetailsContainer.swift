//
//  DetailsContainer.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 21.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

final class DetailsContainer {
    
    private var details: [String: LegacyDetailsModel] = [:]
    
}

// MARK: - DetailsContainerModelProtocol

extension DetailsContainer: DetailsContainerProtocol {
    
    func get(by id: String) -> LegacyDetailsModel? {
        details[id]
    }
    
    func add(model: LegacyDetailsModel, by id: ParentId) {
        guard details[id] == nil else { return }
        // It is ok if details already exists
        // For example, if we add new page block, we will receive .objectDetailsSet event
        // then store details first time
        // and then we will receive .blockAdd and store details second time
        details[id] = model
    }
    
}
