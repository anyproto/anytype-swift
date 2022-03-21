import BlocksModels
import ProtobufMessages 
import AnytypeCore

protocol PasteboardServiceProtocol {
    var hasValidURL: Bool { get }
    func pasteInsideBlock(focusedBlockId: BlockId, range: NSRange)
    func pasteInSelectedBlocks(selectedBlockIds: [BlockId])
    func copy(blocksIds: [BlockId], selectedTextRange: NSRange)
}

final class PasteboardService: PasteboardServiceProtocol {
    private let document: BaseDocumentProtocol
    private let pasteboardAction: PasteboardSlotActionProtocol
    private let pasteboardOperations = OperationQueue()

    init(document: BaseDocumentProtocol, pasteboardAction: PasteboardSlotAction) {
        self.document = document
        self.pasteboardAction = pasteboardAction
        self.pasteboardOperations.maxConcurrentOperationCount = 1
    }
    
    var hasValidURL: Bool {
        pasteboardAction.hasValidURL
    }
    
    func pasteInsideBlock(focusedBlockId: BlockId, range: NSRange) {
        let context = PasteboardActionContext(focusedBlockId: focusedBlockId, range: range, selectedBlocksIds: nil)
        paste(context: context)
    }
    
    func pasteInSelectedBlocks(selectedBlockIds: [BlockId]) {
        let context = PasteboardActionContext(focusedBlockId: nil, range: nil, selectedBlocksIds: selectedBlockIds)
        paste(context: context)
    }
    
    private func paste(context: PasteboardActionContext) {
        let operation = PasteboardOperation(pasteboardValue: pasteboardAction, context: context) { _ in
            #warning("add completion")
        }
        pasteboardOperations.addOperation(operation)
    }
    
    func copy(blocksIds: [BlockId], selectedTextRange: NSRange) {
        let blocksInfo = blocksIds.compactMap {
            document.infoContainer.get(id: $0)
        }
        copy(contextId: document.objectId, blocksInfo: blocksInfo, selectedTextRange: selectedTextRange)
    }
}

// MARK: - PasteboardSlotActionDelegate

extension PasteboardService: PasteboardSlotActionDelegate {
    func pasteText(_ text: String, context: PasteboardActionContext) {
        paste(contextId: document.objectId,
              focusedBlockId: context.focusedBlockId,
              selectedTextRange: context.range,
              selectedBlockIds: context.selectedBlocksIds,
              isPartOfBlock: context.focusedBlockId.isNotNil,
              textSlot: text,
              htmlSlot: nil,
              anySlots:  [],
              fileSlots: [])
    }

    func pasteHTML(_ text: String, context: PasteboardActionContext) {
        paste(contextId: document.objectId,
              focusedBlockId: context.focusedBlockId,
              selectedTextRange: context.range,
              selectedBlockIds: context.selectedBlocksIds,
              isPartOfBlock: context.focusedBlockId.isNotNil,
              textSlot: nil,
              htmlSlot: text,
              anySlots:  [],
              fileSlots: [])
    }

    func pasteBlock(_ blocks: [String], context: PasteboardActionContext) {
        let blocksSlots = blocks.compactMap { blockJSONSlot in
            try? Anytype_Model_Block(jsonString: blockJSONSlot)
        }
        paste(contextId: document.objectId,
              focusedBlockId: context.focusedBlockId,
              selectedTextRange: context.range,
              selectedBlockIds: context.selectedBlocksIds,
              isPartOfBlock: context.focusedBlockId.isNotNil,
              textSlot: nil,
              htmlSlot: nil,
              anySlots:  blocksSlots,
              fileSlots: [])
    }

    func pasteFile(localPath: String, name: String, context: PasteboardActionContext) {
        paste(contextId: document.objectId,
              focusedBlockId: context.focusedBlockId,
              selectedTextRange: context.range,
              selectedBlockIds: context.selectedBlocksIds,
              isPartOfBlock: context.focusedBlockId.isNotNil,
              textSlot: nil,
              htmlSlot: nil,
              anySlots:  [],
              fileSlots: [Anytype_Rpc.Block.Paste.Request.File(name: name, data: Data(), localPath: localPath)])
    }
}


// MARK: - Private methods for middle

private extension PasteboardService {
    
    private func paste(contextId: BlockId,
                       focusedBlockId: BlockId?,
                       selectedTextRange: NSRange?,
                       selectedBlockIds: [BlockId]?,
                       isPartOfBlock: Bool,
                       textSlot: String?,
                       htmlSlot: String?,
                       anySlots:  [Anytype_Model_Block]?,
                       fileSlots: [Anytype_Rpc.Block.Paste.Request.File]?) {
        
        let result = Anytype_Rpc.Block.Paste.Service.invoke(
            contextID: contextId,
            focusedBlockID: focusedBlockId ?? "",
            selectedTextRange: selectedTextRange?.asMiddleware ?? Anytype_Model_Range(),
            selectedBlockIds: selectedBlockIds ?? [],
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
    }
    
    private func copy(contextId: BlockId, blocksInfo: [BlockInformation], selectedTextRange: NSRange) {
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
            pasteboardAction.performCopy(textSlot: result.textSlot, htmlSlot: result.htmlSlot, blockSlot: anySlot)
        }
    }
}
