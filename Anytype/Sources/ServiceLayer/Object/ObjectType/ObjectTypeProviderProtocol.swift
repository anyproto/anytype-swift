//
//  ObjectTypeProviderProtocol.swift
//  Anytype
//
//  Created by Konstantin Mordan on 03.06.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import BlocksModels

protocol ObjectTypeProviderProtocol {
    var supportedTypeUrls: [String] { get }
    var defaultObjectType: ObjectType { get }
    
    func isSupported(typeUrl: String) -> Bool
    func objectType(url: String?) -> ObjectType?
    
    func objectTypes(smartblockTypes: Set<SmartBlockType>) -> [ObjectType]
}
