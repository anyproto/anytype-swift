import Foundation
import Combine
import BlocksModels
import os
import ProtobufMessages
import Amplitude
import AnytypeCore

private extension BlockActionsServiceSingle {
    enum PossibleError: Error {
        case addActionBlockIsNotParsed
        case addActionPositionConversionHasFailed
        case duplicateActionPositionConversionHasFailed
    }
}

// MARK: Actions
final class BlockActionsServiceSingle: BlockActionsServiceSingleProtocol {    
    func open(contextID: BlockId, blockID: BlockId) -> AnyPublisher<ServiceSuccess, Error> {
        Anytype_Rpc.Block.Open.Service.invoke(
            contextID: contextID, blockID: blockID
        ).map(\.event).map(ServiceSuccess.init(_:))
        .subscribe(on: DispatchQueue.global())
        .eraseToAnyPublisher()
    }
    
    func close(contextID: BlockId, blockID: BlockId) -> AnyPublisher<Void, Error> {
        Anytype_Rpc.Block.Close.Service.invoke(contextID: contextID, blockID: blockID).successToVoid().subscribe(
            on: DispatchQueue.global()
        )
        .eraseToAnyPublisher()
    }
    
    // MARK: Create (OR Add) / Replace / Unlink ( OR Delete )
    func add(contextID: BlockId, targetID: BlockId, info: BlockInformation, position: BlockPosition) -> AnyPublisher<ServiceSuccess, Error> {
        guard let blockInformation = BlockInformationConverter.convert(information: info) else {
            return Fail(error: PossibleError.addActionBlockIsNotParsed).eraseToAnyPublisher()
        }
        guard let position = BlocksModelsParserCommonPositionConverter.asMiddleware(position) else {
            return Fail(error: PossibleError.addActionPositionConversionHasFailed).eraseToAnyPublisher()
        }
        return self.action(contextID: contextID, targetID: targetID, block: blockInformation, position: position)
    }

    private func action(contextID: String, targetID: String, block: Anytype_Model_Block, position: Anytype_Model_Block.Position) -> AnyPublisher<ServiceSuccess, Error> {
        Anytype_Rpc.Block.Create.Service.invoke(contextID: contextID, targetID: targetID, block: block, position: position)
            .map(\.event).map(ServiceSuccess.init(_:)).subscribe(on: DispatchQueue.global())
            .handleEvents(receiveSubscription: { _ in
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.blockCreate)
            })
            .eraseToAnyPublisher()
    }
    
    // TODO: Remove it or implement it. Unused.
    func replace(contextID: BlockId, blockID: BlockId, block: BlockInformation) -> AnyPublisher<ServiceSuccess, Error> {
        anytypeAssertionFailure("method is not implemented")
        return .empty()
    }
    
    private func replace(contextID: String, blockID: String, block: Anytype_Model_Block) -> AnyPublisher<ServiceSuccess, Error> {
        Anytype_Rpc.Block.Replace.Service.invoke(contextID: contextID, blockID: blockID, block: block).map(\.event).map(ServiceSuccess.init(_:)).subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    func delete(contextID: BlockId, blockIds: [BlockId]) -> AnyPublisher<ServiceSuccess, Error> {
        Anytype_Rpc.Block.Unlink.Service.invoke(contextID: contextID, blockIds: blockIds)
            .map(\.event)
            .map(ServiceSuccess.init(_:))
            .subscribe(on: DispatchQueue.global())
            .handleEvents(receiveSubscription: { _ in
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.blockUnlink)
            }).eraseToAnyPublisher()
    }

    /// Duplicate block
    func duplicate(contextID: BlockId, targetID: BlockId, blockIds: [BlockId], position: BlockPosition) -> AnyPublisher<ServiceSuccess, Error> {
        guard let position = BlocksModelsParserCommonPositionConverter.asMiddleware(position) else {
            return Fail(error: PossibleError.duplicateActionPositionConversionHasFailed).eraseToAnyPublisher()
        }
        return self.action(contextID: contextID, targetID: targetID, blockIds: blockIds, position: position)
    }
    
    private func action(contextID: String, targetID: String, blockIds: [String], position: Anytype_Model_Block.Position) -> AnyPublisher<ServiceSuccess, Error> {
        Anytype_Rpc.BlockList.Duplicate.Service.invoke(contextID: contextID, targetID: targetID, blockIds: blockIds, position: position).map(\.event).map(ServiceSuccess.init(_:)).subscribe(on: DispatchQueue.global())
            .handleEvents(receiveSubscription: { _ in
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.blockListDuplicate)
            })
            .eraseToAnyPublisher()
    }
}
