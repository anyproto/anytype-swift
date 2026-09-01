import Foundation
import Services
import AnytypeCore

enum QuickCaptureError: Error {
    case contentCopyFailed
}

protocol QuickCaptureServiceProtocol: AnyObject, Sendable {
    func lastCaptureSpaceId() -> String?
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

    func lastCaptureSpaceId() -> String? {
        draftStorage.lastCaptureSpaceId()
    }

    func obtainDraft(spaceId: String) async throws -> ObjectDetails {
        // Types + property details caches without workspaceOpen/setActiveSpace - the full
        // activation would make the space hub coordinator navigate under the capture sheet.
        // The document itself brings its dependencies in the objectShow response.
        await activeSpaceManager.prepareSpaceForPreview(spaceId: spaceId)
        let details: ObjectDetails
        if let restored = await storedDraft(spaceId: spaceId) {
            details = restored
        } else {
            details = try await createDraft(spaceId: spaceId, name: "")
        }
        // Recorded only once the draft is in hand - reopening into a space that just
        // failed to produce one would strand the user there every launch
        draftStorage.setLastCaptureSpaceId(spaceId)
        return details
    }

    func hasDraftWithContent(spaceId: String) async -> Bool {
        guard let details = await storedDraft(spaceId: spaceId) else { return false }
        // Title and body preview - an untouched draft is not worth warning about
        return details.name.isNotEmpty || details.snippet.isNotEmpty
    }

    // Until anytype-heart has a real unsynced-draft state, drafts live as isHidden
    // objects; committing publishes the object by removing the flag.
    func commitDraft(spaceId: String) async throws {
        guard let draftId = draftStorage.draftObjectId(spaceId: spaceId) else { return }
        try await objectActionsService.updateBundledDetails(contextID: draftId, details: [.isHidden(false)])
        draftStorage.setDraftObjectId(nil, spaceId: spaceId)
        await markDraftTypeAsUsed(objectId: draftId, spaceId: spaceId)
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

        // An empty paragraph carries nothing - copying it yields an empty slot, which
        // must not be mistaken for a failed copy
        let carriesContent = blocks.contains { info in
            if case let .text(text) = info.content { return text.text.isNotEmpty }
            return true
        }
        var copiedBlocks = [String]()
        if carriesContent {
            let copyResult = try await pasteboardMiddleService.copy(
                blockInformations: blocks,
                objectId: sourceDraftId,
                selectedTextRange: NSRange(location: 0, length: 0)
            )
            copiedBlocks = copyResult?.blockSlot ?? []
            guard copiedBlocks.isNotEmpty else {
                // Refuse rather than carry on towards deleting the source
                throw QuickCaptureError.contentCopyFailed
            }
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

        // Only now is the target where the draft actually lives - a failed move above
        // leaves the user on the source space, and reopening must agree with that
        draftStorage.setLastCaptureSpaceId(targetSpaceId)
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

    private func markDraftTypeAsUsed(objectId: String, spaceId: String) async {
        guard let details = try? await searchService.searchObjects(spaceId: spaceId, objectIds: [objectId]).first,
              details.type.isNotEmpty else { return }
        try? await objectActionsService.updateBundledDetails(
            contextID: details.type,
            details: [.lastUsedDate(.now)]
        )
    }

    // Callers prepare the space caches (prepareSpaceForPreview) before this
    private func createDraft(spaceId: String, name: String) async throws -> ObjectDetails {
        let type = try objectTypeProvider.defaultObjectType(spaceId: spaceId)
        // isHidden travels with the create request: a separate details write would
        // clear editorDeleteEmpty, so the draft would look edited from the start
        let details = try await objectActionsService.createObject(
            name: name,
            typeUniqueKey: type.uniqueKey,
            shouldDeleteEmptyObject: true,
            shouldSelectType: true,
            shouldSelectTemplate: false,
            spaceId: spaceId,
            origin: .none,
            templateId: nil,
            additionalDetails: [.isHidden(true)]
        )
        draftStorage.setDraftObjectId(details.id, spaceId: spaceId)
        return details
    }
}
