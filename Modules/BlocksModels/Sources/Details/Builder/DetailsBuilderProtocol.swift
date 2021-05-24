//
//  DetailsBuilderProtocol.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 21.05.2021.
//  Copyright © 2021 . All rights reserved.
//

import Foundation

public protocol DetailsBuilderProtocol {
    
    var detailsProviderBuilder: DetailsProviderBuilderProtocol { get }
    
    func emptyStorage() -> DetailsStorageProtocol
    
    // TODO: wtf?
    func build(information: DetailsProviderProtocol) -> DetailsModelProtocol
  
}

