//
//  DetailsStorage.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 21.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

final class DetailsStorage {
    
    private var models: [BlockId: DetailsModel] = [:]
    
}

// MARK: - DetailsContainerModelProtocol

extension DetailsStorage: DetailsStorageProtocol {
    
    func list() -> AnyIterator<BlockId> {
        .init(models.keys.makeIterator())
    }
    
    func choose(by id: BlockId) -> DetailsActiveRecordModelProtocol? {
        guard let value = models[id] else { return nil }
        
        return DetailsActiveRecord(container: self, nestedModel: value)
    }
    
    func get(by id: BlockId) -> DetailsModelProtocol? {
        models[id]
    }
    
    func remove(_ id: BlockId) {
        guard models.keys.contains(id) else {
            assertionFailure("We shouldn't delete models if they are not in the collection. Skipping...")
            return
        }
        
        models.removeValue(forKey: id)
    }
    
    func add(_ model: DetailsModelProtocol) {
        let ourModel = DetailsModel(details: model.details)
        
        guard let parent = model.parent else {
            assertionFailure("We shouldn't add details with empty parent id. Skipping...")
            return
        }
        
        if models[parent] != nil {
            assertionFailure("We shouldn't replace details by add operation. Skipping...")
            return
        }
        
        models[parent] = ourModel
    }
    
}
