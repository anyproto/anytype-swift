//
//  ObjectDetailsStorageProtocol.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 10.10.2021.
//  Copyright © 2021 Dmitry Lobanov. All rights reserved.
//

import Foundation

public protocol ObjectDetailsStorageProtocol {
    
    func get(id: BlockId) -> ObjectDetails?
    func add(details: ObjectDetails, id: BlockId)
    
}
