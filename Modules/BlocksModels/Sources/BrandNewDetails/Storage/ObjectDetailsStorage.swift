//
//  ObjectDetailsStorage.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 10.10.2021.
//  Copyright © 2021 Dmitry Lobanov. All rights reserved.
//

import Foundation
import AnytypeCore

public final class ObjectDetailsStorage {
    
    private var detailsStorage = SynchronizedDictionary<BlockId, ObjectDetails>()
    
    public init() {}
    
}

extension ObjectDetailsStorage: ObjectDetailsStorageProtocol {
    
    public func get(id: BlockId) -> ObjectDetails? {
        detailsStorage[id]
    }
    
    public func add(details: ObjectDetails, id: BlockId) {
        detailsStorage[id] = details
    }
    
}
