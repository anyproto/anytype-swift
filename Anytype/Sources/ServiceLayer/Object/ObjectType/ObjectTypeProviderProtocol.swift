//
//  ObjectTypeProviderProtocol.swift
//  Anytype
//
//  Created by Konstantin Mordan on 03.06.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import BlocksModels

protocol ObjectTypeProviderProtocol: AnyObject {
    var supportedTypeIds: [String] { get }
    var defaultObjectType: ObjectType { get }
    
    func isSupported(typeId: String) -> Bool
    func objectType(id: String) -> ObjectType?
    
    func objectTypes(smartblockTypes: Set<SmartBlockType>) -> [ObjectType]
}
