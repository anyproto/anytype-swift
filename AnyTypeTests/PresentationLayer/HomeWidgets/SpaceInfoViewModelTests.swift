import Testing
import Foundation
import Combine
@testable import Anytype
import Services
import Factory

@Suite(.serialized)
@MainActor
struct SpaceInfoViewModelTests {

    private let storage: TestSpaceViewsStorage
    private let participantsSubscription: TestParticipantsSubscription

    init() {
        let storage = TestSpaceViewsStorage()
        let participantsSubscription = TestParticipantsSubscription()
        Container.shared.spaceViewsStorage.register { storage }
        Container.shared.participantSubscription.register { _ in participantsSubscription }
        self.storage = storage
        self.participantsSubscription = participantsSubscription
    }

    // MARK: - init seed

    @Test func init_withCachedSpaceView_seedsAllFields() {
        storage.subject.value = [
            makeSpaceView(spaceId: "space-1", name: "My Space", spaceAccessType: .shared, spaceType: .regular)
        ]

        let model = SpaceInfoViewModel(spaceId: "space-1")

        #expect(model.spaceName == "My Space")
        #expect(model.spaceIcon != nil)
        #expect(model.sharedSpace == true)
        #expect(model.isOneToOne == false)
    }

    @Test func init_withNoCachedSpaceView_keepsDefaults() {
        let model = SpaceInfoViewModel(spaceId: "space-missing")

        #expect(model.spaceName == "")
        #expect(model.spaceIcon == nil)
        #expect(model.sharedSpace == false)
        #expect(model.isOneToOne == false)
    }

    // Regression: SpaceInfoView's subtitleView routes
    //   if isOneToOne { ... } else if sharedSpace { ... } else { Loc...infoTitle }
    // Pre-fix, sharedSpace was false at first paint → fallback "Private Channel" flashed.
    @Test func init_withSharedSpace_doesNotRouteToPrivateChannelFallback() {
        storage.subject.value = [
            makeSpaceView(spaceId: "space-shared", name: "Shared", spaceAccessType: .shared, spaceType: .regular)
        ]

        let model = SpaceInfoViewModel(spaceId: "space-shared")

        #expect(model.sharedSpace == true)
        #expect(model.isOneToOne == false)
    }

    @Test func init_withOneToOneSpace_routesToOneToOneBranch() {
        storage.subject.value = [
            makeSpaceView(spaceId: "space-1on1", name: "1-on-1", spaceAccessType: .private, spaceType: .oneToOne)
        ]

        let model = SpaceInfoViewModel(spaceId: "space-1on1")

        #expect(model.isOneToOne == true)
        #expect(model.sharedSpace == false)
    }

    // MARK: - subscription path

    @Test func startSubscriptions_secondEmission_updatesState() async throws {
        let initial = makeSpaceView(spaceId: "space-1", name: "Initial", spaceAccessType: .private, spaceType: .regular)
        let updated = makeSpaceView(spaceId: "space-1", name: "Updated", spaceAccessType: .private, spaceType: .regular)

        let model = SpaceInfoViewModel(spaceId: "space-1")
        #expect(model.spaceName == "")

        let task = Task { await model.startSubscriptions() }
        defer { task.cancel() }

        storage.subject.send([initial])
        try await waitForName("Initial", on: model)

        storage.subject.send([updated])
        try await waitForName("Updated", on: model)
    }

    // MARK: - Helpers

    private func makeSpaceView(
        spaceId: String,
        name: String,
        spaceAccessType: SpaceAccessType,
        spaceType: SpaceType
    ) -> SpaceView {
        SpaceView(
            id: "view-\(spaceId)",
            name: name,
            description: "",
            objectIconImage: .object(.space(.mock)),
            targetSpaceId: spaceId,
            createdDate: nil,
            joinDate: nil,
            accountStatus: .spaceActive,
            localStatus: .ok,
            spaceAccessType: spaceAccessType,
            readersLimit: nil,
            writersLimit: nil,
            chatId: "",
            spaceOrder: "",
            spaceType: spaceType,
            pushNotificationEncryptionKey: "",
            pushNotificationMode: .all,
            forceAllIds: [],
            forceMuteIds: [],
            forceMentionIds: [],
            oneToOneIdentity: "",
            homepage: .empty
        )
    }

    private func waitForName(_ expected: String, on model: SpaceInfoViewModel, timeoutMs: Int = 1000) async throws {
        let stepNs: UInt64 = 5_000_000
        let maxIterations = (timeoutMs * 1_000_000) / Int(stepNs)
        for _ in 0..<maxIterations {
            if model.spaceName == expected { return }
            try await Task.sleep(nanoseconds: stepNs)
        }
        #expect(model.spaceName == expected, "Timed out waiting for spaceName to equal \(expected); got \(model.spaceName)")
    }
}

// MARK: - Inline test mocks

private final class TestSpaceViewsStorage: SpaceViewsStorageProtocol, @unchecked Sendable {
    let subject = CurrentValueSubject<[SpaceView], Never>([])

    var allSpaceViews: [SpaceView] { subject.value }
    var allSpaceViewsPublisher: AnyPublisher<[SpaceView], Never> {
        subject.eraseToAnyPublisher()
    }
    func startSubscription() async {}
    func stopSubscription() async {}
    func spaceView(spaceViewId: String) -> SpaceView? {
        subject.value.first(where: { $0.id == spaceViewId })
    }
    func spaceView(spaceId: String) -> SpaceView? {
        subject.value.first(where: { $0.targetSpaceId == spaceId })
    }
    func spaceInfo(spaceId: String) -> AccountInfo? { nil }
    func addSpaceInfo(spaceId: String, info: AccountInfo) {}
}

private final class TestParticipantsSubscription: ParticipantsSubscriptionProtocol, @unchecked Sendable {
    let participantsPublisher: AnyPublisher<[Participant], Never> =
        Empty<[Participant], Never>(completeImmediately: false).eraseToAnyPublisher()
}
