//
//  DetailsModelProtocol.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 21.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import Combine

// MARK: - DetailsModel
public protocol DetailsModelProtocol {
    
    var changeInformationPublisher: AnyPublisher<DetailsProviderProtocol, Never> { get }

    var detailsProvider: DetailsProviderProtocol { get set }
    
    var parent: ParentId? { get set }
        
}
