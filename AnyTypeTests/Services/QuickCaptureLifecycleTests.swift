import Foundation
import Testing
import Services
@testable import Anytype

@MainActor
@Suite(.serialized)
final class QuickCaptureLifecycleTests {
    private let service: CaptureLifecycleServiceStub
    private let model: QuickCaptureCoordinatorViewModel

    init() {
        let service = CaptureLifecycleServiceStub()
        self.service = service
        Container.shared.quickCaptureService.register { service }
        Container.shared.openedDocumentProvider.register { CaptureDocumentsStub() }
        model = QuickCaptureCoordinatorViewModel { _ in }
    }

    deinit {
        Container.shared.quickCaptureService.reset()
        Container.shared.openedDocumentProvider.reset()
    }

    @Test func dismissingUntouchedEmptyDraftRunsCleanup() async {
        await model.openDraft(spaceId: "source")
        await model.onDismiss()
        #expect(service.deletedIds == ["draft-source"])
    }

    @Test func dismissingEditedButApparentlyEmptyDraftDoesNotRacePendingText() async {
        await model.openDraft(spaceId: "source")
        model.onUserInput()
        #expect(!model.isNotEmpty)
        await model.onDismiss()
        #expect(service.deletedIds.isEmpty)
    }

    @Test func dismissingDuringSendOrAnotherOperationDoesNotCleanUp() async {
        await model.openDraft(spaceId: "source")
        model.isProcessing = true
        await model.onDismiss()
        #expect(service.deletedIds.isEmpty)
    }

    @Test func switchingAwayFromEditedEmptyDraftPreservesIt() async {
        await model.openDraft(spaceId: "source")
        model.onUserInput()
        await model.openDraft(spaceId: "target")
        await model.onDismiss()
        #expect(service.deletedIds == ["draft-target"])
    }

    @Test func keepBothNeverAutoDeletesTheSourceEvenIfItBecameEmpty() async {
        await model.openDraft(spaceId: "source")
        await model.onKeepBothDrafts(.mock(id: "target", accountStatus: .spaceActive, localStatus: .ok))
        await model.onDismiss()
        #expect(service.deletedIds == ["draft-target"])
    }

    @Test func switchingDoesNotWaitForOldDraftCleanupButDismissalDoes() async {
        let gate = CaptureCleanupGate()
        service.deleteGate = gate
        await model.openDraft(spaceId: "source")
        await model.openDraft(spaceId: "target")
        #expect(model.editorData?.objectId == "draft-target")
        await gate.waitUntilEntered()
        await gate.release()
        await model.onDismiss()
        #expect(Set(service.deletedIds) == ["draft-source", "draft-target"])
    }

    @Test func cleanupSurvivesCancellationOfPresentationTask() async {
        await model.openDraft(spaceId: "source")
        let dismissal = Task {
            withUnsafeCurrentTask { $0?.cancel() }
            await model.onDismiss()
        }
        await dismissal.value
        #expect(service.deletedIds == ["draft-source"])
        #expect(!service.cleanupWasCancelled)
    }
}

@MainActor
private final class CaptureLifecycleServiceStub: QuickCaptureServiceProtocol {
    var deletedIds = [String]()
    var cleanupWasCancelled = false
    var deleteGate: CaptureCleanupGate?

    nonisolated func lastCaptureSpaceId() -> String? { "source" }
    func discoverDrafts() async throws -> QuickCaptureDraftDiscovery { .init(drafts: [], isComplete: true) }
    func obtainDraft(spaceId: String) async throws -> ObjectDetails {
        ObjectDetails(id: "draft-\(spaceId)", values: ["spaceId": spaceId.protobufValue])
    }
    func hasDraftWithContent(spaceId: String) async throws -> Bool { false }
    func commitDraft(objectId: String, spaceId: String) async throws { }
    func clearDraft(objectId: String, spaceId: String) async throws { deletedIds.append(objectId) }
    func deleteDraftIfEmpty(objectId: String, spaceId: String) async throws -> Bool {
        cleanupWasCancelled = Task.isCancelled
        if let deleteGate { await deleteGate.enter() }
        deletedIds.append(objectId)
        return true
    }
    func moveDraft(objectId: String, from sourceSpaceId: String, to targetSpaceId: String) async throws -> ObjectDetails {
        try await obtainDraft(spaceId: targetSpaceId)
    }
}

private struct CaptureDocumentsStub: OpenedDocumentsProviderProtocol {
    func document(objectId: String, spaceId: String, mode: DocumentMode) -> any BaseDocumentProtocol {
        let document = MockBaseDocument(objectId: objectId)
        document.mockSpaceId = spaceId
        return document
    }
    func setDocument(objectId: String, spaceId: String, mode: DocumentMode) -> any SetDocumentProtocol {
        fatalError("Quick Capture must not open a set document")
    }
}

private actor CaptureCleanupGate {
    private var entered = false
    private var released = false
    private var entryWaiter: CheckedContinuation<Void, Never>?
    private var releaseWaiter: CheckedContinuation<Void, Never>?

    func enter() async {
        entered = true
        entryWaiter?.resume()
        entryWaiter = nil
        if !released { await withCheckedContinuation { releaseWaiter = $0 } }
    }

    func waitUntilEntered() async {
        if !entered { await withCheckedContinuation { entryWaiter = $0 } }
    }

    func release() {
        released = true
        releaseWaiter?.resume()
        releaseWaiter = nil
    }
}
