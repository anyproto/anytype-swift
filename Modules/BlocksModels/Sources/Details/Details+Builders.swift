//
//  Details+Builders.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation
import os

private extension Logging.Categories {
    static let blocksModelsDetailsBuilder: Self = "BlocksModels.Details.Builder"
}

public protocol DetailsBuilderProtocol {
    func build(list: [DetailsModelProtocol]) -> DetailsContainerModelProtocol
    func emptyContainer() -> DetailsContainerModelProtocol
    func build(information: DetailsInformationModelProtocol) -> DetailsModelProtocol
    var informationBuilder: DetailsInformationBuilderProtocol {get}
}

extension Details {
    class Builder: DetailsBuilderProtocol {
        
        typealias BlockId = TopLevel.DetailsId
        typealias Model = DetailsModel
        typealias CurrentContainer = Container
                
        func build(list: [DetailsModelProtocol]) -> DetailsContainerModelProtocol {
            let container: CurrentContainer = .init()
            list.forEach(container.add(_:))
            return container
        }
        
        func emptyContainer() -> DetailsContainerModelProtocol {
            build(list: [])
        }
        
        func build(information: DetailsInformationModelProtocol) -> DetailsModelProtocol {
            Model.init(details: information)
        }
        
        var informationBuilder: DetailsInformationBuilderProtocol = Information.Builder.init()
    }
}
