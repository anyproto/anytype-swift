//
//  DetailsProviderBuilderProtocol.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 21.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

public protocol DetailsProviderBuilderProtocol {
    
    func empty() -> DetailsProviderProtocol
    
    func filled(with list: [DetailsEntry<AnyHashable>]) -> DetailsProviderProtocol
    
}
