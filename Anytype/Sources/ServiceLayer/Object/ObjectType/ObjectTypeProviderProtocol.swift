//
//  ObjectTypeProviderProtocol.swift
//  Anytype
//
//  Created by Konstantin Mordan on 03.06.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import ProtobufMessages

protocol ObjectTypeProviderProtocol {
    static var supportedTypeUrls: [String] { get }
    static var defaultObjectType: ObjectType { get }
    
    static func isSupported(typeUrl: String) -> Bool
    static func objectType(url: String?) -> ObjectType?
    
    static func objectTypes(smartblockTypes: [Anytype_Model_SmartBlockType]) -> [ObjectType]
}
