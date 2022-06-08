import BlocksModels

final class PasteboardService: PasteboardServiceProtocol {
    private let document: BaseDocumentProtocol
    private let pasteboardHelper: PasteboardHelper
    private let pasteboardMiddlewareService: PasteboardMiddlewareServiceProtocol
    private let pasteboardOperations: OperationQueue = {
        let queue = OperationQueue()
        queue.qualityOfService = .utility
        queue.maxConcurrentOperationCount = 1
        return queue
    }()

    init(document: BaseDocumentProtocol,
         pasteboardHelper: PasteboardHelper,
         pasteboardMiddlewareService: PasteboardMiddlewareServiceProtocol) {
        self.document = document
        self.pasteboardMiddlewareService = pasteboardMiddlewareService
        self.pasteboardHelper = pasteboardHelper
    }
    
    var hasValidURL: Bool {
        pasteboardHelper.hasValidURL
    }
    
    func pasteInsideBlock(focusedBlockId: BlockId,
                          range: NSRange,
                          handleLongOperation:  @escaping () -> Void,
                          completion: @escaping (_ pasteResult: PasteboardPasteResult?) -> Void) {
        let context = PasteboardActionContext.focused(focusedBlockId, range)
        paste(context: context, handleLongOperation: handleLongOperation, completion: completion)
    }
    
    func pasteInSelectedBlocks(selectedBlockIds: [BlockId],
                               handleLongOperation:  @escaping () -> Void,
                               completion: @escaping (_ pasteResult: PasteboardPasteResult?) -> Void) {
        let context = PasteboardActionContext.selected(selectedBlockIds)
        paste(context: context, handleLongOperation: handleLongOperation, completion: completion)
    }
    
    private func paste(context: PasteboardActionContext,
                       handleLongOperation:  @escaping () -> Void,
                       completion: @escaping (_ pasteResult: PasteboardPasteResult?) -> Void) {
        let workItem = DispatchWorkItem {
            handleLongOperation()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.longOperationTime, execute: workItem)

        let operation = PasteboardOperation (
            pasteboardHelper: pasteboardHelper,
            pasteboardMiddlewareService: pasteboardMiddlewareService,
            context: context
        ) { pasteResult in
            DispatchQueue.main.async {
                workItem.cancel()
                completion(pasteResult)
            }
        }
        pasteboardOperations.addOperation(operation)
    }
    
    func copy(blocksIds: [BlockId], selectedTextRange: NSRange) {
        if let result = pasteboardMiddlewareService.copy(blocksIds: blocksIds, selectedTextRange: selectedTextRange) {
            pasteboardHelper.setItems(textSlot: result.textSlot, htmlSlot: result.htmlSlot, blocksSlots: result.blockSlot)
        }
    }
}

private extension PasteboardService {
    enum Constants {
        static let longOperationTime: Double = 0.5
    }
}
