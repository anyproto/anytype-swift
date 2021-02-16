//
//  Block+Protocols+BlockModel.swift
//  BlocksModels
//
//  Created by Dmitry Lobanov on 10.07.2020.
//  Copyright © 2020 Dmitry Lobanov. All rights reserved.
//

import Foundation
import Combine

// MARK: - BlockModel
public protocol BlockHasInformationProtocol {
    var information: BlockInformationModelProtocol { get set }
    init(information: BlockInformationModelProtocol)
}

public protocol BlockHasParentProtocol {
    typealias BlockId = TopLevel.AliasesMap.BlockId
    var parent: BlockId? {get set}
}

public protocol BlockHasKindProtocol {
    typealias BlockKind = TopLevel.AliasesMap.BlockKind
    var kind: BlockKind {get}
}
