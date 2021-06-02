//
//  DetailsContainerProtocol.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 21.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

public protocol DetailsContainerProtocol {
    
    func get(by id: ParentId) -> LegacyDetailsModel?
    func add(model: LegacyDetailsModel, by id: ParentId)
    
}
