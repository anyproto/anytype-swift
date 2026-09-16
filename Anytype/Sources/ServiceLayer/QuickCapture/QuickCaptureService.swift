import Foundation
import Services
import AnytypeCore
import ProtobufMessages

enum QuickCaptureError: LocalizedError {
    case contentCopyFailed
    case draftUnavailable
    case discoveryIncomplete
    case targetHasContent

    var errorDescription: String? { Loc.QuickCapture.operationFailed }
}

protocol QuickCaptureServiceProtocol: AnyObject, Sendable {
    func lastCaptureSpaceId() -> String?
    func discoverDrafts() async throws -> QuickCaptureDraftDiscovery
    func obtainDraft(spaceId: String) async throws -> ObjectDetails
    func hasDraftWithContent(spaceId: String) async throws -> Bool
    func commitDraft(objectId: String, spaceId: String) async throws
    func clearDraft(objectId: String, spaceId: String) async throws
    func deleteDraftIfEmpty(objectId: String, spaceId: String) async throws -> Bool
    func moveDraft(objectId: String, from sourceSpaceId: String, to targetSpaceId: String) async throws -> ObjectDetails
}

final class QuickCaptureService: QuickCaptureServiceProtocol, Sendable {

    @Injected(\.quickCaptureDraftStorage)
    private var draftStorage: any QuickCaptureDraftStorageProtocol
    @Injected(\.searchMiddleService)
    private var searchService: any SearchMiddleServiceProtocol
    @Injected(\.crossSpaceSearchMiddleService)
    private var crossSpaceSearchService: any CrossSpaceSearchMiddleServiceProtocol
    @Injected(\.participantsStorage)
    private var participantsStorage: any ParticipantsStorageProtocol
    @Injected(\.objectLifecycleService)
    private var objectLifecycleService: any ObjectLifecycleServiceProtocol
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

    private let discoveryStorage = AtomicStorage<QuickCaptureDraftDiscovery?>(nil)
    // Object.ListDelete returns before the space index drops the object, so a search right
    // after clearing a draft can hand the deleted draft back. Opening it then hangs on the
    // editor placeholder or fails resolution once the index catches up. Anything this device
    // deleted is never resolved again; the set only holds ids deleted in this session.
    private let deletedDraftIds = AtomicStorage<Set<String>>([])

    func lastCaptureSpaceId() -> String? {
        draftStorage.lastCaptureSpaceId()
    }

    func discoverDrafts() async throws -> QuickCaptureDraftDiscovery {
        let participantIds = participantsStorage.participants.map(\.id).filter(\.isNotEmpty)
        guard participantIds.isNotEmpty else { throw QuickCaptureError.discoveryIncomplete }
        var drafts = [ObjectDetails]()
        var offset = 0
        while true {
            try Task.checkCancellation()
            let result = try await crossSpaceSearchService.search(
                data: QuickCaptureDraft.discoveryRequest(
                    participantIds: participantIds, localDraftIds: draftStorage.draftObjectIds(), offset: offset
                )
            )
            drafts.append(contentsOf: result.records.filter { isDraft($0, spaceId: $0.spaceId) })
            guard result.allStoresLoaded else {
                let discovery = QuickCaptureDraftDiscovery(drafts: drafts, isComplete: false)
                discoveryStorage.value = discovery
                return discovery
            }
            guard result.records.count == 100 else { break }
            offset += result.records.count
        }
        let discovery = QuickCaptureDraftDiscovery(drafts: drafts, isComplete: true)
        discoveryStorage.value = discovery
        return discovery
    }

    func obtainDraft(spaceId: String) async throws -> ObjectDetails {
        // Prepare caches without navigating the space hub underneath the sheet.
        await activeSpaceManager.prepareSpaceForPreview(spaceId: spaceId)
        let details: ObjectDetails
        if let restored = try await storedDraft(spaceId: spaceId) {
            details = restored
        } else {
            details = try await createDraft(spaceId: spaceId)
        }
        draftStorage.setDraftObjectId(details.id, spaceId: spaceId)
        draftStorage.setLastCaptureSpaceId(spaceId)
        return details
    }

