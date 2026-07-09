import Testing
import Foundation
import Combine
import SwiftProtobuf
import ProtobufMessages
import AnytypeCore
import Services
@testable import Anytype

// A toggler whose startSubscription suspends until the test resumes it,
// so an event can be injected while the storage is parked at the RPC await.
private actor FakeSuspendingToggler: SubscriptionTogglerProtocol {
    private var hasEntered = false
    private var enteredWaiter: CheckedContinuation<Void, Never>?
    private var resultWaiter: CheckedContinuation<SubscriptionTogglerResult, Error>?

    func startSubscription(data: SubscriptionData) async throws -> SubscriptionTogglerResult {
        hasEntered = true
        enteredWaiter?.resume(); enteredWaiter = nil
        return try await withCheckedThrowingContinuation { resultWaiter = $0 }
    }
    func stopSubscription(id: String) async throws {}
    func stopSubscriptions(ids: [String]) async throws {}

    func waitUntilEntered() async {
        if hasEntered { return }
        await withCheckedContinuation { enteredWaiter = $0 }
    }
    func finish(with result: SubscriptionTogglerResult) {
        resultWaiter?.resume(returning: result); resultWaiter = nil
    }
}

// A toggler that returns a pre-set result immediately (warm-path / re-subscribe).
private actor FakeImmediateToggler: SubscriptionTogglerProtocol {
    private var results: [SubscriptionTogglerResult]
    init(_ results: [SubscriptionTogglerResult]) { self.results = results }
    func startSubscription(data: SubscriptionData) async throws -> SubscriptionTogglerResult {
        results.isEmpty
            ? SubscriptionTogglerResult(records: [], dependencies: [], total: 0, prevCount: 0, nextCount: 0)
            : results.removeFirst()
    }
    func stopSubscription(id: String) async throws {}
    func stopSubscriptions(ids: [String]) async throws {}
}

@Suite(.serialized)
struct SubscriptionStorageRaceTests {

    private func makeDetails(id: String, name: String) -> ObjectDetails {
        ObjectDetails(id: id, values: ["name": name.protobufValue])
    }

    private func searchData(subId: String, limit: Int = 100) -> SubscriptionData {
        .search(.init(identifier: subId, spaceId: "space-1", filters: [], limit: limit, keys: ["name"]))
    }

    private func detailsSetEvent(id: String, subId: String, name: String) -> Anytype_Event.Message {
        var set = Anytype_Event.Object.Details.Set()
        set.id = id
        set.subIds = [subId]
        set.details = Google_Protobuf_Struct(fields: ["name": name.protobufValue])
        var msg = Anytype_Event.Message()
        msg.value = .objectDetailsSet(set)
        return msg
    }

    private func subscriptionAddEvent(id: String, subId: String, afterId: String = "") -> Anytype_Event.Message {
        var add = Anytype_Event.Object.Subscription.Add()
        add.id = id
        add.subID = subId
        add.afterID = afterId
        var msg = Anytype_Event.Message()
        msg.value = .subscriptionAdd(add)
        return msg
    }

    private func currentItemIds(_ storage: any SubscriptionStorageProtocol) async -> [String] {
        for await state in storage.statePublisher.values { return state.items.map(\.id) }
        return []
    }

    @Test
    func eventDuringInflightSubscribeSurvivesReseed() async throws {
        let subId = "SubscriptionId.Test-\(UUID().uuidString)"
        let toggler = FakeSuspendingToggler()
        let storage = SubscriptionStorage(subId: subId, detailsStorage: ObjectDetailsStorage(), toggler: toggler)

        // Partial cold response: contains "in-response" but NOT the streamed member.
        let partial = SubscriptionTogglerResult(
            records: [makeDetails(id: "in-response", name: "InResponse")],
            dependencies: [], total: 2, prevCount: 0, nextCount: 0
        )

        let task = Task { try await storage.startOrUpdateSubscription(data: searchData(subId: subId)) }

        await toggler.waitUntilEntered()   // storage parked at the RPC await; handler already registered

        let bunch = EventsBunch(contextId: "", middlewareEvents: [
            detailsSetEvent(id: "streamed-id", subId: subId, name: "Streamed"),
            subscriptionAddEvent(id: "streamed-id", subId: subId)
        ])
        await EventBunchSubscribtion.default.sendEvent(events: bunch)

        await toggler.finish(with: partial)
        _ = try await task.value

        let ids = await currentItemIds(storage)
        #expect(ids.contains("in-response"))
        #expect(ids.contains("streamed-id"))   // pre-fix: wiped by removeAll
    }

