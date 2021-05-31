//
//  DetailsContainer.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 21.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

final class DetailsContainer {
    
    private var details: [String: DetailsModel] = [:]
    
}

// MARK: - DetailsContainerModelProtocol

extension DetailsContainer: DetailsContainerProtocol {
    
    func get(by id: String) -> DetailsModelProtocol? {
        details[id]
    }
    
    func add(_ model: DetailsModelProtocol) {
        let ourModel = DetailsModel(detailsProvider: model.detailsProvider)
        
        guard let parent = model.parent else {
            assertionFailure("We shouldn't add details with empty parent id. Skipping...")
            return
        }
        
        if details[parent] != nil {
            assertionFailure("We shouldn't replace details by add operation. Skipping...")
            return
        }
        
        details[parent] = ourModel
    }
    
}