    func hasDraftWithContent(spaceId: String) async throws -> Bool {
        guard let details = try await storedDraft(spaceId: spaceId, preferLocalHint: false) else { return false }
        // A snippet cannot establish emptiness: an image-only draft has no text preview.
        return try await draftContent(objectId: details.id, spaceId: spaceId).content.hasContent
    }

    func commitDraft(objectId: String, spaceId: String) async throws {
        let details = try await requireDraft(objectId: objectId, spaceId: spaceId)
        // Both flags must change in the same write, or discovery can reopen a published note.
        // A legacy draft was never created with isDraft, so its space has no such relation and
        // Object.SetDetails would reject the key; isHidden alone un-drafts it.
        var published: [BundledDetails] = [.isHidden(false)]
        if QuickCaptureDraft.hasDraftFlag(details) {
            published.append(.isDraft(false))
        }
        try await objectActionsService.updateBundledDetails(contextID: objectId, details: published)
        clearPointer(objectId: objectId, spaceId: spaceId)
        await markDraftTypeAsUsed(objectId: objectId, spaceId: spaceId)
    }

    func clearDraft(objectId: String, spaceId: String) async throws {
        _ = try await requireDraft(objectId: objectId, spaceId: spaceId)
        try await objectActionsService.delete(objectIds: [objectId])
        forgetDeletedDraft(objectId: objectId, spaceId: spaceId)
    }

    func deleteDraftIfEmpty(objectId: String, spaceId: String) async throws -> Bool {
        let snapshot = try await draftContent(objectId: objectId, spaceId: spaceId)
        guard snapshot.details.isHidden, !snapshot.content.hasContent else { return false }
        try Task.checkCancellation()
        try await objectActionsService.delete(objectIds: [objectId])
        forgetDeletedDraft(objectId: objectId, spaceId: spaceId)
        return true
    }

    func moveDraft(objectId: String, from sourceSpaceId: String, to targetSpaceId: String) async throws -> ObjectDetails {
        guard sourceSpaceId != targetSpaceId else {
            return try await requireDraft(objectId: objectId, spaceId: sourceSpaceId)
        }
        let source = try await draftContent(objectId: objectId, spaceId: sourceSpaceId)
        let copiedBlocks: [String]
        if source.content.copyableBlocks.contains(where: { !$0.content.isEmpty }) {
            copiedBlocks = try await pasteboardMiddleService.copy(
                blockInformations: source.content.copyableBlocks,
                objectId: objectId,
                selectedTextRange: NSRange(location: 0, length: 0)
            )?.blockSlot ?? []
            guard copiedBlocks.isNotEmpty else { throw QuickCaptureError.contentCopyFailed }
        } else {
            copiedBlocks = []
        }

        await activeSpaceManager.prepareSpaceForPreview(spaceId: targetSpaceId)
        if let existing = try await storedDraft(spaceId: targetSpaceId, preferLocalHint: false) {
            let snapshot = try await draftContent(objectId: existing.id, spaceId: targetSpaceId)
            guard !snapshot.content.hasContent else { throw QuickCaptureError.targetHasContent }
        }
        // Even an empty off-screen draft can receive a remote edit while copying.
        // Leave it intact; discovery keeps it reachable if that happens.
        let target = try await createDraft(spaceId: targetSpaceId, sourceTypeId: source.details.type)

        // Keep both pointers throughout copying. Even a partial paste remains recoverable.
        draftStorage.setDraftObjectId(target.id, spaceId: targetSpaceId)
        if copiedBlocks.isNotEmpty {
            let firstBlockId = try await blockService.addFirstBlock(contextId: target.id, info: .emptyText)
            _ = try await pasteboardMiddleService.pasteBlock(
                copiedBlocks, objectId: target.id,
                context: .focused(blockId: firstBlockId, range: NSRange(location: 0, length: 0))
            )
        }
        // isDraft and isHidden were set when the target was created; only the copied metadata is written here.
        try await objectActionsService.updateBundledDetails(
            contextID: target.id,
            details: [.name(source.content.name), .description(source.content.description)]
        )
        let copied = try await draftContent(objectId: target.id, spaceId: targetSpaceId)
        guard copied.content.contains(source.content) else { throw QuickCaptureError.contentCopyFailed }

        // Re-read immediately before deletion: neither publication nor a concurrent edit
        // may turn a successful copy into permission to delete different content.
        let currentSource = try await draftContent(objectId: objectId, spaceId: sourceSpaceId)
        guard currentSource.content == source.content else { throw QuickCaptureError.contentCopyFailed }
        try Task.checkCancellation()
        // Destination bookkeeping precedes destruction. Cancellation can leave duplicates,
        // but must never leave the only remaining copy without a pointer.
        draftStorage.setLastCaptureSpaceId(targetSpaceId)
        try await objectActionsService.delete(objectIds: [objectId])
        forgetDeletedDraft(objectId: objectId, spaceId: sourceSpaceId)
        return copied.details
    }

