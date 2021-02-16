//
//  BlockActionsService+Single+Implementation.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 11.02.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation
import Combine
import BlocksModels
import os
import ProtobufMessages

fileprivate typealias Namespace = ServiceLayerModule.Single

private extension Logging.Categories {
    static let service: Self = "BlockActionsService.Single.Implementation"
}

extension Namespace {
    class BlockActionsService: ServiceLayerModule_BlockActionsServiceSingleProtocol {
        var open: Open = .init() // SmartBlock only for now? Move it to Smartblocks service later.
        var close: Close = .init() // SmartBlock only for now? Move it to Smartblocks service later.
        var add: Add
        var replace: Replace = .init()
        var delete: Delete = .init()
        var duplicate: Duplicate = .init() // BlockList?
        
        /// DI
        private var parser: BlocksModelsModule.Parser = .init()
        init() {
            self.add = .init(parser: self.parser)
        }
    }
}

private extension Namespace.BlockActionsService {
    enum PossibleError: Error {
        case addActionBlockIsNotParsed
        case addActionPositionConversionHasFailed
        case duplicateActionPositionConversionHasFailed
    }
}

// MARK: Actions
extension Namespace.BlockActionsService {
    typealias Success = ServiceLayerModule.Success
    
    // MARK: Open / Close
    struct Open: ServiceLayerModule_BlockActionsServiceSingleProtocolOpen {
        func action(contextID: BlockId, blockID: BlockId) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Open.Service.invoke(contextID: contextID, blockID: blockID).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    struct Close: ServiceLayerModule_BlockActionsServiceSingleProtocolClose {
        func action(contextID: BlockId, blockID: BlockId) -> AnyPublisher<Void, Error> {
            Anytype_Rpc.Block.Close.Service.invoke(contextID: contextID, blockID: blockID).successToVoid().subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    // MARK: Create (OR Add) / Replace / Unlink ( OR Delete )
    struct Add: ServiceLayerModule_BlockActionsServiceSingleProtocolAdd {
        private var parser: BlocksModelsModule.Parser
        init(parser: BlocksModelsModule.Parser) {
            self.parser = parser
        }
        func action(contextID: BlockId, targetID: BlockId, block: Model, position: Position) -> AnyPublisher<ServiceLayerModule.Success, Error> {
            guard let blockInformation = self.parser.convert(information: block) else {
                return Fail(error: PossibleError.addActionBlockIsNotParsed).eraseToAnyPublisher()
            }
            guard let position = BlocksModelsModule.Parser.Common.Position.Converter.asMiddleware(position) else {
                return Fail(error: PossibleError.addActionPositionConversionHasFailed).eraseToAnyPublisher()
            }
            return self.action(contextID: contextID, targetID: targetID, block: blockInformation, position: position)
        }
        private func action(contextID: String, targetID: String, block: Anytype_Model_Block, position: Anytype_Model_Block.Position) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Create.Service.invoke(contextID: contextID, targetID: targetID, block: block, position: position)
                .map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    /// TODO: Remove it or implement it.
    /// Unused.
    struct Replace: ServiceLayerModule_BlockActionsServiceSingleProtocolReplace {
        func action(contextID: BlockId, blockID: BlockId, block: Model) -> AnyPublisher<ServiceLayerModule.Success, Error> {
            let logger = Logging.createLogger(category: .service)
            os_log(.info, log: logger, "method is not implemented")
            return .empty()
        }
        
        private func action(contextID: String, blockID: String, block: Anytype_Model_Block) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Replace.Service.invoke(contextID: contextID, blockID: blockID, block: block).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    struct Delete: ServiceLayerModule_BlockActionsServiceSingleProtocolDelete {
        func action(contextID: BlockId, blockIds: [BlockId]) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Unlink.Service.invoke(contextID: contextID, blockIds: blockIds).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    
    // MARK: Duplicate
    // Actually, should be used for BlockList
    struct Duplicate: ServiceLayerModule_BlockListActionsServiceProtocolDuplicate {
        func action(contextID: BlockId, targetID: BlockId, blockIds: [BlockId], position: Position) -> AnyPublisher<ServiceLayerModule.Success, Error> {
            guard let position = BlocksModelsModule.Parser.Common.Position.Converter.asMiddleware(position) else {
                return Fail(error: PossibleError.duplicateActionPositionConversionHasFailed).eraseToAnyPublisher()
            }
            return self.action(contextID: contextID, targetID: targetID, blockIds: blockIds, position: position)
        }
        
        private func action(contextID: String, targetID: String, blockIds: [String], position: Anytype_Model_Block.Position) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Duplicate.Service.invoke(contextID: contextID, targetID: targetID, blockIds: blockIds, position: position).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
}
