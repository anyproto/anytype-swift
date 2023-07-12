import Services
import Foundation
import Combine

final class PasteboardService: PasteboardServiceProtocol {
    private let document: BaseDocumentProtocol
    private let pasteboardHelper: PasteboardHelper
    private let pasteboardMiddlewareService: PasteboardMiddlewareServiceProtocol
    
    private var tasks = [AnyCancellable]()

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
        
        let task = PasteboardTask(
            pasteboardHelper: pasteboardHelper,
            pasteboardMiddlewareService: pasteboardMiddlewareService,
            context: context
        )
        
        Task {
            let pasteResult = try? await task.start()
            
            DispatchQueue.main.async {
                workItem.cancel()
                completion(pasteResult)
            }
        }
        .cancellable()
        .store(in: &tasks)
    }
    
    func copy(blocksIds: [BlockId], selectedTextRange: NSRange) async throws {
        if let result = try await pasteboardMiddlewareService.copy(blocksIds: blocksIds, selectedTextRange: selectedTextRange) {
            pasteboardHelper.setItems(textSlot: result.textSlot, htmlSlot: result.htmlSlot, blocksSlots: result.blockSlot)
        }
    }
    
    deinit {
        print("lol")
    }
}

private extension PasteboardService {
    enum Constants {
        static let longOperationTime: Double = 0.5
    }
}
