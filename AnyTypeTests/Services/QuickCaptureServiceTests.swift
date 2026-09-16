import Foundation
import Testing
import Services
import AnytypeCore
import AsyncTools
import ProtobufMessages
@testable import Anytype

@Suite(.serialized)
final class QuickCaptureServiceTests {
    private let storage: CaptureDraftStorageStub
    private let middleware: CaptureMiddlewareStub
    private let service: QuickCaptureService

    init() {
        let storage = CaptureDraftStorageStub()
        let middleware = CaptureMiddlewareStub()
        self.storage = storage
        self.middleware = middleware
        Container.shared.quickCaptureDraftStorage.register { storage }
        Container.shared.objectLifecycleService.register { middleware }
        Container.shared.objectActionsService.register { middleware }
        Container.shared.searchMiddleService.register { middleware }
        Container.shared.crossSpaceSearchMiddleService.register { middleware }
        Container.shared.participantsStorage.register { CaptureParticipantsStub() }
        service = QuickCaptureService()
    }

    deinit {
        Container.shared.quickCaptureDraftStorage.reset()
        Container.shared.objectLifecycleService.reset()
        Container.shared.objectActionsService.reset()
        Container.shared.searchMiddleService.reset()
        Container.shared.crossSpaceSearchMiddleService.reset()
        Container.shared.participantsStorage.reset()
    }

    @Test func emptyDraftIsPermanentlyDeletedBeforePointerIsCleared() async throws {
        await middleware.setView(view())
        #expect(try await service.deleteDraftIfEmpty(objectId: "draft", spaceId: "space"))
        #expect(await middleware.deletedIds == ["draft"])
        #expect(storage.draftObjectId(spaceId: "space") == nil)
        #expect(await middleware.archiveCalls == 0)
    }

