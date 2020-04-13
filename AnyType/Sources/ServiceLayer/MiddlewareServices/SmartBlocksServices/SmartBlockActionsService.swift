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

// MARK: - Service Protocol
/// Protocol for SmartBlock actions services.
protocol SmartBlockActionsServiceProtocol {
    associatedtype CreatePage: SmartBlockActionsServiceProtocolCreatePage
    
    var createPage: CreatePage {get}
}

/// Concrete service that adopts SmartBlock actions service.
/// NOTE: Use it as default service IF you want to use desired functionality.
// MARK: - SmartBlockActionsService
class SmartBlockActionsService: SmartBlockActionsServiceProtocol {
    
    var createPage: CreatePage = .init()
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
            return Anytype_Rpc.Block.CreatePage.Service.invoke(contextID: contextID, targetID: targetID, details: details, position: position).map({Success.init(blockId: $0.blockID, targetId: $0.targetID)}).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()            
        }
    }
}

