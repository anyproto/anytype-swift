import Combine
import BlocksModels
import ProtobufMessages
import AnytypeCore

// MARK: Actions
final class BlockActionsServiceSingle: BlockActionsServiceSingleProtocol {
    private let contextId: BlockId

    init(contextId: BlockId) {
        self.contextId = contextId
    }

    func open() -> Bool {
        let event = Anytype_Rpc.Block.Open.Service.invoke(contextID: contextId, blockID: contextId, traceID: "")
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockActionsService)
        
        guard let event = event else { return false }
        event.send()
        
        return true
    }
    
    func close() {
        _ = Anytype_Rpc.Block.Close.Service.invoke(contextID: contextId, blockID: contextId)
    }
    
    func add(targetId: BlockId, info: BlockInformation, position: BlockPosition) -> BlockId? {
        guard let block = BlockInformationConverter.convert(information: info) else {
            anytypeAssertionFailure("addActionBlockIsNotParsed", domain: .blockActionsService)
            return nil
        }

        AnytypeAnalytics.instance().logCreateBlock(type: info.content.description, style: info.content.type.style)

        let response = Anytype_Rpc.Block.Create.Service
            .invoke(contextID: contextId, targetID: targetId, block: block, position: position.asMiddleware)
        
        guard let result = response.getValue(domain: .blockActionsService) else { return nil }

        EventsBunch(event: result.event).send()
        return result.blockID
    }
    
    func delete(blockIds: [BlockId]) -> Bool {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.blockDelete)
        let event = Anytype_Rpc.Block.Unlink.Service.invoke(contextID: contextId, blockIds: blockIds)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockActionsService)
        
        guard let event = event else { return false }
        event.send()
        
        return true
    }

    func duplicate(targetId: BlockId, blockIds: [BlockId], position: BlockPosition) {
        AnytypeAnalytics.instance().logEvent(AnalyticsEventsName.blockListDuplicate)

        Anytype_Rpc.BlockList.Duplicate.Service
            .invoke(contextID: contextId, targetID: targetId, blockIds: blockIds, position: position.asMiddleware)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockActionsService)?
            .send()
        
    }

    func move(
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

        AnytypeAnalytics.instance().logReorderBlock(count: blockIds.count)
    }
}
