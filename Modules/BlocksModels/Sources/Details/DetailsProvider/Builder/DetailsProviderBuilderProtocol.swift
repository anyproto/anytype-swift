//
//  DetailsProviderBuilderProtocol.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 21.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation

public protocol DetailsProviderBuilderProtocol {
    
    func filled(with list: [DetailsId: DetailsEntry<AnyHashable>]) -> DetailsProviderProtocol
    
    func filled(with detailsEntries: [DetailsEntry<AnyHashable>]) -> DetailsProviderProtocol
    
    
}