    // MARK: - Draft resolution

    func storedDraft(spaceId: String, preferLocalHint: Bool = true) async throws -> ObjectDetails? {
        var localDraft: ObjectDetails?
        // Opening a known draft never waits for stores in other spaces to warm up.
        if let draftId = draftStorage.draftObjectId(spaceId: spaceId) {
            let details = try await fetchDetails(objectId: draftId, spaceId: spaceId)
            if isDraft(details, spaceId: spaceId) {
                // A legacy draft (hidden, no isDraft) is not stamped here: Object.SetDetails
                // rejects isDraft in a space where no object was created with it. It stays
                // reachable through the local pointer and is un-drafted on publish by isHidden.
                localDraft = details
                if preferLocalHint, let newer = discoveryStorage.value?.newestDraft(spaceId: spaceId), newer.id != details.id,
                   (newer.createdDate ?? .distantPast) > (details.createdDate ?? .distantPast) {
                    // The dot and switching logic resolve the same cross-device draft.
                    let resolved = try await requireDraft(objectId: newer.id, spaceId: spaceId)
                    draftStorage.setDraftObjectId(resolved.id, spaceId: spaceId)
                    return resolved
                }
                if preferLocalHint { return details }
            } else {
                // Only positive evidence invalidates the local hint, never an empty search/error.
                clearPointer(objectId: draftId, spaceId: spaceId)
            }
        }

        guard let participant = participantsStorage.participants.first(where: { $0.spaceId == spaceId && $0.id.isNotEmpty }) else {
            if let localDraft { return localDraft }
            throw QuickCaptureError.discoveryIncomplete
        }
        // ObjectSearch initializes this space's index before returning. Its successful
        // answer is authoritative for this space, unlike an incomplete cross-space snapshot.
        // This also lets the first capture open without waiting on other spaces at all.
        let request = QuickCaptureDraft.discoveryRequest(participantIds: [participant.id])
        let records = try await searchService.search(
            spaceId: spaceId, filters: request.filters, sorts: request.sorts, keys: request.keys, limit: 1
        )
        let candidates = (records + [localDraft].compactMap { $0 }).filter { isDraft($0, spaceId: spaceId) }
        if let candidate = candidates.max(by: { ($0.createdDate ?? .distantPast) < ($1.createdDate ?? .distantPast) }) {
            let details = try await requireDraft(objectId: candidate.id, spaceId: spaceId)
            draftStorage.setDraftObjectId(details.id, spaceId: spaceId)
            return details
        }
        if let known = discoveryStorage.value?.newestDraft(spaceId: spaceId) {
            // A conflicting positive snapshot is still a draft to resolve, never permission
            // to manufacture a replacement on an inconclusive answer.
            return try await requireDraft(objectId: known.id, spaceId: spaceId)
        }
        return nil
    }

