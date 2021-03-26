//
//  BlockActionsService+List.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 19.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import BlocksModels
import UIKit

protocol ServiceLayerModule_BlockActionsServiceListProtocolDelete {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    func action(contextID: BlockId, blocksIds: [BlockId]) -> AnyPublisher<Success, Error>
}

/// We don't support fields now.
protocol ServiceLayerModule_BlockActionsServiceListProtocolSetFields {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    /// TODO: Add our fields model.
    typealias Field = String
    func action(contextID: BlockId, blockFields: [String]) -> AnyPublisher<Success, Error>
//    func action(contextID: BlockId, blockFields: [Anytype_Rpc.BlockList.Set.Fields.Request.BlockField]) -> AnyPublisher<Success, Error>
}

protocol ServiceLayerModule_BlockActionsServiceListProtocolSetTextStyle {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    typealias Style = TopLevel.AliasesMap.BlockContent.Text.ContentType
    func action(contextID: BlockId, blockIds: [BlockId], style: Style) -> AnyPublisher<Success, Error>
}
// TODO: Later enable it and remove old services that works with Duplicates.
//protocol ServiceLayerModule_BlockActionsServiceListProtocolDuplicate {
//    associatedtype Success
//    func action() -> AnyPublisher<Success, Error>
//}
protocol ServiceLayerModule_BlockActionsServiceListProtocolSetBackgroundColor {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    func action(contextID: BlockId, blockIds: [BlockId], color: String) -> AnyPublisher<Success, Error>
}
protocol ServiceLayerModule_BlockActionsServiceListProtocolSetAlign {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    typealias Alignment = TopLevel.AliasesMap.Alignment
    func action(contextID: BlockId, blockIds: [BlockId], alignment: Alignment) -> AnyPublisher<Success, Error>
}
protocol ServiceLayerModule_BlockActionsServiceListProtocolSetDivStyle {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    typealias Style = TopLevel.AliasesMap.BlockContent.Divider.Style
    func action(contextID: BlockId, blockIds: [BlockId], style: Style) -> AnyPublisher<Success, Error>
}
protocol ServiceLayerModule_BlockActionsServiceListProtocolSetPageIsArchived {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    func action(contextID: BlockId, blockIds: [BlockId], isArchived: Bool) -> AnyPublisher<Success, Error>
}
protocol ServiceLayerModule_BlockActionsServiceListProtocolDeletePage {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    func action(blockIds: [String]) -> AnyPublisher<Success, Error>
}


protocol ServiceLayerModule_BlockActionsServiceListProtocol {
    associatedtype Delete: ServiceLayerModule_BlockActionsServiceListProtocolDelete
    associatedtype SetFields: ServiceLayerModule_BlockActionsServiceListProtocolSetFields
    associatedtype SetTextStyle: ServiceLayerModule_BlockActionsServiceListProtocolSetTextStyle
    associatedtype Duplicate // : ServiceLayerModule_BlockActionsServiceListProtocolDuplicate /// Add conformance later.
    associatedtype SetBackgroundColor: ServiceLayerModule_BlockActionsServiceListProtocolSetBackgroundColor
    associatedtype SetAlign: ServiceLayerModule_BlockActionsServiceListProtocolSetAlign
    associatedtype SetDivStyle: ServiceLayerModule_BlockActionsServiceListProtocolSetDivStyle
    associatedtype SetPageIsArchived: ServiceLayerModule_BlockActionsServiceListProtocolSetPageIsArchived
    associatedtype DeletePage: ServiceLayerModule_BlockActionsServiceListProtocolDeletePage
    
    var delete: Delete {get}
    var setFields: SetFields {get}
    var setTextStyle: SetTextStyle {get}
    var duplicate: Duplicate {get}
    var setBackgroundColor: SetBackgroundColor {get}
    var setAlign: SetAlign {get}
    var setDivStyle: SetDivStyle {get}
    var setPageIsArchived: SetPageIsArchived {get}
    var deletePage: DeletePage {get}

    typealias BlockId = TopLevel.AliasesMap.BlockId

    /// Set block  color
    /// - Parameters:
    ///   - contextID: page id
    ///   - blockIds: id block
    ///   - color: block  color
    func setBlockColor(contextID: BlockId, blockIds: [BlockId], color: String) -> AnyPublisher<ServiceLayerModule.Success, Error>
}
