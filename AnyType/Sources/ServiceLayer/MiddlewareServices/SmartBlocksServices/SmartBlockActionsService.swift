//
//  SmartBlockActionsService.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 10.04.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import SwiftProtobuf

// MARK: - Actions Protocols
/// Protocol for create page action.
/// NOTE: `CreatePage` action will return block of type `.link(.page)`. (!!!)
protocol SmartBlockActionsServiceProtocolCreatePage {
    associatedtype Success
    func action(contextID: String, targetID: String, details: Google_Protobuf_Struct, position: Anytype_Model_Block.Position) -> AnyPublisher<Success, Error>
}

/// Protocol for set details action.
/// NOTE: You have to convert value to List<Anytype_Rpc.Block.Set.Details.Detail>.
protocol SmartBlockActionsServiceProtocolSetDetails {
    func action(contextID: String, details: [Anytype_Rpc.Block.Set.Details.Detail]) -> AnyPublisher<Void, Error>
}

// MARK: - Service Protocol
/// Protocol for SmartBlock actions services.
protocol SmartBlockActionsServiceProtocol {
    associatedtype CreatePage: SmartBlockActionsServiceProtocolCreatePage
    associatedtype SetDetails: SmartBlockActionsServiceProtocolSetDetails
    
    var createPage: CreatePage {get}
    var setDetails: SetDetails {get}
}

/// Concrete service that adopts SmartBlock actions service.
/// NOTE: Use it as default service IF you want to use desired functionality.
// MARK: - SmartBlockActionsService
class SmartBlockActionsService: SmartBlockActionsServiceProtocol {
    
    var createPage: CreatePage = .init()
    var setDetails: SetDetails = .init()
}

// MARK: - SmartBlockActionsService / CreatePage
extension SmartBlockActionsService {
    
    /// Structure that adopts `CreatePage` action protocol
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`.
    struct CreatePage: SmartBlockActionsServiceProtocolCreatePage {
        struct Success {
            var blockId: String
            var targetId: String
        }
        func action(contextID: String, targetID: String, details: Google_Protobuf_Struct, position: Anytype_Model_Block.Position) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.CreatePage.Service.invoke(contextID: contextID, targetID: targetID, details: details, position: position).map({Success.init(blockId: $0.blockID, targetId: $0.targetID)}).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
}

// MARK: - SmartBlockActionsService / SetDetails
extension SmartBlockActionsService {
    struct SetDetails: SmartBlockActionsServiceProtocolSetDetails {
        func action(contextID: String, details: [Anytype_Rpc.Block.Set.Details.Detail]) -> AnyPublisher<Void, Error> {
            Anytype_Rpc.Block.Set.Details.Service.invoke(contextID: contextID, details: details).successToVoid().subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
}
