import Combine
import BlocksModels
import ProtobufMessages
import Amplitude
import AnytypeCore

// MARK: Actions
final class BlockActionsServiceSingle: BlockActionsServiceSingleProtocol {

    func paste(contextId: BlockId,
               focusedBlockId: BlockId,
               selectedTextRange: NSRange,
               isPartOfBlock: Bool,
               textSlots: TextSlots,
               anySlots: AnySlots?,
               fileSlot: Anytype_Rpc.Block.Paste.Request.File?) -> BlockId? {
        paste(contextId: contextId,
              focusedBlockId: focusedBlockId,
              selectedTextRange: selectedTextRange.asMiddleware,
              selectedBlockIds: [],
              isPartOfBlock: isPartOfBlock,
              textSlots: textSlots,
              anySlots: anySlots,
              fileSlot: fileSlot)
    }

    func paste(contextId: BlockId,
               selectedBlockIds: [BlockId],
               isPartOfBlock: Bool,
               textSlots: TextSlots,
               anySlots: AnySlots?,
               fileSlot: Anytype_Rpc.Block.Paste.Request.File?) -> BlockId? {
        paste(contextId: contextId,
              focusedBlockId: "",
              selectedTextRange: Anytype_Model_Range(),
              selectedBlockIds: selectedBlockIds,
              isPartOfBlock: isPartOfBlock,
              textSlots: textSlots,
              anySlots: anySlots,
              fileSlot: fileSlot)
    }

    private func paste(contextId: BlockId,
                       focusedBlockId: BlockId,
                       selectedTextRange: Anytype_Model_Range,
                       selectedBlockIds: [BlockId],
                       isPartOfBlock: Bool,
                       textSlots: TextSlots,
                       anySlots: AnySlots?,
                       fileSlot: Anytype_Rpc.Block.Paste.Request.File?) -> BlockId? {

        let result = Anytype_Rpc.Block.Paste.Service.invoke(
            contextID: contextId,
            focusedBlockID: focusedBlockId,
            selectedTextRange: selectedTextRange,
            selectedBlockIds: selectedBlockIds,
            isPartOfBlock: isPartOfBlock,
            textSlot: textSlots.textSlot ?? "",
            htmlSlot: textSlots.htmlSlot ?? "",
            anySlot: anySlots ?? [],
            fileSlot: [fileSlot ?? Anytype_Rpc.Block.Paste.Request.File()]
        )
            .getValue(domain: .blockActionsService)

        let events = result.map {
            EventsBunch(event: $0.event)
        }
        events?.send()

        return result?.blockIds.last
    }

    func copy(contextId: BlockId, blocksInfo: [BlockInformation], selectedTextRange: NSRange) -> PastboardSlots {
        let blockskModels = blocksInfo.compactMap {
            BlockInformationConverter.convert(information: $0)
        }

        let result = Anytype_Rpc.Block.Copy.Service.invoke(
            contextID: contextId,
            blocks: blockskModels,
            selectedTextRange: selectedTextRange.asMiddleware
        )
            .getValue(domain: .blockActionsService)

        let textSlots = TextSlots(textSlot: result?.textSlot, htmlSlot: result?.htmlSlot)
        return PastboardSlots(textSlots: textSlots, anySlots: result?.anySlot, fileSlots: nil)
    }

    func open(contextId: BlockId, blockId: BlockId) -> Bool {
        let event = Anytype_Rpc.Block.Open.Service.invoke(contextID: contextId, blockID: blockId, traceID: "")
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockActionsService)
        
        guard let event = event else { return false }
        event.send()
        
        return true
    }
    
    func close(contextId: BlockId, blockId: BlockId) {
        _ = Anytype_Rpc.Block.Close.Service.invoke(contextID: contextId, blockID: blockId)
    }
    
    func add(contextId: BlockId, targetId: BlockId, info: BlockInformation, position: BlockPosition) -> BlockId? {
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
    
    func delete(contextId: BlockId, blockIds: [BlockId]) -> Bool {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockDelete)
        let event = Anytype_Rpc.Block.Unlink.Service.invoke(contextID: contextId, blockIds: blockIds)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockActionsService)
        
        guard let event = event else { return false }
        event.send()
        
        return true
    }

    func duplicate(contextId: BlockId, targetId: BlockId, blockIds: [BlockId], position: BlockPosition) {
        Amplitude.instance().logEvent(AmplitudeEventsName.blockListDuplicate)

        Anytype_Rpc.BlockList.Duplicate.Service
            .invoke(contextID: contextId, targetID: targetId, blockIds: blockIds, position: position.asMiddleware)
            .map { EventsBunch(event: $0.event) }
            .getValue(domain: .blockActionsService)?
            .send()
        
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
