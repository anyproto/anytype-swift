import ProtobufMessages
import AnytypeCore
import Foundation

public final class PasteboardMiddleService: PasteboardMiddlewareServiceProtocol {
    
    public init() {}

    public func pasteText(_ text: String, objectId: BlockId, context: PasteboardActionContext) async throws -> PasteboardPasteResult {
        try await paste(contextId: objectId,
              focusedBlockId: context.focusedBlockId,
              selectedTextRange: context.selectedRange,
              selectedBlockIds: context.selectedBlocksIds,
              isPartOfBlock: context.focusedBlockId.isNotEmpty,
              textSlot: text,
              htmlSlot: "",
              anySlots:  [],
              fileSlots: [])
    }

    public func pasteHTML(_ html: String, objectId: BlockId, context: PasteboardActionContext) async throws -> PasteboardPasteResult {
        try await paste(contextId: objectId,
              focusedBlockId: context.focusedBlockId,
              selectedTextRange: context.selectedRange,
              selectedBlockIds: context.selectedBlocksIds,
              isPartOfBlock: context.focusedBlockId.isNotEmpty,
              textSlot: "",
              htmlSlot: html,
              anySlots:  [],
              fileSlots: [])
    }

    public func pasteBlock(_ blocks: [String], objectId: BlockId, context: PasteboardActionContext) async throws -> PasteboardPasteResult {
        let blocksSlots = blocks.compactMap { blockJSONSlot in
            try? Anytype_Model_Block(jsonString: blockJSONSlot)
        }
        return try await paste(contextId: objectId,
                     focusedBlockId: context.focusedBlockId,
                     selectedTextRange: context.selectedRange,
                     selectedBlockIds: context.selectedBlocksIds,
                     isPartOfBlock: context.focusedBlockId.isNotEmpty,
                     textSlot: "",
                     htmlSlot: "",
                     anySlots:  blocksSlots,
                     fileSlots: [])
    }

    public func pasteFiles(_ files: [PasteboardFile], objectId: BlockId, context: PasteboardActionContext) async throws -> PasteboardPasteResult {
        let fileSlots = files.map { file in
            return Anytype_Rpc.Block.Paste.Request.File.with {
                $0.name = file.name
                $0.data = Data()
                $0.localPath = file.path
            }
        }
        return try await paste(
            contextId: objectId,
            focusedBlockId: context.focusedBlockId,
            selectedTextRange: context.selectedRange,
            selectedBlockIds: context.selectedBlocksIds,
            isPartOfBlock: context.focusedBlockId.isNotEmpty,
            textSlot: "",
            htmlSlot: "",
            anySlots:  [],
            fileSlots: fileSlots
        )
    }

    public func copy(blockInformations: [BlockInformation], objectId: BlockId, selectedTextRange: NSRange) async throws -> PasteboardCopyResult? {
        let blocks: [Anytype_Model_Block] = blockInformations.compactMap { info in
            BlockInformationConverter.convert(information: info)
        }
        let result = try await ClientCommands.blockCopy(.with {
            $0.contextID = objectId
            $0.blocks = blocks
            $0.selectedTextRange = selectedTextRange.asMiddleware
        }).invoke()

        let blocksSlots = result.anySlot.compactMap { modelBlock in
            try? modelBlock.jsonString()
        }
        return PasteboardCopyResult(textSlot: result.textSlot, htmlSlot: result.htmlSlot, blockSlot: blocksSlots)
    }
    
    public func cut(blockInformations: [BlockInformation], objectId: BlockId, selectedTextRange: NSRange) async throws -> PasteboardCopyResult? {
        let blocks: [Anytype_Model_Block] = blockInformations.compactMap { info in
            BlockInformationConverter.convert(information: info)
        }
        let result = try await ClientCommands.blockCut(.with {
            $0.contextID = objectId
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
                       fileSlots: [Anytype_Rpc.Block.Paste.Request.File]) async throws -> PasteboardPasteResult {

        let result = try await ClientCommands.blockPaste(.with {
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

        return PasteboardPasteResult(caretPosition: Int(result.caretPosition),
                                     isSameBlockCaret: result.isSameBlockCaret,
                                     blockIds: result.blockIds)
    }
}
