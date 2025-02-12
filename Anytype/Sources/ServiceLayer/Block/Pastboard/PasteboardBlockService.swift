import Services
@preconcurrency import Foundation
import Combine
import AnytypeCore

final class PasteboardBlockService: PasteboardBlockServiceProtocol, Sendable {
    
    private let pasteboardHelper: any PasteboardHelperProtocol = Container.shared.pasteboardHelper()
    private let pasteboardMiddlewareService: any PasteboardMiddlewareServiceProtocol = Container.shared.pasteboardMiddleService()
    
    private let tasks = SynchronizedArray<AnyCancellable>()
    
    var hasValidURL: Bool {
        pasteboardHelper.hasValidURL
    }
    
    var pasteboardContent: PasteboardContent? {
        pasteboardHelper.pasteboardContent
    }
    
    func pasteInsideBlock(
        objectId: String,
        spaceId: String,
        focusedBlockId: String,
        range: NSRange,
        handleLongOperation:  @escaping () -> Void,
        completion: @escaping @Sendable @MainActor (_ pasteResult: PasteboardPasteResult?) -> Void
    ) {
        let context = PasteboardActionContext.focused(blockId: focusedBlockId, range: range)
        paste(objectId: objectId, spaceId: spaceId, context: context, handleLongOperation: handleLongOperation, completion: completion)
    }
    
    func pasteInSelectedBlocks(
        objectId: String,
        spaceId: String,
        selectedBlockIds: [String],
        handleLongOperation:  @escaping () -> Void,
        completion: @escaping @Sendable @MainActor (_ pasteResult: PasteboardPasteResult?) -> Void
    ) {
        let context = PasteboardActionContext.selected(blockIds: selectedBlockIds)
        paste(objectId: objectId, spaceId: spaceId, context: context, handleLongOperation: handleLongOperation, completion: completion)
    }
    
    private func paste(
        objectId: String,
        spaceId: String,
        context: PasteboardActionContext,
        handleLongOperation:  @escaping () -> Void,
        completion: @escaping @Sendable @MainActor (_ pasteResult: PasteboardPasteResult?) -> Void
    ) {
        
        let workItem = DispatchWorkItem {
            handleLongOperation()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.longOperationTime, execute: workItem)
        
        let pasteboardTask = PasteboardTask(
            objectId: objectId,
            spaceId: spaceId,
            pasteboardHelper: pasteboardHelper,
            pasteboardMiddlewareService: pasteboardMiddlewareService,
            context: context
        )
        
        let task = Task { @Sendable in
            let pasteResult = try? await pasteboardTask.start()
            
            DispatchQueue.main.async {
                workItem.cancel()
                completion(pasteResult)
            }
        }
        .cancellable()
        
        tasks.append(task)
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

