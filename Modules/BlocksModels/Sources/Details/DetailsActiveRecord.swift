//
//  DetailsActiveRecord.swift
//  BlocksModels
//
//  Created by Konstantin Mordan on 21.05.2021.
//  Copyright © 2021 Anytype. All rights reserved.
//

import Foundation
import Combine

final class DetailsActiveRecord {
    
    private weak var nestedContainer: DetailsStorage?
    private let nestedModel: DetailsModelProtocol
    
    // MARK: - Initializers
    
    init(container: DetailsStorage, nestedModel: DetailsModelProtocol) {
        self.nestedContainer = container
        self.nestedModel = nestedModel
    }
    
    required init(_ chosen: DetailsActiveRecord) {
        self.nestedContainer = chosen.nestedContainer
        self.nestedModel = chosen.nestedModel
    }

}

// MARK: - DetailsActiveRecordModelProtocol

extension DetailsActiveRecord: DetailsActiveRecordModelProtocol {
    
    var container: DetailsStorageProtocol? {
        self.nestedContainer
    }
    
    var detailsModel: DetailsModelProtocol {
        self.nestedModel
    }
    
    func changeInformationPublisher() -> AnyPublisher<DetailsProviderProtocol, Never> {
        detailsModel.changeInformationPublisher
    }
    
}
