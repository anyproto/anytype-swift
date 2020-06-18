//
//  SmartBlockActionsService+New.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 14.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import SwiftProtobuf

// MARK: - Actions Protocols
/// Protocol for create page action.
/// NOTE: `CreatePage` action will return block of type `.link(.page)`. (!!!)
protocol NewModel_SmartBlockActionsServiceProtocolCreatePage {
    associatedtype Success
    func action(contextID: String, targetID: String, details: Google_Protobuf_Struct, position: Anytype_Model_Block.Position) -> AnyPublisher<Success, Error>
}

/// Protocol for set details action.
/// NOTE: You have to convert value to List<Anytype_Rpc.Block.Set.Details.Detail>.
protocol NewModel_SmartBlockActionsServiceProtocolSetDetails {
    func action(contextID: String, details: [Anytype_Rpc.Block.Set.Details.Detail]) -> AnyPublisher<Void, Error>
}

// MARK: - Service Protocol
/// Protocol for SmartBlock actions services.
protocol NewModel_SmartBlockActionsServiceProtocol {
    associatedtype CreatePage: NewModel_SmartBlockActionsServiceProtocolCreatePage
    associatedtype SetDetails: NewModel_SmartBlockActionsServiceProtocolSetDetails
    
    var createPage: CreatePage {get}
    var setDetails: SetDetails {get}
}

/// Concrete service that adopts SmartBlock actions service.
/// NOTE: Use it as default service IF you want to use desired functionality.
// MARK: - SmartBlockActionsService

fileprivate typealias Namespace = ServiceLayerNewModel

extension Namespace {
    class SmartBlockActionsService: NewModel_SmartBlockActionsServiceProtocol {
        
        var createPage: CreatePage = .init()
        var setDetails: SetDetails = .init()
    }
}

// MARK: - SmartBlockActionsService / CreatePage
extension Namespace.SmartBlockActionsService {
    typealias Success = ServiceLayerNewModel.Success
    /// Structure that adopts `CreatePage` action protocol
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`.
    struct CreatePage: NewModel_SmartBlockActionsServiceProtocolCreatePage {
        func action(contextID: String, targetID: String, details: Google_Protobuf_Struct, position: Anytype_Model_Block.Position) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.CreatePage.Service.invoke(contextID: contextID, targetID: targetID, details: details, position: position).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
}

// MARK: - SmartBlockActionsService / SetDetails
extension Namespace.SmartBlockActionsService {
    struct SetDetails: NewModel_SmartBlockActionsServiceProtocolSetDetails {
        func action(contextID: String, details: [Anytype_Rpc.Block.Set.Details.Detail]) -> AnyPublisher<Void, Error> {
            Anytype_Rpc.Block.Set.Details.Service.invoke(contextID: contextID, details: details).successToVoid().subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
}

// MARK: - Children to page.
// TODO: Add later.
extension Namespace.SmartBlockActionsService {
    struct ConvertChildrenToPages {
        func action(contextID: String, blockIds: [String]) {
//            Anytype_Rpc.BlockList.ConvertChildrenToPages.Service.invoke(contextID: contextID, blockIds: blockIds).filter { (value) -> Bool in
//            }
        }
    }
}