    private func fetchDetails(objectId: String, spaceId: String) async throws -> ObjectDetails {
        let records = try await searchService.search(
            spaceId: spaceId,
            filters: [SearchHelper.includeIdsFilter([objectId])],
            keys: QuickCaptureDraft.keys,
            limit: 1
        )
        if let details = records.first { return details }
        // Search absence is inconclusive. ObjectShow can positively report deletion.
        do {
            let model = try await objectLifecycleService.openForPreview(contextId: objectId, spaceId: spaceId)
            guard let details = model.details.first(where: { $0.id == objectId }) else {
                throw QuickCaptureError.draftUnavailable
            }
            return ObjectDetails(id: details.id, values: details.details.fields)
        } catch let error as Anytype_Rpc.Object.Show.Response.Error where error.code == .objectDeleted {
            return ObjectDetails(id: objectId, values: [BundledPropertyKey.isDeleted.rawValue: true.protobufValue])
        }
    }

    private func requireDraft(objectId: String, spaceId: String) async throws -> ObjectDetails {
        let details = try await fetchDetails(objectId: objectId, spaceId: spaceId)
        guard isDraft(details, spaceId: spaceId) else { throw QuickCaptureError.draftUnavailable }
        return details
    }

    private func isDraft(_ details: ObjectDetails, spaceId: String) -> Bool {
        guard !deletedDraftIds.value.contains(details.id) else { return false }
        return QuickCaptureDraft.isDraft(details, participantId: participantsStorage.participants.first { $0.spaceId == spaceId }?.id)
    }

    private func forgetDeletedDraft(objectId: String, spaceId: String) {
        _ = deletedDraftIds.access { $0.insert(objectId) }
        clearPointer(objectId: objectId, spaceId: spaceId)
    }

    private func draftContent(objectId: String, spaceId: String) async throws -> (details: ObjectDetails, content: QuickCaptureDraftContent) {
        let model = try await objectLifecycleService.openForPreview(contextId: objectId, spaceId: spaceId)
        guard model.rootID == objectId,
              model.blocks.contains(where: { $0.id == objectId }),
              let rawDetails = model.details.first(where: { $0.id == objectId }) else {
            throw QuickCaptureError.draftUnavailable
        }
        let details = ObjectDetails(id: objectId, values: rawDetails.details.fields)
        guard isDraft(details, spaceId: spaceId) else { throw QuickCaptureError.draftUnavailable }
        let blocks = model.blocks.compactMap { BlockInformationConverter.convert(block: $0) }
        guard blocks.count == model.blocks.count else { throw QuickCaptureError.contentCopyFailed }
        return (details, QuickCaptureDraftContent(details: details, blocks: blocks))
    }

    private func clearPointer(objectId: String, spaceId: String) {
        if let discovery = discoveryStorage.value {
            discoveryStorage.value = QuickCaptureDraftDiscovery(
                drafts: discovery.drafts.filter { $0.id != objectId }, isComplete: discovery.isComplete
            )
        }
        guard draftStorage.draftObjectId(spaceId: spaceId) == objectId else { return }
        draftStorage.setDraftObjectId(nil, spaceId: spaceId)
    }

    private func markDraftTypeAsUsed(objectId: String, spaceId: String) async {
        guard let details = try? await fetchDetails(objectId: objectId, spaceId: spaceId), details.type.isNotEmpty else { return }
        try? await objectActionsService.updateBundledDetails(contextID: details.type, details: [.lastUsedDate(.now)])
    }

    private func createDraft(spaceId: String, sourceTypeId: String? = nil) async throws -> ObjectDetails {
        let type: ObjectType
        if let sourceTypeId,
           let sourceType = try? objectTypeProvider.objectType(id: sourceTypeId),
           let targetType = try? objectTypeProvider.objectType(uniqueKey: sourceType.uniqueKey, spaceId: spaceId) {
            type = targetType
        } else {
            type = try objectTypeProvider.defaultObjectType(spaceId: spaceId)
        }
        let details = try await objectActionsService.createObject(
            name: "", typeUniqueKey: type.uniqueKey,
            shouldDeleteEmptyObject: true, shouldSelectType: true, shouldSelectTemplate: false,
            spaceId: spaceId, origin: .none, templateId: nil,
            additionalDetails: [.isDraft(true), .isHidden(true)]
        )
        draftStorage.setDraftObjectId(details.id, spaceId: spaceId)
        return details
    }
}
