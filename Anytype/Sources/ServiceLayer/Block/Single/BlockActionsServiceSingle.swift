import Foundation
import Combine
import BlocksModels
import ProtobufMessages
import Amplitude
import AnytypeCore
import BlocksModels

// MARK: Actions
final class BlockActionsServiceSingle: BlockActionsServiceSingleProtocol {    
    func open(contextId: BlockId, blockId: BlockId) -> MiddlewareResponse? {
        Anytype_Rpc.Block.Open.Service.invoke(contextID: contextId, blockID: blockId, traceID: "")
            .map { MiddlewareResponse($0.event) }
            .getValue(domain: .blockActionsService)
    }
    
    func close(contextId: BlockId, blockId: BlockId) {
        _ = Anytype_Rpc.Block.Close.Service.invoke(contextID: contextId, blockID: blockId)
    }
    
    // MARK: Create (OR Add) / Replace / Unlink ( OR Delete )
    func add(contextId: BlockId, targetId: BlockId, info: BlockInformation, position: BlockPosition) -> MiddlewareResponse? {
        guard let blockInformation = BlockInformationConverter.convert(information: info) else {
            anytypeAssertionFailure("addActionBlockIsNotParsed", domain: .blockActionsService)
            return nil
        }

        Amplitude.instance().logCreateBlock(type: info.content.description, style: info.content.type.style)

        return Anytype_Rpc.Block.Create.Service.invoke(contextID: contextId, targetID: targetId, block: blockInformation, position: position.asMiddleware)
            .map { MiddlewareResponse($0.event) }
            .getValue(domain: .blockActionsService)
    }

    func replace(contextId: BlockId, blockId: BlockId, info: BlockInformation) -> MiddlewareResponse? {
        guard let block = BlockInformationConverter.convert(information: info) else {
            anytypeAssertionFailure("replace action parsing error", domain: .blockActionsService)
            return nil
        }
        
        return Anytype_Rpc.Block.Replace.Service
            .invoke(contextID: contextId, blockID: blockId, block: block)
            .map { MiddlewareResponse($0.event) }
            .getValue(domain: .blockActionsService)
    }
    
    func delete(contextId: BlockId, blockIds: [BlockId]) -> Bool {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockDelete)
        let event = Anytype_Rpc.Block.Unlink.Service.invoke(contextID: contextId, blockIds: blockIds)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockActionsService)
        
        guard let event = event else { return false }
        event.send()
        
        return true
    }

    func duplicate(contextId: BlockId, targetId: BlockId, blockIds: [BlockId], position: BlockPosition) -> MiddlewareResponse? {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockListDuplicate)

        return Anytype_Rpc.BlockList.Duplicate.Service
            .invoke(contextID: contextId, targetID: targetId, blockIds: blockIds, position: position.asMiddleware)
            .map { MiddlewareResponse($0.event) }
            .getValue(domain: .blockActionsService)
    }

    func move(
        contextId: BlockId,
        blockIds: [String],
        targetContextID: BlockId,
        dropTargetID: String,
        position: BlockPosition
    ) {
        let event = Anytype_Rpc.BlockList.Move.Service
            .invoke(
                contextID: contextId,
                blockIds: blockIds,
                targetContextID: targetContextID,
                dropTargetID: dropTargetID,
                position: position.asMiddleware
            ).map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockActionsService)

        guard let event = event else { return }

        event.send()

        Amplitude.instance().logReorderBlock(count: blockIds.count)
    }
}
