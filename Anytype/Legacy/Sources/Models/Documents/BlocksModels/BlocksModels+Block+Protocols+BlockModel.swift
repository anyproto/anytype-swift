//
//  BlocksModels+Block+Protocols+BlockModel.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation

// MARK: - BlockModel
protocol BlocksModelsHasInformationProtocol {
    var information: BlocksModelsInformationModelProtocol { get set }
    init(information: BlocksModelsInformationModelProtocol)
}

protocol BlocksModelsHasParentProtocol {
    typealias BlockId = BlocksModels.Aliases.BlockId
    var parent: BlockId? {get set}
}

protocol BlocksModelsHasKindProtocol {
    typealias BlockKind = BlocksModels.Aliases.BlockKind
    var kind: BlockKind {get}
}
