import Combine
import BlocksModels
import ProtobufMessages
import Amplitude
import AnytypeCore

// MARK: Actions
final class BlockActionsServiceSingle: BlockActionsServiceSingleProtocol {
    private let contextId: BlockId
    init(contextId: BlockId) {
        self.contextId = contextId
    }
    
    func paste(
        focusedBlockId: BlockId,
        selectedTextRange: NSRange,
        selectedBlockIds: [BlockId],
        isPartOfBlock: Bool,
        textSlot: String?,
        htmlSlot: String?,
        anySlots:  [Anytype_Model_Block]?,
        fileSlots: [Anytype_Rpc.Block.Paste.Request.File]?
    ) -> BlockId? {

        let result = Anytype_Rpc.Block.Paste.Service.invoke(
            contextID: contextId,
            focusedBlockID: focusedBlockId,
            selectedTextRange: selectedTextRange.asMiddleware,
            selectedBlockIds: selectedBlockIds,
            isPartOfBlock: isPartOfBlock,
            textSlot: textSlot ?? "",
            htmlSlot: htmlSlot ?? "",
            anySlot: anySlots ?? [],
            fileSlot: fileSlots ?? []
        )
            .getValue(domain: .blockActionsService)

        let events = result.map {
            EventsBunch(event: $0.event)
        }
        events?.send()

        return result?.blockIds.last
    }

    func copy(blocksInfo: [BlockInformation], selectedTextRange: NSRange) -> [PasteboardSlot]? {
        let blockskModels = blocksInfo.compactMap {
            BlockInformationConverter.convert(information: $0)
        }

        let result = Anytype_Rpc.Block.Copy.Service.invoke(
            contextID: contextId,
            blocks: blockskModels,
            selectedTextRange: selectedTextRange.asMiddleware
        )
            .getValue(domain: .blockActionsService)

        if let result = result {
            let anySlot = result.anySlot.compactMap { modelBlock in
                try? modelBlock.jsonString()
            }
            return [.html(result.htmlSlot), .text(result.textSlot), .anySlots(anySlot)]
        }
        return nil
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

        Amplitude.instance().logCreateBlock(type: info.content.description, style: info.content.type.style)

        let response = Anytype_Rpc.Block.Create.Service
            .invoke(contextID: contextId, targetID: targetId, block: block, position: position.asMiddleware)
        
        guard let result = response.getValue(domain: .blockActionsService) else { return nil }

        EventsBunch(event: result.event).send()
        return result.blockID
    }
    
    func delete(blockIds: [BlockId]) -> Bool {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockDelete)
        let event = Anytype_Rpc.Block.Unlink.Service.invoke(contextID: contextId, blockIds: blockIds)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockActionsService)
        
        guard let event = event else { return false }
        event.send()
        
        return true
    }

    func duplicate(targetId: BlockId, blockIds: [BlockId], position: BlockPosition) {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockListDuplicate)

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

        Amplitude.instance().logReorderBlock(count: blockIds.count)
    }
}