    @Test
    func replayedAddWithRealAfterIdIsPositioned() async throws {
        // Realistic streamed add: afterID points at a record present in the response
        // snapshot (not the empty afterID used above), so it must land right after it.
        let subId = "SubscriptionId.Test-\(UUID().uuidString)"
        let toggler = FakeSuspendingToggler()
        let storage = SubscriptionStorage(subId: subId, detailsStorage: ObjectDetailsStorage(), toggler: toggler)

        let response = SubscriptionTogglerResult(
            records: [makeDetails(id: "anchor", name: "Anchor")],
            dependencies: [], total: 2, prevCount: 0, nextCount: 0
        )

        let task = Task { try await storage.startOrUpdateSubscription(data: searchData(subId: subId)) }
        await toggler.waitUntilEntered()
        await EventBunchSubscribtion.default.sendEvent(events: EventsBunch(contextId: "", middlewareEvents: [
            detailsSetEvent(id: "streamed-id", subId: subId, name: "Streamed"),
            subscriptionAddEvent(id: "streamed-id", subId: subId, afterId: "anchor")
        ]))
        await toggler.finish(with: response)
        _ = try await task.value

        let ids = await currentItemIds(storage)
        #expect(ids == ["anchor", "streamed-id"])
    }

    @Test
    func replayedAddIsDedupedAgainstResponseSnapshot() async throws {
        let subId = "SubscriptionId.Test-\(UUID().uuidString)"
        let toggler = FakeSuspendingToggler()
        let storage = SubscriptionStorage(subId: subId, detailsStorage: ObjectDetailsStorage(), toggler: toggler)

        // Response already includes "dup"; an in-flight event re-adds the same id.
        let response = SubscriptionTogglerResult(
            records: [makeDetails(id: "dup", name: "Dup")],
            dependencies: [], total: 1, prevCount: 0, nextCount: 0
        )

        let task = Task { try await storage.startOrUpdateSubscription(data: searchData(subId: subId)) }
        await toggler.waitUntilEntered()
        await EventBunchSubscribtion.default.sendEvent(events: EventsBunch(contextId: "", middlewareEvents: [
            detailsSetEvent(id: "dup", subId: subId, name: "Dup"),
            subscriptionAddEvent(id: "dup", subId: subId)
        ]))
        await toggler.finish(with: response)
        _ = try await task.value

        let ids = await currentItemIds(storage)
        #expect(ids == ["dup"])   // pre-guard: ["dup", "dup"]
    }

    @Test
    func warmPathSeedsFromResponseRecords() async throws {
        let subId = "SubscriptionId.Test-\(UUID().uuidString)"
        let toggler = FakeImmediateToggler([
            SubscriptionTogglerResult(records: [makeDetails(id: "x", name: "X")], dependencies: [], total: 1, prevCount: 0, nextCount: 0)
        ])
        let storage = SubscriptionStorage(subId: subId, detailsStorage: ObjectDetailsStorage(), toggler: toggler)
        try await storage.startOrUpdateSubscription(data: searchData(subId: subId))
        let ids = await currentItemIds(storage)
        #expect(ids == ["x"])
    }

    @Test
    func reSubscribeClearsStaleRecords() async throws {
        let subId = "SubscriptionId.Test-\(UUID().uuidString)"
        let toggler = FakeImmediateToggler([
            SubscriptionTogglerResult(records: [makeDetails(id: "x", name: "X")], dependencies: [], total: 1, prevCount: 0, nextCount: 0),
            SubscriptionTogglerResult(records: [makeDetails(id: "y", name: "Y")], dependencies: [], total: 1, prevCount: 0, nextCount: 0)
        ])
        let storage = SubscriptionStorage(subId: subId, detailsStorage: ObjectDetailsStorage(), toggler: toggler)
        try await storage.startOrUpdateSubscription(data: searchData(subId: subId))
        // Second subscribe with different data (different limit) so `self.data != data`.
        try await storage.startOrUpdateSubscription(data: searchData(subId: subId, limit: 200))
        let ids = await currentItemIds(storage)
        #expect(ids == ["y"])
    }
}
