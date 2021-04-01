//
//  SmartBlockActionsService+Implementation.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 11.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation
import Combine
import SwiftProtobuf
import BlocksModels
import ProtobufMessages

/// Concrete service that adopts SmartBlock actions service.
/// NOTE: Use it as default service IF you want to use desired functionality.
// MARK: - SmartBlockActionsService

class SmartBlockActionsService: SmartBlockActionsServiceProtocol {
    
    var createPage: CreatePage = .init()
    var setDetails: SetDetails = .init()
    var convertChildrenToPages: ConvertChildrenToPages = .init()
}

private extension SmartBlockActionsService {
    enum PossibleError: Error {
        case createPageActionPositionConversionHasFailed
    }
}

// MARK: - SmartBlockActionsService / CreatePage
extension SmartBlockActionsService {
    typealias Success = ServiceSuccess
    /// Structure that adopts `CreatePage` action protocol
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`.
    struct CreatePage: SmartBlockActionsServiceProtocolCreatePage {
        
        func action(contextID: BlockId, targetID: BlockId, details: DetailsInformation, position: Position) -> AnyPublisher<ServiceSuccess, Error> {
            guard let position = BlocksModelsModule.Parser.Common.Position.Converter.asMiddleware(position) else {
                return Fail.init(error: PossibleError.createPageActionPositionConversionHasFailed).eraseToAnyPublisher()
            }
            let convertedDetails = BlocksModelsModule.Parser.Details.Converter.asMiddleware(models: details.toList())
            let preparedDetails = convertedDetails.map({($0.key, $0.value)})
            let protobufDetails: [String: Google_Protobuf_Value] = .init(preparedDetails) { (lhs, rhs) in rhs }
            let protobufStruct: Google_Protobuf_Struct = .init(fields: protobufDetails)
            
            return self.action(contextID: contextID, targetID: targetID, details: protobufStruct, position: position)
        }
        
        private func action(contextID: String, targetID: String, details: Google_Protobuf_Struct, position: Anytype_Model_Block.Position) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.CreatePage.Service.invoke(contextID: contextID, targetID: targetID, details: details, position: position).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
}

// MARK: - SmartBlockActionsService / SetDetails
extension SmartBlockActionsService {
    struct SetDetails: SmartBlockActionsServiceProtocolSetDetails {
        func action(contextID: BlockId, details: Self.DetailsContent) -> AnyPublisher<ServiceSuccess, Error> {
            let middlewareDetails = BlocksModelsModule.Parser.Details.Converter.asMiddleware(models: [details])
            return self.action(contextID: contextID, details: middlewareDetails)
        }
        
        private func action(contextID: String, details: [Anytype_Rpc.Block.Set.Details.Detail]) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Set.Details.Service.invoke(contextID: contextID, details: details, queue: .global()).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
}

// MARK: - Children to page.
// TODO: Add later.
extension SmartBlockActionsService {
    struct ConvertChildrenToPages: SmartBlockActionsServiceProtocolConvertChildrenToPages {
        func action(contextID: BlockId, blocksIds: [BlockId]) -> AnyPublisher<Void, Error> {
            Anytype_Rpc.BlockList.ConvertChildrenToPages.Service.invoke(contextID: contextID, blockIds: blocksIds).successToVoid().subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
}
