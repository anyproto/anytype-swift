import AnytypeCore
import Foundation
import UniformTypeIdentifiers
import Services

final class PasteboardTask: Sendable {

    private enum Constants {
        static let filesDirectory = "PasteboardTask"
    }
    
    // MARK: - Private variables
    
    private let alreadyStarted = AtomicStorage(false)
    
    private let objectId: String
    private let spaceId: String
    private let context: PasteboardActionContext
    private let pasteboardHelper: any PasteboardHelperProtocol
    private let pasteboardMiddlewareService: any PasteboardMiddlewareServiceProtocol

    // MARK: - Initializers

    init(
        objectId: String,
        spaceId: String,
        pasteboardHelper: some PasteboardHelperProtocol,
        pasteboardMiddlewareService: any PasteboardMiddlewareServiceProtocol,
        context: PasteboardActionContext
    ) {
        self.objectId = objectId
        self.spaceId = spaceId
        self.pasteboardHelper = pasteboardHelper
        self.pasteboardMiddlewareService = pasteboardMiddlewareService
        self.context = context
    }

    func start() async throws -> PasteboardPasteResult? {
        guard !alreadyStarted.value else {
            return nil
        }
        
        alreadyStarted.value = true
        
        return try await performPaste()
    }

    private func performPaste() async throws -> PasteboardPasteResult? {
        guard pasteboardHelper.hasSlots else { return nil }
        
        // Find first item to paste with follow order anySlots (blocks slots), htmlSlot, textSlot, filesSlots
        // blocks slots
        if let blocksSlots = pasteboardHelper.obtainBlocksSlots() {
            AnytypeAnalytics.instance().logPasteBlock(spaceId: spaceId, countBlocks: blocksSlots.count)
            return try await pasteboardMiddlewareService.pasteBlock(blocksSlots, objectId: objectId, context: context)
        }

        // html slot
        if let htmlSlot = pasteboardHelper.obtainHTMLSlot() {
            AnytypeAnalytics.instance().logPasteBlock(spaceId: spaceId, countBlocks: 1)
            return try await pasteboardMiddlewareService.pasteHTML(htmlSlot, objectId: objectId, context: context)
        }

        // text slot
        if let textSlot = pasteboardHelper.obtainTextSlot() {
            AnytypeAnalytics.instance().logPasteBlock(spaceId: spaceId, countBlocks: 1)
            return try await pasteboardMiddlewareService.pasteText(textSlot, objectId: objectId, context: context)
        }

        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(Constants.filesDirectory, isDirectory: true)
        
        var files = [PasteboardFile]()
        
        defer {
            files.forEach { try? FileManager.default.removeItem(atPath: $0.path) }
        }
        
        let fileSlots = pasteboardHelper.obtainFileSlots()
        AnytypeAnalytics.instance().logPasteBlock(spaceId: spaceId, countBlocks: fileSlots.count)
        
        for itemProvider in fileSlots {
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
