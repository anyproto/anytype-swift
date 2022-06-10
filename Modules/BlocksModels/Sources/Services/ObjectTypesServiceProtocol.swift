//
//  ObjectTypesServiceProtocol.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 10.06.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation

public protocol ObjectTypesServiceProtocol {
    
    func obtainObjectTypes() -> Set<ObjectType>
    
}
