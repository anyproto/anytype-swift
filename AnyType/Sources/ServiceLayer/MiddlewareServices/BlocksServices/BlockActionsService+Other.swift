//
//  BlockActionsService+Other.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 06.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import SwiftProtobuf

fileprivate typealias Namespace = ServiceLayerModule.Other

// MARK: - Actions Protocols
/// Protocol for set divider style.
protocol ServiceLayerModule_BlockActionsServiceOtherProtocolSetDividerStyle {
    associatedtype Success
    func action(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Div.Style) -> AnyPublisher<Success, Error>
}

// MARK: - Service Protocol
/// Protocol for Other blocks actions services.
protocol ServiceLayerModule_BlockActionsServiceOtherProtocol {
    associatedtype SetDividerStyle: ServiceLayerModule_BlockActionsServiceOtherProtocolSetDividerStyle
    var setDividerStyle: SetDividerStyle {get}
}

/// Concrete service that adopts OtherBlock actions service.
/// NOTE: Use it as default service IF you want to use default functionality.
// MARK: - OtherBlockActionsService

extension Namespace {
    class BlockActionsService: ServiceLayerModule_BlockActionsServiceOtherProtocol {
        
        var setDividerStyle: SetDividerStyle = .init()
    }
}

// MARK: - OtherBlockActionsService / Actions
extension Namespace.BlockActionsService {
    /// Structure that adopts `CreatePage` action protocol
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`.
    struct SetDividerStyle: ServiceLayerModule_BlockActionsServiceOtherProtocolSetDividerStyle {
        typealias Success = ServiceLayerModule.Success
        func action(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Div.Style) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Set.Div.Style.Service.invoke(contextID: contextID, blockIds: blockIds, style: style).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
        }
    }
}

