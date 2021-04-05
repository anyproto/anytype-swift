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

enum SmartBlockActionsServicePossibleError: Error {
    case createPageActionPositionConversionHasFailed
}

/// Concrete service that adopts SmartBlock actions service.
/// NOTE: Use it as default service IF you want to use desired functionality.
// MARK: - SmartBlockActionsService
class SmartBlockActionsService: SmartBlockActionsServiceProtocol {
    // MARK: - SmartBlockActionsService / CreatePage
    /// Structure that adopts `CreatePage` action protocol
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`.
    func createPage(contextID: BlockId, targetID: BlockId, details: DetailsInformation, position: Position) -> AnyPublisher<ServiceSuccess, Error> {
        guard let position = BlocksModelsModule.Parser.Common.Position.Converter.asMiddleware(position) else {
            return Fail.init(error: SmartBlockActionsServicePossibleError.createPageActionPositionConversionHasFailed).eraseToAnyPublisher()
        }
        let convertedDetails = BlocksModelsModule.Parser.Details.Converter.asMiddleware(models: details.toList())
        let preparedDetails = convertedDetails.map({($0.key, $0.value)})
        let protobufDetails: [String: Google_Protobuf_Value] = .init(preparedDetails) { (lhs, rhs) in rhs }
        let protobufStruct: Google_Protobuf_Struct = .init(fields: protobufDetails)
        
        return createPage(contextID: contextID, targetID: targetID, details: protobufStruct, position: position)
    }
    
    private func createPage(contextID: String, targetID: String, details: Google_Protobuf_Struct, position: Anytype_Model_Block.Position) -> AnyPublisher<ServiceSuccess, Error> {
        Anytype_Rpc.Block.CreatePage.Service.invoke(contextID: contextID, targetID: targetID, details: details, position: position).map(\.event).map(ServiceSuccess.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }

    // MARK: - SmartBlockActionsService / SetDetails
    func setDetails(contextID: BlockId, details: DetailsContent) -> AnyPublisher<ServiceSuccess, Error> {
        let middlewareDetails = BlocksModelsModule.Parser.Details.Converter.asMiddleware(models: [details])
        return setDetails(contextID: contextID, details: middlewareDetails)
    }
    
    private func setDetails(contextID: String, details: [Anytype_Rpc.Block.Set.Details.Detail]) -> AnyPublisher<ServiceSuccess, Error> {
        Anytype_Rpc.Block.Set.Details.Service.invoke(contextID: contextID, details: details, queue: .global()).map(\.event).map(ServiceSuccess.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }

    // MARK: - Children to page.
    // TODO: Add later.
    func convertChildrenToPages(contextID: BlockId, blocksIds: [BlockId]) -> AnyPublisher<Void, Error> {
        Anytype_Rpc.BlockList.ConvertChildrenToPages.Service.invoke(contextID: contextID, blockIds: blocksIds).successToVoid().subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
    }
}