    @Test func failedDeletePreservesPointer() async {
        await middleware.setView(view())
        await middleware.failDelete()
        await #expect(throws: CaptureTestError.self) {
            try await service.deleteDraftIfEmpty(objectId: "draft", spaceId: "space")
        }
        #expect(storage.draftObjectId(spaceId: "space") == "draft")
    }

    @Test func missingSnapshotRootOrDetailsNeverAuthorizesDeletion() async {
        var noRoot = view()
        noRoot.blocks = []
        var noDetails = view()
        noDetails.details = []
        for snapshot in [noRoot, noDetails] {
            await middleware.setView(snapshot)
            await #expect(throws: QuickCaptureError.self) {
                try await service.deleteDraftIfEmpty(objectId: "draft", spaceId: "space")
            }
        }
        #expect(await middleware.deletedIds.isEmpty)
        #expect(storage.draftObjectId(spaceId: "space") == "draft")
    }

    @Test func failedReadNeverDeletesOrClearsPointer() async {
        await #expect(throws: CaptureTestError.self) {
            try await service.deleteDraftIfEmpty(objectId: "draft", spaceId: "space")
        }
        #expect(await middleware.deletedIds.isEmpty)
        #expect(storage.draftObjectId(spaceId: "space") == "draft")
    }

    @Test func cancellationBeforeDeleteKeepsTheDraftAndPointer() async {
        await middleware.setView(view())
        let service = service
        let cleanup = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            return try await service.deleteDraftIfEmpty(objectId: "draft", spaceId: "space")
        }
        await #expect(throws: CancellationError.self) { try await cleanup.value }
        #expect(await middleware.deletedIds.isEmpty)
        #expect(storage.draftObjectId(spaceId: "space") == "draft")
    }

    @Test func visibleDraftIsNotAutoDeleted() async throws {
        await middleware.setView(view(details: draft().updated(by: ["isHidden": false.protobufValue])))
        #expect(try await !service.deleteDraftIfEmpty(objectId: "draft", spaceId: "space"))
        #expect(await middleware.deletedIds.isEmpty)
    }

    @Test func publishedArchivedDeletedAndForeignObjectsAreProtected() async {
        let variants = [
            draft().updated(by: ["isDraft": false.protobufValue]),
            draft().updated(by: ["isArchived": true.protobufValue]),
            draft().updated(by: ["isDeleted": true.protobufValue]),
            draft().updated(by: ["creator": "someone-else".protobufValue])
        ]
        for details in variants {
            await middleware.setView(view(details: details))
            await #expect(throws: QuickCaptureError.self) {
                try await service.deleteDraftIfEmpty(objectId: "draft", spaceId: "space")
            }
        }
        #expect(await middleware.deletedIds.isEmpty)
        #expect(storage.draftObjectId(spaceId: "space") == "draft")
    }

    @Test func descriptionAndNestedBodyTextAreProtected() async throws {
        for style in [BlockText.Style.description, .text] {
            var snapshot = view()
            snapshot.blocks.append(try #require(BlockInformationConverter.convert(information:
                .empty(id: "nested", content: .text(.plain("Unsent", contentType: style)))
            )))
            await middleware.setView(snapshot)
            #expect(try await !service.deleteDraftIfEmpty(objectId: "draft", spaceId: "space"))
        }
        #expect(await middleware.deletedIds.isEmpty)
    }

    @Test func attachmentOnlyDraftIsProtected() async throws {
        var snapshot = view()
        snapshot.blocks.append(try #require(BlockInformationConverter.convert(information:
            .empty(id: "image", content: .file(.empty(contentType: .image)))
        )))
        await middleware.setView(snapshot)
        #expect(try await !service.deleteDraftIfEmpty(objectId: "draft", spaceId: "space"))
        #expect(await middleware.deletedIds.isEmpty)
    }

    @Test func unconvertibleBlockPreventsCleanup() async {
        var snapshot = view()
        snapshot.blocks.append(.with { $0.id = "unknown" })
        await middleware.setView(snapshot)
        await #expect(throws: QuickCaptureError.self) {
            try await service.deleteDraftIfEmpty(objectId: "draft", spaceId: "space")
        }
        #expect(await middleware.deletedIds.isEmpty)
        #expect(storage.draftObjectId(spaceId: "space") == "draft")
    }

    @Test func cleanupDoesNotClearReplacementPointer() async throws {
        await middleware.setView(view())
        storage.setDraftObjectId("replacement", spaceId: "space")
        #expect(try await service.deleteDraftIfEmpty(objectId: "draft", spaceId: "space"))
        #expect(storage.draftObjectId(spaceId: "space") == "replacement")
    }

    @Test(arguments: [true, false])
    func legacyDraftIsResolvedWithoutWritingDraftFlag(preferLocalHint: Bool) async throws {
        // Object.SetDetails rejects isDraft in a space where no object was created with it,
        // so opening never stamps a legacy draft.
        let legacy = ObjectDetails(id: "draft", values: [
            "isHidden": true.protobufValue, "spaceId": "space".protobufValue,
            "creator": "me".protobufValue, "createdDate": 1.protobufValue,
            "name": "Unsent legacy draft".protobufValue, "isDraft": .with { $0.nullValue = .nullValue }
        ])
        let newer = draft(id: "newer").updated(by: ["createdDate": 2.protobufValue])
        await middleware.setSearchRecords([legacy, newer])
        _ = try await service.discoverDrafts()

        let resolved = try await service.storedDraft(spaceId: "space", preferLocalHint: preferLocalHint)

        #expect(resolved?.id == "newer")
        #expect(await middleware.detailWrites.isEmpty)
        #expect(storage.draftObjectId(spaceId: "space") == "newer")
    }

    @Test func clearedDraftIsNotResurrectedByStaleSearch() async throws {
        // The stub keeps deleted records in search results, like the space index does for a
        // moment after Object.ListDelete.
        await middleware.setSearchRecords([draft()])

        try await service.clearDraft(objectId: "draft", spaceId: "space")

        #expect(await middleware.deletedIds == ["draft"])
        #expect(storage.draftObjectId(spaceId: "space") == nil)
        #expect(try await service.storedDraft(spaceId: "space") == nil)
        #expect(try await service.discoverDrafts().drafts.isEmpty)
    }

    @Test func publishingLegacyDraftWritesOnlyHiddenFlag() async throws {
        let legacy = ObjectDetails(id: "draft", values: [
            "isHidden": true.protobufValue, "spaceId": "space".protobufValue, "creator": "me".protobufValue
        ])
        await middleware.setSearchRecords([legacy])

        try await service.commitDraft(objectId: "draft", spaceId: "space")

        let writes = await middleware.detailWrites
        #expect(writes.count == 1)
        #expect(writes.first?.contextID == "draft")
        let flags = writtenFlags(writes.first?.details)
        #expect(flags.isHidden == false)
        #expect(flags.isDraft == nil)
    }

    @Test func publishingFlaggedDraftClearsBothFlagsInOneWrite() async throws {
        await middleware.setSearchRecords([draft()])

        try await service.commitDraft(objectId: "draft", spaceId: "space")

        let writes = await middleware.detailWrites
        #expect(writes.count == 1)
        let flags = writtenFlags(writes.first?.details)
        #expect(flags.isDraft == false)
        #expect(flags.isHidden == false)
    }

    private func writtenFlags(_ details: [BundledDetails]?) -> (isDraft: Bool?, isHidden: Bool?) {
        var flags: (isDraft: Bool?, isHidden: Bool?) = (nil, nil)
        for detail in details ?? [] {
            switch detail {
            case .isDraft(let value): flags.isDraft = value
            case .isHidden(let value): flags.isHidden = value
            default: break
            }
        }
        return flags
    }

    private func draft(id: String = "draft") -> ObjectDetails {
        ObjectDetails(id: id, values: [
            "isHidden": true.protobufValue, "isDraft": true.protobufValue,
            "spaceId": "space".protobufValue, "creator": "me".protobufValue
        ])
    }

    private func view(details: ObjectDetails? = nil) -> ObjectViewModel {
        let details = details ?? draft()
        return .with {
            $0.rootID = details.id
            $0.blocks = [.with { $0.id = details.id; $0.smartblock = .init() }]
            $0.details = [.with { $0.id = details.id; $0.details.fields = details.values }]
        }
    }
}

