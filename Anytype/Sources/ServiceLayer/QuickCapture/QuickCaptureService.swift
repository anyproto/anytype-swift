import Foundation
import Services
import AnytypeCore

enum QuickCaptureError: Error {
    case contentCopyFailed
}

protocol QuickCaptureServiceProtocol: AnyObject, Sendable {
    func obtainDraft(spaceId: String) async throws -> ObjectDetails
    func hasDraftWithContent(spaceId: String) async -> Bool
    func commitDraft(spaceId: String) async throws
    func clearDraft(spaceId: String) async throws
    func moveDraft(
        from sourceSpaceId: String,
        to targetSpaceId: String,
        blocks: [BlockInformation],
        name: String
    ) async throws -> ObjectDetails
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

    func obtainDraft(spaceId: String) async throws -> ObjectDetails {
        // Types + property details caches without workspaceOpen/setActiveSpace - the full
        // activation would make the space hub coordinator navigate under the capture sheet.
        // The document itself brings its dependencies in the objectShow response.
        await activeSpaceManager.prepareSpaceForPreview(spaceId: spaceId)
        if let details = await storedDraft(spaceId: spaceId) {
            return details
        }
        return try await createDraft(spaceId: spaceId, name: "")
    }

    func hasDraftWithContent(spaceId: String) async -> Bool {
        guard let details = await storedDraft(spaceId: spaceId) else { return false }
        // The middleware clears editorDeleteEmpty once the object gets real content
        return !details.internalFlagsValue.contains(.editorDeleteEmpty)
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
        try await deleteDraft(objectId: draftId, spaceId: spaceId)
    }

    func moveDraft(
        from sourceSpaceId: String,
        to targetSpaceId: String,
        blocks: [BlockInformation],
        name: String
    ) async throws -> ObjectDetails {
        guard sourceSpaceId != targetSpaceId else {
            return try await obtainDraft(spaceId: sourceSpaceId)
        }
        guard let sourceDraftId = draftStorage.draftObjectId(spaceId: sourceSpaceId) else {
            return try await obtainDraft(spaceId: targetSpaceId)
        }

        let copyResult = try await pasteboardMiddleService.copy(
            blockInformations: blocks,
            objectId: sourceDraftId,
            selectedTextRange: NSRange(location: 0, length: 0)
        )
        let copiedBlocks = copyResult?.blockSlot ?? []
        guard blocks.isEmpty || copiedBlocks.isNotEmpty else {
            // Refuse rather than carry on towards deleting the source
            throw QuickCaptureError.contentCopyFailed
        }

        await activeSpaceManager.prepareSpaceForPreview(spaceId: targetSpaceId)

        // Nothing is destroyed until the content is safely in the target space
        let replacedDraftId = draftStorage.draftObjectId(spaceId: targetSpaceId)
        let newDraft = try await createDraft(spaceId: targetSpaceId, name: name)
        do {
            if copiedBlocks.isNotEmpty {
                let firstBlockId = try await blockService.addFirstBlock(contextId: newDraft.id, info: .emptyText)
                _ = try await pasteboardMiddleService.pasteBlock(
                    copiedBlocks,
                    objectId: newDraft.id,
                    context: .focused(blockId: firstBlockId, range: NSRange(location: 0, length: 0))
                )
            }
        } catch {
            try? await objectActionsService.delete(objectIds: [newDraft.id])
            draftStorage.setDraftObjectId(replacedDraftId, spaceId: targetSpaceId)
            throw error
        }

        if let replacedDraftId {
            try? await objectActionsService.delete(objectIds: [replacedDraftId])
        }
        // A failed delete keeps the pointer, so the leftover copy stays reachable
        // instead of becoming a hidden object nothing can ever open
        try? await deleteDraft(objectId: sourceDraftId, spaceId: sourceSpaceId)

        return newDraft
    }

    // MARK: - Private

    private func storedDraft(spaceId: String) async -> ObjectDetails? {
        guard let draftId = draftStorage.draftObjectId(spaceId: spaceId) else { return nil }
        // Ids filter only - the default search filters exclude hidden objects
        let details = try? await searchService.searchObjects(spaceId: spaceId, objectIds: [draftId]).first
        guard let details, !details.isDeleted, !details.isArchived else {
            // Empty drafts are auto-deleted by the middleware on close - the pointer just goes stale
            draftStorage.setDraftObjectId(nil, spaceId: spaceId)
            return nil
        }
        return details
    }

    private func deleteDraft(objectId: String, spaceId: String) async throws {
        try await objectActionsService.delete(objectIds: [objectId])
        draftStorage.setDraftObjectId(nil, spaceId: spaceId)
    }

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
        do {
            try await objectActionsService.updateBundledDetails(contextID: details.id, details: [.isHidden(true)])
        } catch {
            // A visible object nothing tracks is worse than no draft at all
            try? await objectActionsService.delete(objectIds: [details.id])
            throw error
        }
        draftStorage.setDraftObjectId(details.id, spaceId: spaceId)
        return details
    }
}
