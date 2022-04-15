import BlocksModels
import ProtobufMessages
import AnytypeCore

final class PasteboardMiddleService: PasteboardMiddlewareServiceProtocol {
    private let document: BaseDocumentProtocol

    init(document: BaseDocumentProtocol) {
        self.document = document
    }

    func pasteText(_ text: String, context: PasteboardActionContext) {
        paste(contextId: document.objectId.value,
              focusedBlockId: context.focusedBlockId,
              selectedTextRange: context.selectedRange,
              selectedBlockIds: context.selectedBlocksIds,
              isPartOfBlock: context.focusedBlockId.isNotEmpty,
              textSlot: text,
              htmlSlot: "",
              anySlots:  [],
              fileSlots: [])
    }

    func pasteHTML(_ html: String, context: PasteboardActionContext) {
        paste(contextId: document.objectId.value,
              focusedBlockId: context.focusedBlockId,
              selectedTextRange: context.selectedRange,
              selectedBlockIds: context.selectedBlocksIds,
              isPartOfBlock: context.focusedBlockId.isNotEmpty,
              textSlot: "",
              htmlSlot: html,
              anySlots:  [],
              fileSlots: [])
    }

    func pasteBlock(_ blocks: [String], context: PasteboardActionContext) {
        let blocksSlots = blocks.compactMap { blockJSONSlot in
            try? Anytype_Model_Block(jsonString: blockJSONSlot)
        }
        paste(contextId: document.objectId.value,
              focusedBlockId: context.focusedBlockId,
              selectedTextRange: context.selectedRange,
              selectedBlockIds: context.selectedBlocksIds,
              isPartOfBlock: context.focusedBlockId.isNotEmpty,
              textSlot: "",
              htmlSlot: "",
              anySlots:  blocksSlots,
              fileSlots: [])
    }

    func pasteFile(localPath: String, name: String, context: PasteboardActionContext) {
        paste(contextId: document.objectId.value,
              focusedBlockId: context.focusedBlockId,
              selectedTextRange: context.selectedRange,
              selectedBlockIds: context.selectedBlocksIds,
              isPartOfBlock: context.focusedBlockId.isNotEmpty,
              textSlot: "",
              htmlSlot: "",
              anySlots:  [],
              fileSlots: [Anytype_Rpc.Block.Paste.Request.File(name: name, data: Data(), localPath: localPath)])
    }

    func copy(blocksIds: [BlockId], selectedTextRange: NSRange) -> PasteboardCopyResult? {
        let blocks: [Anytype_Model_Block] = blocksIds.compactMap {
            guard let info = document.infoContainer.get(id: $0) else { return nil }
            return BlockInformationConverter.convert(information: info)
        }
        let result = Anytype_Rpc.Block.Copy.Service.invoke(
            contextID: document.objectId.value,
            blocks: blocks,
            selectedTextRange: selectedTextRange.asMiddleware
        )
            .getValue(domain: .blockActionsService)

        if let result = result {
            let blocksSlots = result.anySlot.compactMap { modelBlock in
                try? modelBlock.jsonString()
            }
            return PasteboardCopyResult(textSlot: result.textSlot, htmlSlot: result.htmlSlot, blockSlot: blocksSlots)
        }
        return nil
    }
}

// MARK: - Private methods for middle

private extension PasteboardMiddleService {

    private func paste(contextId: BlockId,
                       focusedBlockId: BlockId,
                       selectedTextRange: NSRange,
                       selectedBlockIds: [BlockId],
                       isPartOfBlock: Bool,
                       textSlot: String,
                       htmlSlot: String,
                       anySlots:  [Anytype_Model_Block],
                       fileSlots: [Anytype_Rpc.Block.Paste.Request.File]) {

        let result = Anytype_Rpc.Block.Paste.Service.invoke(
            contextID: contextId,
            focusedBlockID: focusedBlockId,
            selectedTextRange: selectedTextRange.asMiddleware,
            selectedBlockIds: selectedBlockIds,
            isPartOfBlock: isPartOfBlock,
            textSlot: textSlot,
            htmlSlot: htmlSlot,
            anySlot: anySlots,
            fileSlot: fileSlots
        )
            .getValue(domain: .blockActionsService)

        let events = result.map {
            EventsBunch(event: $0.event)
        }
        events?.send()
    }
}
