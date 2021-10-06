import Foundation
import Combine
import BlocksModels
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
    func open(contextId: BlockId, blockId: BlockId) -> ResponseEvent? {
        let result = Anytype_Rpc.Block.Open.Service.invoke(contextID: contextId, blockID: blockId)
            .map { ResponseEvent($0.event) }
        
        switch result {
        case .success(let response):
            return response
        case .failure(let error):
            anytypeAssertionFailure(error.localizedDescription)
            return nil
        }
        
    }
    
    func close(contextID: BlockId, blockID: BlockId) -> AnyPublisher<Void, Error> {
        Anytype_Rpc.Block.Close.Service.invoke(contextID: contextID, blockID: blockID).successToVoid().subscribe(
            on: DispatchQueue.global()
        )
        .eraseToAnyPublisher()
    }
    
    // MARK: Create (OR Add) / Replace / Unlink ( OR Delete )
    func add(contextID: BlockId, targetID: BlockId, info: BlockInformation, position: BlockPosition) -> Result<ResponseEvent, Error> {
        guard let blockInformation = BlockInformationConverter.convert(information: info) else {
            return .failure(PossibleError.addActionBlockIsNotParsed)
        }
        guard let position = BlocksModelsParserCommonPositionConverter.asMiddleware(position) else {
            return .failure(PossibleError.addActionPositionConversionHasFailed)
        }
        return action(contextID: contextID, targetID: targetID, block: blockInformation, position: position)
    }

    private func action(
        contextID: String, targetID: String, block: Anytype_Model_Block, position: Anytype_Model_Block.Position
    ) -> Result<ResponseEvent, Error> {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockCreate)
        return Anytype_Rpc.Block.Create.Service.invoke(contextID: contextID, targetID: targetID, block: block, position: position)
            .map { ResponseEvent($0.event) }
    }
    
    // TODO: Remove it or implement it. Unused.
    func replace(contextID: BlockId, blockID: BlockId, block: BlockInformation) -> AnyPublisher<ResponseEvent, Error> {
        anytypeAssertionFailure("method is not implemented")
        return .empty()
    }
    
    private func replace(contextID: String, blockID: String, block: Anytype_Model_Block) -> AnyPublisher<ResponseEvent, Error> {
        Anytype_Rpc.Block.Replace.Service.invoke(contextID: contextID, blockID: blockID, block: block).map(\.event).map(ResponseEvent.init(_:)).subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
    
    func delete(contextID: BlockId, blockIds: [BlockId]) -> AnyPublisher<ResponseEvent, Error> {
        Anytype_Rpc.Block.Unlink.Service.invoke(contextID: contextID, blockIds: blockIds)
            .map(\.event)
            .map(ResponseEvent.init(_:))
            .subscribe(on: DispatchQueue.global())
            .handleEvents(receiveSubscription: { _ in
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.blockUnlink)
            }).eraseToAnyPublisher()
    }

    /// Duplicate block
    func duplicate(contextID: BlockId, targetID: BlockId, blockIds: [BlockId], position: BlockPosition) -> AnyPublisher<ResponseEvent, Error> {
        guard let position = BlocksModelsParserCommonPositionConverter.asMiddleware(position) else {
            return Fail(error: PossibleError.duplicateActionPositionConversionHasFailed).eraseToAnyPublisher()
        }
        return self.action(contextID: contextID, targetID: targetID, blockIds: blockIds, position: position)
    }
    
    private func action(contextID: String, targetID: String, blockIds: [String], position: Anytype_Model_Block.Position) -> AnyPublisher<ResponseEvent, Error> {
        Anytype_Rpc.BlockList.Duplicate.Service.invoke(contextID: contextID, targetID: targetID, blockIds: blockIds, position: position).map(\.event).map(ResponseEvent.init(_:)).subscribe(on: DispatchQueue.global())
            .handleEvents(receiveSubscription: { _ in
                // Analytics
                Amplitude.instance().logEvent(AmplitudeEventsName.blockListDuplicate)
            })
            .eraseToAnyPublisher()
    }
}
