//
//  LegacyDetailsModel.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 21.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import Combine

public final class LegacyDetailsModel {
    
    @Published public var detailsData: DetailsData
    
    public required init(detailsData: DetailsData) {
        self.detailsData = detailsData
    }
    
}

//MARK: - LegacyDetailsModelProtocol

public extension LegacyDetailsModel {
    
    var changeInformationPublisher: AnyPublisher<DetailsData, Never> {
        $detailsData.eraseToAnyPublisher()
    }
    
}
