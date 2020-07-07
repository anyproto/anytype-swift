//
//  OtherBlockActionsService.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 06.07.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import SwiftProtobuf

// MARK: - Actions Protocols
/// Protocol for set divider style.
protocol NewModel_OtherBlockActionsServiceProtocolSetDividerStyle {
    associatedtype Success
    func action(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Div.Style) -> AnyPublisher<Success, Error>
}

// MARK: - Service Protocol
/// Protocol for SmartBlock actions services.
protocol NewModel_OtherBlockActionsServiceProtocol {
    associatedtype SetDividerStyle: NewModel_OtherBlockActionsServiceProtocolSetDividerStyle
    var setDividerStyle: SetDividerStyle {get}
}

/// Concrete service that adopts OtherBlock actions service.
/// NOTE: Use it as default service IF you want to use default functionality.
// MARK: - SmartBlockActionsService

fileprivate typealias Namespace = ServiceLayerModule

extension Namespace {
    class OtherBlockActionsService: NewModel_OtherBlockActionsServiceProtocol {
        
        var setDividerStyle: SetDividerStyle = .init()
    }
}

// MARK: - SmartBlockActionsService / CreatePage
extension Namespace.OtherBlockActionsService {
    typealias Success = ServiceLayerModule.Success
    /// Structure that adopts `CreatePage` action protocol
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`.
    struct SetDividerStyle: NewModel_OtherBlockActionsServiceProtocolSetDividerStyle {
        func action(contextID: String, blockIds: [String], style: Anytype_Model_Block.Content.Div.Style) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Set.Div.Style.Service.invoke(contextID: contextID, blockIds: blockIds, style: style).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
        }
    }
}

