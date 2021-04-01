import Foundation
import Combine
import BlocksModels
import os
import ProtobufMessages

private extension Logging.Categories {
    static let service: Self = "BlockActionsService.Single.Implementation"
}

class BlockActionsServiceSingle: BlockActionsServiceSingleProtocol {
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

private extension BlockActionsServiceSingle {
    enum PossibleError: Error {
        case addActionBlockIsNotParsed
        case addActionPositionConversionHasFailed
        case duplicateActionPositionConversionHasFailed
    }
}

// MARK: Actions
extension BlockActionsServiceSingle {
    typealias Success = ServiceSuccess
    
    // MARK: Open / Close
    struct Open: BlockActionsServiceSingleProtocolOpen {
        func action(contextID: BlockId, blockID: BlockId) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Open.Service.invoke(contextID: contextID, blockID: blockID).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    struct Close: BlockActionsServiceSingleProtocolClose {
        func action(contextID: BlockId, blockID: BlockId) -> AnyPublisher<Void, Error> {
            Anytype_Rpc.Block.Close.Service.invoke(contextID: contextID, blockID: blockID).successToVoid().subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    // MARK: Create (OR Add) / Replace / Unlink ( OR Delete )
    struct Add: BlockActionsServiceSingleProtocolAdd {
        typealias InformationModel = Block.Information.InformationModel
        private var parser: BlocksModelsModule.Parser

        init(parser: BlocksModelsModule.Parser) {
            self.parser = parser
        }

        func action(contextID: BlockId, targetID: BlockId, block: InformationModel, position: Position) -> AnyPublisher<ServiceSuccess, Error> {
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
    struct Replace: BlockActionsServiceSingleProtocolReplace {
        typealias InformationModel = Block.Information.InformationModel

        func action(contextID: BlockId, blockID: BlockId, block: InformationModel) -> AnyPublisher<ServiceSuccess, Error> {
            let logger = Logging.createLogger(category: .service)
            os_log(.info, log: logger, "method is not implemented")
            return .empty()
        }
        
        private func action(contextID: String, blockID: String, block: Anytype_Model_Block) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Replace.Service.invoke(contextID: contextID, blockID: blockID, block: block).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    struct Delete: BlockActionsServiceSingleProtocolDelete {
        func action(contextID: BlockId, blockIds: [BlockId]) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Unlink.Service.invoke(contextID: contextID, blockIds: blockIds).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    
    // MARK: Duplicate
    // Actually, should be used for BlockList
    struct Duplicate: ServiceLayerModule_BlockListActionsServiceProtocolDuplicate {
        func action(contextID: BlockId, targetID: BlockId, blockIds: [BlockId], position: Position) -> AnyPublisher<ServiceSuccess, Error> {
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
