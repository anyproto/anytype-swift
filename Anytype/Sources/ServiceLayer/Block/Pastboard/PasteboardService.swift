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
        let context = PasteboardActionContext.focused(focusedBlockId, range)
        paste(context: context)
    }
    
    func pasteInSelectedBlocks(selectedBlockIds: [BlockId]) {
        let context = PasteboardActionContext.selected(selectedBlockIds)
        paste(context: context)
    }
    
    private func paste(context: PasteboardActionContext) {
        let operation = PasteboardOperation(pasteboardValue: pasteboardAction, context: context) { _ in
            #warning("add completion")
        }
        pasteboardOperations.addOperation(operation)
    }
    
    func copy(blocksIds: [BlockId], selectedTextRange: NSRange) {
        pasteboardAction.performCopy(blocksIds: blocksIds, selectedTextRange: selectedTextRange)
    }
}