private enum CaptureTestError: Error { case unavailable }

private final class CaptureDraftStorageStub: QuickCaptureDraftStorageProtocol, Sendable {
    private let ids = AtomicStorage(["space": "draft"])
    func draftObjectId(spaceId: String) -> String? { ids.value[spaceId] }
    func draftObjectIds() -> [String] { Array(ids.value.values) }
    func setDraftObjectId(_ objectId: String?, spaceId: String) { ids.access { $0[spaceId] = objectId } }
    func lastCaptureSpaceId() -> String? { "space" }
    func setLastCaptureSpaceId(_ spaceId: String) { }
}

private final class CaptureParticipantsStub: ParticipantsStorageProtocol, Sendable {
    let participants = [Participant(
        id: "me", localName: "", globalName: "", icon: nil, status: .active, permission: .owner,
        identity: "", identityProfileLink: "", spaceId: "space", type: ""
    )]
    private let stream = AsyncToManyStream<[Participant]>()
    var participantsSequence: AnyAsyncSequence<[Participant]> { stream.eraseToAnyAsyncSequence() }
    func startSubscription() async { }
    func stopSubscription() async { }
}

private actor CaptureMiddlewareStub: ObjectLifecycleServiceProtocol, ObjectActionsServiceProtocol, SearchMiddleServiceProtocol, CrossSpaceSearchMiddleServiceProtocol {
    private var snapshot: ObjectViewModel?
    private var records = [ObjectDetails]()
    private var deleteFails = false
    private(set) var deletedIds = [String]()
    private(set) var detailWrites = [(contextID: String, details: [BundledDetails])]()
    private(set) var archiveCalls = 0

    func setView(_ view: ObjectViewModel) { snapshot = view }
    func setSearchRecords(_ records: [ObjectDetails]) { self.records = records }
    func failDelete() { deleteFails = true }

    func openForPreview(contextId: String, spaceId: String) async throws -> ObjectViewModel {
        guard let snapshot else { throw CaptureTestError.unavailable }
        return snapshot
    }
    func open(contextId: String, spaceId: String) async throws -> ObjectViewModel { throw CaptureTestError.unavailable }
    func close(contextId: String, spaceId: String) async throws { }

    func delete(objectIds: [String]) async throws {
        if deleteFails { throw CaptureTestError.unavailable }
        deletedIds.append(contentsOf: objectIds)
    }

    func updateBundledDetails(contextID: String, details: [BundledDetails]) async throws {
        detailWrites.append((contextID, details))
    }

    func search(data: SearchRequest) async throws -> [ObjectDetails] {
        if let ids = data.filters.first(where: { $0.relationKey == "id" })?.value.listValue.values.map(\.stringValue) {
            return records.filter { ids.contains($0.id) }
        }
        return records.filter { $0.values["isDraft"]?.boolValue == true }
            .sorted { ($0.createdDate ?? .distantPast) > ($1.createdDate ?? .distantPast) }
    }

    func search(data: CrossSpaceSearchRequest) async throws -> CrossSpaceSearchResult {
        let localIds = data.filters.first?.nestedFilters.first(where: { $0.relationKey == "id" })?.value.listValue.values.map(\.stringValue) ?? []
        return CrossSpaceSearchResult(records: records.filter { $0.values["isDraft"]?.boolValue == true || localIds.contains($0.id) }
            .sorted { ($0.createdDate ?? .distantPast) > ($1.createdDate ?? .distantPast) }, allStoresLoaded: true)
    }

    func setArchive(objectIds: [String], _ isArchived: Bool) async throws { archiveCalls += 1 }
    func createObject(name: String, typeUniqueKey: ObjectTypeUniqueKey, shouldDeleteEmptyObject: Bool, shouldSelectType: Bool, shouldSelectTemplate: Bool, spaceId: String, origin: ObjectOrigin, templateId: String?, createdInContext: String, createdInContextRef: String, additionalDetails: [BundledDetails]) async throws -> ObjectDetails { throw CaptureTestError.unavailable }
    func setPin(objectIds: [String], _ isPinned: Bool) async throws { throw CaptureTestError.unavailable }
    func setLocked(_ isLocked: Bool, objectId: String) async throws { throw CaptureTestError.unavailable }
    func updateLayout(contextID: String, value: Int) async throws { throw CaptureTestError.unavailable }
    func duplicate(objectId: String) async throws -> String { throw CaptureTestError.unavailable }
    func applyTemplate(objectId: String, templateId: String) async throws { throw CaptureTestError.unavailable }
    func updateDetails(contextId: String, relationKey: String, value: DataviewGroupValue) async throws { throw CaptureTestError.unavailable }
    func setInternalFlags(contextId: String, internalFlags: [Int]) async throws { throw CaptureTestError.unavailable }
    func addObjectsToCollection(contextId: String, objectIds: [String]) async throws { throw CaptureTestError.unavailable }
    func setObjectType(objectId: String, typeUniqueKey: ObjectTypeUniqueKey) async throws { throw CaptureTestError.unavailable }
    func setObjectSetType(objectId: String) async throws { throw CaptureTestError.unavailable }
    func setObjectCollectionType(objectId: String) async throws { throw CaptureTestError.unavailable }
    func setSource(objectId: String, source: [String]) async throws { throw CaptureTestError.unavailable }
    func undo(objectId: String) async throws { throw CaptureTestError.unavailable }
    func redo(objectId: String) async throws { throw CaptureTestError.unavailable }
    func move(dashboadId: String, blockId: String, dropPositionblockId: String, position: Anytype_Model_Block.Position) async throws { throw CaptureTestError.unavailable }
    func createSet(name: String, iconEmoji: Emoji?, setOfObjectType: String, spaceId: String) async throws -> ObjectDetails { throw CaptureTestError.unavailable }
}
