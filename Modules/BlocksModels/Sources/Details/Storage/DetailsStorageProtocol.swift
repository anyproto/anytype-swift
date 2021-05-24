//
//  DetailsContainerProtocol.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 21.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

public protocol DetailsStorageProtocol {
    
    func list() -> AnyIterator<DetailsId>
    
    func choose(by id: DetailsId) -> DetailsActiveRecordModelProtocol?
    func get(by id: DetailsId) -> DetailsModelProtocol?
    func remove(_ id: DetailsId)
    func add(_ model: DetailsModelProtocol)
    
}
