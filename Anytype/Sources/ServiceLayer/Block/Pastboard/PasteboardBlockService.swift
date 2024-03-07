import Services
import Foundation
import Combine

final class PasteboardBlockService: PasteboardBlockServiceProtocol {
    
    @Injected(\.pasteboardHelper)
    private var pasteboardHelper: PasteboardHelperProtocol
    @Injected(\.pasteboardMiddleService)
    private var pasteboardMiddlewareService: PasteboardMiddlewareServiceProtocol
    
    private var tasks = [AnyCancellable]()
    
    var hasValidURL: Bool {
        pasteboardHelper.hasValidURL
    }
    
    var pasteboardContent: PasteboardContent? {
        pasteboardHelper.pasteboardContent
    }
    
    func pasteInsideBlock(
        objectId: String,
        focusedBlockId: String,
        range: NSRange,
        handleLongOperation:  @escaping () -> Void,
        completion: @escaping (_ pasteResult: PasteboardPasteResult?) -> Void
    ) {
        let context = PasteboardActionContext.focused(blockId: focusedBlockId, range: range)
        paste(objectId: objectId, context: context, handleLongOperation: handleLongOperation, completion: completion)
    }
    
    func pasteInSelectedBlocks(
        objectId: String,
        selectedBlockIds: [String],
        handleLongOperation:  @escaping () -> Void,
        completion: @escaping (_ pasteResult: PasteboardPasteResult?) -> Void
    ) {
        let context = PasteboardActionContext.selected(blockIds: selectedBlockIds)
        paste(objectId: objectId, context: context, handleLongOperation: handleLongOperation, completion: completion)
    }
    
    private func paste(
        objectId: String,
        context: PasteboardActionContext,
        handleLongOperation:  @escaping () -> Void,
        completion: @escaping (_ pasteResult: PasteboardPasteResult?) -> Void
    ) {
        
        let workItem = DispatchWorkItem {
            handleLongOperation()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.longOperationTime, execute: workItem)
        
        let task = PasteboardTask(
            objectId: objectId,
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
    
    func copy(
        objectId: String,
        blockInfos: [BlockInformation],
        blocksIds: [String],
        selectedTextRange: NSRange
    ) async throws {
        if let result = try await pasteboardMiddlewareService.copy(
            blockInformations: blockInfos,
            objectId: objectId,
            selectedTextRange: selectedTextRange
        ) {
            pasteboardHelper.setItems(textSlot: result.textSlot, htmlSlot: result.htmlSlot, blocksSlots: result.blockSlot)
        }
    }
    
    func cut(
        objectId: String,
        blockInfos: [BlockInformation],
        blocksIds: [String],
        selectedTextRange: NSRange
    ) async throws {
        if let result = try await pasteboardMiddlewareService.cut(blockInformations: blockInfos, objectId: objectId, selectedTextRange: selectedTextRange) {
            pasteboardHelper.setItems(textSlot: result.textSlot, htmlSlot: result.htmlSlot, blocksSlots: result.blockSlot)
        }
    }
}

private extension PasteboardBlockService {
    enum Constants {
        static let longOperationTime: Double = 0.5
    }
}

