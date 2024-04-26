import AnytypeCore
import Foundation
import UniformTypeIdentifiers
import Services

final class PasteboardTask {

    private enum Constants {
        static let filesDirectory = "PasteboardTask"
    }
    
    // MARK: - Private variables
    
    private var alreadyStarted: Bool = false
    
    private let objectId: BlockId
    private let context: PasteboardActionContext
    private let pasteboardHelper: PasteboardHelper
    private let pasteboardMiddlewareService: PasteboardMiddlewareServiceProtocol

    // MARK: - Initializers

    init(
        objectId: BlockId,
        pasteboardHelper: PasteboardHelper,
        pasteboardMiddlewareService: PasteboardMiddlewareServiceProtocol,
        context: PasteboardActionContext
    ) {
        self.objectId = objectId
        self.pasteboardHelper = pasteboardHelper
        self.pasteboardMiddlewareService = pasteboardMiddlewareService
        self.context = context
    }

    func start() async throws -> PasteboardPasteResult? {
        guard !alreadyStarted else {
            return nil
        }
        
        alreadyStarted = true
        
        return try await performPaste()
    }

    private func performPaste() async throws -> PasteboardPasteResult? {
        guard pasteboardHelper.hasSlots else { return nil }
        
        AnytypeAnalytics.instance().logPasteBlock()
        
        // Find first item to paste with follow order anySlots (blocks slots), htmlSlot, textSlot, filesSlots
        // blocks slots
        if let blocksSlots = pasteboardHelper.obtainBlocksSlots() {
            return try await pasteboardMiddlewareService.pasteBlock(blocksSlots, objectId: objectId, context: context)
        }

        // html slot
        if let htmlSlot = pasteboardHelper.obtainHTMLSlot() {
            return try await pasteboardMiddlewareService.pasteHTML(htmlSlot, objectId: objectId, context: context)
        }

        // text slot
        if let textSlot = pasteboardHelper.obtainTextSlot() {
            return try await pasteboardMiddlewareService.pasteText(textSlot, objectId: objectId, context: context)
        }

        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(Constants.filesDirectory, isDirectory: true)
        
        var files = [PasteboardFile]()
        
        defer {
            files.forEach { try? FileManager.default.removeItem(atPath: $0.path) }
        }
        
        try await pasteboardHelper.obtainAsFiles().asyncForEach { itemProvider in
            try Task.checkCancellation()
            let path = try? await itemProvider.loadFileRepresentation(forTypeIdentifier: UTType.data.identifier, directory: directory)
            if let path {
                files.append(PasteboardFile(path: path.relativePath, name: itemProvider.suggestedName ?? ""))
            }
        }
        
        try Task.checkCancellation()
        return try await pasteboardMiddlewareService.pasteFiles(files, objectId: objectId, context: context)
    }
}
