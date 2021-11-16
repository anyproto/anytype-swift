//
//  ObjectRelationsStorage.swift
//  Anytype
//
//  Created by Denis Batvinkin on 16.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import AnytypeCore


final class ObjectRelationsStorage {

    private var allRelationsStorage = SynchronizedArray<ObjectRelationData>()
    private var featuredRelationsStorage = SynchronizedArray<ObjectRelationData>()
    private var otherRelationsStorage = SynchronizedArray<ObjectRelationData>()

    public init(allRelations: [ObjectRelationData], otherRelations: [ObjectRelationData], featuredRelations: [ObjectRelationData]) {
        self.allRelationsStorage = SynchronizedArray<ObjectRelationData>(array: allRelations)
        self.otherRelationsStorage = SynchronizedArray<ObjectRelationData>(array: otherRelations)
        self.featuredRelationsStorage = SynchronizedArray<ObjectRelationData>(array: featuredRelations)
    }
}

extension ObjectRelationsStorage: ObjectRelationsStorageProtocol {

    var allObjectRelations: [ObjectRelationData] {
        allRelationsStorage.array
    }

    var featuredObjectRelations: [ObjectRelationData] {
        featuredRelationsStorage.array
    }

    var otherObjectRelations: [ObjectRelationData] {
        otherRelationsStorage.array
    }

}
