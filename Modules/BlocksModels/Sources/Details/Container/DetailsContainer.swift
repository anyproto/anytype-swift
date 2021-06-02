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
        guard details[id] == nil else {
            assertionFailure("We shouldn't replace details by add operation. Skipping...")
            return
        }
        
        details[id] = model
    }
    
}
