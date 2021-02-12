//
//  BlockActionsService+Other.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 06.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import BlocksModels

// MARK: - Actions Protocols
/// Protocol for set divider style.
protocol ServiceLayerModule_BlockActionsServiceOtherProtocolSetDividerStyle {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    typealias Style = TopLevel.AliasesMap.BlockContent.Divider.Style
    func action(contextID: BlockId, blockIds: [BlockId], style: Style) -> AnyPublisher<Success, Error>
}

// MARK: - Service Protocol
/// Protocol for Other blocks actions services.
protocol ServiceLayerModule_BlockActionsServiceOtherProtocol {
    associatedtype SetDividerStyle: ServiceLayerModule_BlockActionsServiceOtherProtocolSetDividerStyle
    var setDividerStyle: SetDividerStyle {get}
}
