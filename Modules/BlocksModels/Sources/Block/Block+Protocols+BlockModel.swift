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
    var information: BlockInformation.InformationModel { get set }
    init(information: BlockInformation.InformationModel)
}

public protocol BlockHasParentProtocol {
    var parent: BlockId? {get set}
}

public protocol BlockHasKindProtocol {
    var kind: BlockKind {get}
}
