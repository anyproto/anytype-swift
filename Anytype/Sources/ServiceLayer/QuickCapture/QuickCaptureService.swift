import Foundation
import Services
import AnytypeCore

struct QuickCaptureDraft: Sendable {
    let details: ObjectDetails
    let isRestored: Bool
}

protocol QuickCaptureServiceProtocol: AnyObject, Sendable {
    func obtainDraft(spaceId: String) async throws -> QuickCaptureDraft
    func commitDraft(spaceId: String) async throws
    func clearDraft(spaceId: String) async throws
    func moveDraft(from sourceSpaceId: String, to targetSpaceId: String) async throws -> ObjectDetails
}

final class QuickCaptureService: QuickCaptureServiceProtocol, Sendable {

    @Injected(\.quickCaptureDraftStorage)
    private var draftStorage: any QuickCaptureDraftStorageProtocol
    @Injected(\.searchService)
    private var searchService: any SearchServiceProtocol
    @Injected(\.objectActionsService)
    private var objectActionsService: any ObjectActionsServiceProtocol
    @Injected(\.objectTypeProvider)
    private var objectTypeProvider: any ObjectTypeProviderProtocol
    @Injected(\.activeSpaceManager)
    private var activeSpaceManager: any ActiveSpaceManagerProtocol
    @Injected(\.blockService)
    private var blockService: any BlockServiceProtocol
    @Injected(\.pasteboardMiddleService)
    private var pasteboardMiddleService: any PasteboardMiddlewareServiceProtocol
    @Injected(\.openedDocumentProvider)
    private var documentsProvider: any OpenedDocumentsProviderProtocol

    func obtainDraft(spaceId: String) async throws -> QuickCaptureDraft {
        // Types + property details caches without workspaceOpen/setActiveSpace - the full
        // activation would make the space hub coordinator navigate under the capture sheet.
        // The document itself brings its dependencies in the objectShow response.
        await activeSpaceManager.prepareSpaceForPreview(spaceId: spaceId)
        if let draftId = draftStorage.draftObjectId(spaceId: spaceId) {
            let details = try? await searchService.searchObjects(spaceId: spaceId, objectIds: [draftId]).first
            if let details, !details.isDeleted, !details.isArchived {
                return QuickCaptureDraft(details: details, isRestored: true)
            }
            // Empty drafts are auto-deleted by the middleware on close - the pointer just goes stale
            draftStorage.setDraftObjectId(nil, spaceId: spaceId)
        }
        let details = try await createDraft(spaceId: spaceId, name: "")
        return QuickCaptureDraft(details: details, isRestored: false)
    }

    // Until anytype-heart has a real unsynced-draft state, drafts live as isHidden
    // objects; committing publishes the object by removing the flag.
    func commitDraft(spaceId: String) async throws {
        guard let draftId = draftStorage.draftObjectId(spaceId: spaceId) else { return }
        try await objectActionsService.updateBundledDetails(contextID: draftId, details: [.isHidden(false)])
        draftStorage.setDraftObjectId(nil, spaceId: spaceId)
    }

    func clearDraft(spaceId: String) async throws {
        guard let draftId = draftStorage.draftObjectId(spaceId: spaceId) else { return }
        draftStorage.setDraftObjectId(nil, spaceId: spaceId)
        try await objectActionsService.delete(objectIds: [draftId])
    }

    func moveDraft(from sourceSpaceId: String, to targetSpaceId: String) async throws -> ObjectDetails {
        guard sourceSpaceId != targetSpaceId else {
            return try await obtainDraft(spaceId: sourceSpaceId).details
        }
        guard let sourceDraftId = draftStorage.draftObjectId(spaceId: sourceSpaceId) else {
            return try await obtainDraft(spaceId: targetSpaceId).details
        }

        let sourceDocument = documentsProvider.document(objectId: sourceDraftId, spaceId: sourceSpaceId)
        try await sourceDocument.open()
        let sourceName = sourceDocument.details?.name ?? ""
        let sourceBlocks = sourceDocument.children
        let copyResult = try await pasteboardMiddleService.copy(
            blockInformations: sourceBlocks,
            objectId: sourceDraftId,
            selectedTextRange: NSRange(location: 0, length: 0)
        )

        // The moved draft replaces whatever draft the target space held
        if let existingTargetDraftId = draftStorage.draftObjectId(spaceId: targetSpaceId) {
            draftStorage.setDraftObjectId(nil, spaceId: targetSpaceId)
            try? await objectActionsService.delete(objectIds: [existingTargetDraftId])
        }

        await activeSpaceManager.prepareSpaceForPreview(spaceId: targetSpaceId)
        let newDraft = try await createDraft(spaceId: targetSpaceId, name: sourceName)

        if let blockSlot = copyResult?.blockSlot, blockSlot.isNotEmpty {
            let firstBlockId = try await blockService.addFirstBlock(contextId: newDraft.id, info: .emptyText)
            _ = try await pasteboardMiddleService.pasteBlock(
                blockSlot,
                objectId: newDraft.id,
                context: .focused(blockId: firstBlockId, range: NSRange(location: 0, length: 0))
            )
        }

        try? await objectActionsService.delete(objectIds: [sourceDraftId])
        draftStorage.setDraftObjectId(nil, spaceId: sourceSpaceId)

        return newDraft
    }

    // MARK: - Private

    // Callers prepare the space caches (prepareSpaceForPreview) before this
    private func createDraft(spaceId: String, name: String) async throws -> ObjectDetails {
        let type = try objectTypeProvider.defaultObjectType(spaceId: spaceId)
        let details = try await objectActionsService.createObject(
            name: name,
            typeUniqueKey: type.uniqueKey,
            shouldDeleteEmptyObject: true,
            shouldSelectType: true,
            shouldSelectTemplate: false,
            spaceId: spaceId,
            origin: .none,
            templateId: nil
        )
        try await objectActionsService.updateBundledDetails(contextID: details.id, details: [.isHidden(true)])
        draftStorage.setDraftObjectId(details.id, spaceId: spaceId)
        return details
    }
}
