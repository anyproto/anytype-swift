import Services
import ProtobufMessages
import AnytypeCore
import Foundation

final class PasteboardMiddleService: PasteboardMiddlewareServiceProtocol {
    private let document: BaseDocumentProtocol

    init(document: BaseDocumentProtocol) {
        self.document = document
    }

    func pasteText(_ text: String, context: PasteboardActionContext) -> PasteboardPasteResult? {
        paste(contextId: document.objectId,
              focusedBlockId: context.focusedBlockId,
              selectedTextRange: context.selectedRange,
              selectedBlockIds: context.selectedBlocksIds,
              isPartOfBlock: context.focusedBlockId.isNotEmpty,
              textSlot: text,
              htmlSlot: "",
              anySlots:  [],
              fileSlots: [])
    }

    func pasteHTML(_ html: String, context: PasteboardActionContext) -> PasteboardPasteResult? {
        paste(contextId: document.objectId,
              focusedBlockId: context.focusedBlockId,
              selectedTextRange: context.selectedRange,
              selectedBlockIds: context.selectedBlocksIds,
              isPartOfBlock: context.focusedBlockId.isNotEmpty,
              textSlot: "",
              htmlSlot: html,
              anySlots:  [],
              fileSlots: [])
    }

    func pasteBlock(_ blocks: [String], context: PasteboardActionContext) -> PasteboardPasteResult? {
        let blocksSlots = blocks.compactMap { blockJSONSlot in
            try? Anytype_Model_Block(jsonString: blockJSONSlot)
        }
        return paste(contextId: document.objectId,
                     focusedBlockId: context.focusedBlockId,
                     selectedTextRange: context.selectedRange,
                     selectedBlockIds: context.selectedBlocksIds,
                     isPartOfBlock: context.focusedBlockId.isNotEmpty,
                     textSlot: "",
                     htmlSlot: "",
                     anySlots:  blocksSlots,
                     fileSlots: [])
    }

    func pasteFile(localPath: String, name: String, context: PasteboardActionContext)  -> PasteboardPasteResult? {
        let fileSlot = Anytype_Rpc.Block.Paste.Request.File.with {
            $0.name = name
            $0.data = Data()
            $0.localPath = localPath
        }
        return paste(contextId: document.objectId,
              focusedBlockId: context.focusedBlockId,
              selectedTextRange: context.selectedRange,
              selectedBlockIds: context.selectedBlocksIds,
              isPartOfBlock: context.focusedBlockId.isNotEmpty,
              textSlot: "",
              htmlSlot: "",
              anySlots:  [],
              fileSlots: [fileSlot])
    }

    func copy(blocksIds: [BlockId], selectedTextRange: NSRange) async throws -> PasteboardCopyResult? {
        let blocks: [Anytype_Model_Block] = blocksIds.compactMap {
            guard let info = document.infoContainer.get(id: $0) else { return nil }
            return BlockInformationConverter.convert(information: info)
        }
        let result = try await ClientCommands.blockCopy(.with {
            $0.contextID = document.objectId
            $0.blocks = blocks
            $0.selectedTextRange = selectedTextRange.asMiddleware
        }).invoke()

        let blocksSlots = result.anySlot.compactMap { modelBlock in
            try? modelBlock.jsonString()
        }
        return PasteboardCopyResult(textSlot: result.textSlot, htmlSlot: result.htmlSlot, blockSlot: blocksSlots)
    }
    
    func cut(blocksIds: [BlockId], selectedTextRange: NSRange) async throws -> PasteboardCopyResult? {
        let blocks: [Anytype_Model_Block] = blocksIds.compactMap {
            guard let info = document.infoContainer.get(id: $0) else { return nil }
            return BlockInformationConverter.convert(information: info)
        }

        let result = try await ClientCommands.blockCut(.with {
            $0.contextID = document.objectId
            $0.blocks = blocks
            $0.selectedTextRange = selectedTextRange.asMiddleware
        }).invoke()

        let blocksSlots = result.anySlot.compactMap { modelBlock in
            try? modelBlock.jsonString()
        }
        return PasteboardCopyResult(textSlot: result.textSlot, htmlSlot: result.htmlSlot, blockSlot: blocksSlots)
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
                       fileSlots: [Anytype_Rpc.Block.Paste.Request.File]) -> PasteboardPasteResult? {

        let result = try? ClientCommands.blockPaste(.with {
            $0.contextID = contextId
            $0.focusedBlockID = focusedBlockId
            $0.selectedTextRange = selectedTextRange.asMiddleware
            $0.selectedBlockIds = selectedBlockIds
            $0.isPartOfBlock = isPartOfBlock
            $0.textSlot = textSlot
            $0.htmlSlot = htmlSlot
            $0.anySlot = anySlots
            $0.fileSlot = fileSlots
        }).invoke()

        guard let result = result else {
            return nil
        }

        return PasteboardPasteResult(caretPosition: Int(result.caretPosition),
                                     isSameBlockCaret: result.isSameBlockCaret,
                                     blockIds: result.blockIds)
    }
}
