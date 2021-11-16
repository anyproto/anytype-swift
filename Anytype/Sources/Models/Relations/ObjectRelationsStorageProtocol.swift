//
//  ObjectRelationsStorageProtocol.swift
//  Anytype
//
//  Created by Denis Batvinkin on 16.11.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

protocol ObjectRelationsStorageProtocol {
    var allObjectRelations: [ObjectRelationData] { get }
    var featuredObjectRelations: [ObjectRelationData] { get }
    var otherObjectRelations: [ObjectRelationData] { get }
}
