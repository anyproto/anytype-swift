# SubscriptionStorage event/response race — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make `SubscriptionStorage` race-safe so a record the middleware delivers via a `subscriptionAdd` event (cold cache) is not wiped by the subscribe-response reseed — fixing read-only spaces and protecting all subscription consumers.

**Architecture:** Inside the `SubscriptionStorage` actor: (1) register the event handler deterministically *before* issuing the subscribe RPC, and (2) buffer events that arrive while the subscribe RPC is in flight and replay them (deduped) after the response snapshot is seeded. `removeAll()` + records-seed semantics are preserved, so the warm path is unchanged.

**Tech Stack:** Swift, Swift Concurrency (`actor`, `async/await`, `CheckedContinuation`), Combine (`CurrentValueSubject`/`AnyPublisher`), Swift Testing (`import Testing`, `@Test`, `#expect`), SwiftProtobuf.

**Design doc:** `docs/plans/2026-06-25-subscriptionstorage-event-response-race-design.md` · **Ticket:** IOS-6522

## Global Constraints

- Test framework is **Swift Testing** (`import Testing`, struct suites, `@Test`, `#expect`). Not XCTest.
- Test target: **`AnytypeTests`**; new tests go under `AnytypeTests/Services/`.
- Production targets compile in Xcode; the project's convention is to **verify compilation/tests in Xcode** (faster with caches). A CLI command is given as a backup for each run step.
- Commit messages are a single line prefixed `IOS-6522`, direct and technical (no buzzwords). Do **not** commit unless the user has authorized it for execution.
- Keep `detailsStorage.removeAll()` + records-seed in `startOrUpdateSubscription` (a blind merge would leak stale rows on a real re-subscribe).
- `EventBunchSubscribtion.default` is a process-wide singleton; tests use **unique subIds** and a **`@Suite(.serialized)`** suite to avoid cross-test interference.

## File Structure

- **Modify:** `Anytype/Sources/Models/Documents/Events/Model/EventBunchSubscribtion.swift` — add an actor-isolated `async` `addHandler` overload (deterministic registration).
- **Modify:** `Anytype/Sources/ServiceLayer/SubscriptionsToggler/Internals/SubscriptionStorage.swift` — await handler registration before the RPC; add `pendingEvents` buffer + replay; extract `applyEvents`; add the dedup guard.
- **Create:** `AnytypeTests/Services/SubscriptionStorageRaceTests.swift` — Swift Testing suite + fake togglers + helpers.

---

## Task 1: Race-safe SubscriptionStorage (deterministic registration + buffer/replay)

**Files:**
- Modify: `Anytype/Sources/Models/Documents/Events/Model/EventBunchSubscribtion.swift` (after line 23)
- Modify: `Anytype/Sources/ServiceLayer/SubscriptionsToggler/Internals/SubscriptionStorage.swift:36-153`
- Test: `AnytypeTests/Services/SubscriptionStorageRaceTests.swift` (new)

**Interfaces:**
- Consumes: `SubscriptionStorage.init(subId:detailsStorage:toggler:)`; `SubscriptionTogglerProtocol { startSubscription(data:) async throws -> SubscriptionTogglerResult; stopSubscription(id:) async throws; stopSubscriptions(ids:) async throws }`; `SubscriptionTogglerResult(records:dependencies:total:prevCount:nextCount:)` with `records/dependencies: [ObjectDetails]`, others `Int`; `EventBunchSubscribtion.default.sendEvent(events:) async`; `EventsBunch(contextId:middlewareEvents:)`; `SubscriptionData.search(.init(identifier:spaceId:filters:limit:keys:))`; `ObjectDetails(id:values:)`; `SubscriptionStorageProtocol.statePublisher: AnyPublisher<SubscriptionStorageState, Never>` whose `.items` is `[ObjectDetails]`.
- Produces: `EventBunchSubscribtion.addHandler(_:) async -> AnyCancellable`; `SubscriptionStorage` with `private var pendingEvents: [EventsBunch]?`, `private var handlerRegistration: Task<Void, Never>?`, `private func applyEvents(_:)`, `private func setupHandler() async`.

- [ ] **Step 1: Write the failing race-survival test (with fakes + helpers)**

Create `AnytypeTests/Services/SubscriptionStorageRaceTests.swift`:

```swift
import Testing
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

    private func searchData(subId: String) -> SubscriptionData {
        .search(.init(identifier: subId, spaceId: "space-1", filters: [], limit: 100, keys: ["name"]))
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
        #expect(ids.contains("streamed-id"))   // pre-fix: wiped by removeAll → FAILS
    }
}
```

- [ ] **Step 2: Run the test — verify it FAILS**

Xcode: open the file, ⌃⌥⌘U on `eventDuringInflightSubscribeSurvivesReseed`. Or CLI:

```bash
xcodebuild test -scheme Anytype \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:AnytypeTests/SubscriptionStorageRaceTests/eventDuringInflightSubscribeSurvivesReseed 2>&1 | tail -20
```
Expected: FAIL — `#expect(ids.contains("streamed-id"))` is false (the event-added record is wiped by `removeAll()` on the response resume).

- [ ] **Step 3: Add the actor-isolated async `addHandler` overload**

In `EventBunchSubscribtion.swift`, immediately after the existing `addHandler` (after line 23), add:

```swift
    // Actor-isolated registration: addSubscriber runs synchronously before this returns,
    // so the handler is live the moment the caller awaits it (no deferred-Task gap).
    func addHandler(_ handler: @escaping @Sendable (_ events: EventsBunch) async -> Void) async -> AnyCancellable {
        let subscriber = EventBunchSubscriber(handler: handler)
        addSubscriber(subscriber)
        return AnyCancellable(subscriber)
    }
```
(If Swift reports overload ambiguity at the `SubscriptionStorage` call site in Step 4, rename this one to `addHandlerAwaiting` and update the call.)

- [ ] **Step 4: Make `SubscriptionStorage` register its handler deterministically before the RPC**

In `SubscriptionStorage.swift`:

Add a stored registration task next to the other state (near line 26):
```swift
    private var handlerRegistration: Task<Void, Never>?
    private var pendingEvents: [EventsBunch]?
```

Change `init` (lines 36-42) to store the registration task and make setup awaitable:
```swift
    init(subId: String, detailsStorage: ObjectDetailsStorage, toggler: some SubscriptionTogglerProtocol) {
        self.subId = subId
        self.detailsStorage = detailsStorage
        self.toggler = toggler
        self.statePublisher = stateSubject.compactMap { $0 }.eraseToAnyPublisher()
        handlerRegistration = Task { await setupHandler() }
    }
```

Change `setupHandler` (lines 99-104) to `async` using the new awaitable registration:
```swift
    private func setupHandler() async {
        subscription = await EventBunchSubscribtion.default.addHandler { [weak self] events in
            guard events.contextId.isEmpty else { return }
            await self?.handle(events: events)
        }
    }
```

- [ ] **Step 5: Extract `applyEvents` and add the buffer/replay to `startOrUpdateSubscription`**

In `SubscriptionStorage.swift`, replace the body of `startOrUpdateSubscription(data:update:)` (lines 55-89) so it awaits registration, buffers during the RPC, and replays after the seed:

```swift
    func startOrUpdateSubscription(data: SubscriptionData, update: @escaping @Sendable (_ state: SubscriptionStorageState) async -> Void) async throws {
        guard subId == data.identifier else {
            anytypeAssertionFailure("Ids should be equals", info: ["old id": subId, "new id": data.identifier])
            return
        }

        guard self.data != data else {
            self.update = update
            await update(state)
            stateSubject.send(state)
            return
        }

        await handlerRegistration?.value     // handler is live before the subscribe RPC

        pendingEvents = []                   // capture events arriving during the in-flight subscribe
        let result: SubscriptionTogglerResult
        do {
            result = try await toggler.startSubscription(data: data)
        } catch {
            pendingEvents = nil
            throw error
        }

        self.data = data
        self.update = update

        detailsStorage.removeAll()
        orderIds.removeAll()

        result.records.forEach { detailsStorage.amend(details: $0) }
        result.dependencies.forEach { detailsStorage.amend(details: $0) }
        result.records.forEach { orderIds.append($0.id) }

        state.total = result.total
        state.prevCount = result.prevCount
        state.nextCount = result.nextCount

        let buffered = pendingEvents         // reconcile event-delivered records the snapshot omitted
        pendingEvents = nil
        buffered?.forEach { applyEvents($0) }

        updateItemsCache()
        await update(state)
        stateSubject.send(state)
    }
```

Replace `handle(events:)` (lines 106-153) with a buffer-aware version that delegates to a new `applyEvents`:

```swift
    private func handle(events: EventsBunch) async {
        anytypeAssert(events.localEvents.isEmpty, "Local events with emplty objectId: \(events)")

        if pendingEvents != nil {            // a subscribe RPC is in flight: buffer, reconcile after the seed
            pendingEvents?.append(events)
            return
        }

        let oldState = state
        applyEvents(events)

        if oldState != state {
            updateItemsCache()
            await update?(state)
            stateSubject.send(state)
        }
    }

    private func applyEvents(_ events: EventsBunch) {
        for event in events.middlewareEvents {
            switch event.value {
            case .objectDetailsSet(let data):
                guard idsContainsMySub(data.subIds, incudeDeps: true) else { break }
                _ = detailsStorage.set(data: data)
            case .objectDetailsAmend(let data):
                guard idsContainsMySub(data.subIds, incudeDeps: true) else { break }
                _ = detailsStorage.amend(data: data)
            case .objectDetailsUnset(let data):
                guard idsContainsMySub(data.subIds, incudeDeps: true) else { break }
                _ = detailsStorage.unset(data: data)
            case .subscriptionPosition(let data):
                guard idsContainsMySub([data.subID]) else { break }
                let update: SubscriptionUpdate = .move(from: data.id, after: data.afterID.isNotEmpty ? data.afterID : nil)
                orderIds.applySubscriptionUpdate(update)
            case .subscriptionAdd(let data):
                guard idsContainsMySub([data.subID]) else { break }
                let update: SubscriptionUpdate = .add(data.id, after: data.afterID.isNotEmpty ? data.afterID : nil)
                orderIds.applySubscriptionUpdate(update)
            case .subscriptionRemove(let data):
                guard idsContainsMySub([data.subID]) else { break }
                let update: SubscriptionUpdate = .remove(data.id)
                orderIds.applySubscriptionUpdate(update)
            case .objectRemove:
                break // unsupported (Not supported in middleware converter also)
            case .subscriptionCounters(let data):
                guard idsContainsMySub([data.subID]) else { break }
                state.total = Int(data.total)
                state.nextCount = Int(data.nextCount)
                state.prevCount = Int(data.prevCount)
            default:
                break
            }
        }

        state.items = orderIds.compactMap { detailsStorage.get(id: $0) }
    }
```

- [ ] **Step 6: Run the race-survival test — verify it PASSES**

```bash
xcodebuild test -scheme Anytype \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:AnytypeTests/SubscriptionStorageRaceTests/eventDuringInflightSubscribeSurvivesReseed 2>&1 | tail -20
```
Expected: PASS — `streamed-id` is buffered during the RPC and replayed after the seed.

- [ ] **Step 7: Add warm-path + re-subscribe regression tests**

Append to the suite in `SubscriptionStorageRaceTests.swift`:

```swift
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
        try await storage.startOrUpdateSubscription(
            data: .search(.init(identifier: subId, spaceId: "space-1", filters: [], limit: 200, keys: ["name"]))
        )
        let ids = await currentItemIds(storage)
        #expect(ids == ["y"])
    }
```

- [ ] **Step 8: Run all three tests — verify PASS**

```bash
xcodebuild test -scheme Anytype \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:AnytypeTests/SubscriptionStorageRaceTests 2>&1 | tail -25
```
Expected: 3 tests PASS.

- [ ] **Step 9: Commit**

```bash
git add Anytype/Sources/Models/Documents/Events/Model/EventBunchSubscribtion.swift \
        Anytype/Sources/ServiceLayer/SubscriptionsToggler/Internals/SubscriptionStorage.swift \
        AnytypeTests/Services/SubscriptionStorageRaceTests.swift
git commit -m "IOS-6522 Buffer+replay subscription events racing the subscribe response"
```

---

## Task 2: Dedup replayed `subscriptionAdd` against the response snapshot

**Files:**
- Modify: `Anytype/Sources/ServiceLayer/SubscriptionsToggler/Internals/SubscriptionStorage.swift` (the `.subscriptionAdd` case in `applyEvents`)
- Test: `AnytypeTests/Services/SubscriptionStorageRaceTests.swift` (append)

**Interfaces:**
- Consumes: `applyEvents(_:)` and the `.subscriptionAdd` case from Task 1; `Array.applySubscriptionUpdate(.add)` (inserts without dedup).
- Produces: dedup guard `guard !orderIds.contains(data.id) else { break }` in the `.subscriptionAdd` case.

- [ ] **Step 1: Write the failing dedup test**

Append to the suite:

```swift
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
        #expect(ids == ["dup"])   // pre-guard: ["dup", "dup"] → FAILS
    }
```

- [ ] **Step 2: Run the dedup test — verify it FAILS**

```bash
xcodebuild test -scheme Anytype \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:AnytypeTests/SubscriptionStorageRaceTests/replayedAddIsDedupedAgainstResponseSnapshot 2>&1 | tail -20
```
Expected: FAIL — `ids == ["dup", "dup"]` (replayed add duplicates the seeded id).

- [ ] **Step 3: Add the dedup guard**

In `SubscriptionStorage.swift`, in `applyEvents`, the `.subscriptionAdd` case — add the guard line:

```swift
            case .subscriptionAdd(let data):
                guard idsContainsMySub([data.subID]) else { break }
                guard !orderIds.contains(data.id) else { break }   // applySubscriptionUpdate(.add) inserts unconditionally
                let update: SubscriptionUpdate = .add(data.id, after: data.afterID.isNotEmpty ? data.afterID : nil)
                orderIds.applySubscriptionUpdate(update)
```

- [ ] **Step 4: Run the dedup test — verify it PASSES**

```bash
xcodebuild test -scheme Anytype \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:AnytypeTests/SubscriptionStorageRaceTests/replayedAddIsDedupedAgainstResponseSnapshot 2>&1 | tail -20
```
Expected: PASS.

- [ ] **Step 5: Run the whole suite — verify no regressions**

```bash
xcodebuild test -scheme Anytype \
  -destination "platform=iOS Simulator,name=iPhone 16" \
  -only-testing:AnytypeTests/SubscriptionStorageRaceTests 2>&1 | tail -25
```
Expected: 4 tests PASS.

- [ ] **Step 6: Commit**

```bash
git add Anytype/Sources/ServiceLayer/SubscriptionsToggler/Internals/SubscriptionStorage.swift \
        AnytypeTests/Services/SubscriptionStorageRaceTests.swift
git commit -m "IOS-6522 Dedup replayed subscriptionAdd against the response snapshot"
```

---

## Manual verification (after both tasks)

Cold-launch (fresh install / cleared cache) with a one-to-one space whose participant streams as a delta; open the chat immediately → message input + create-document "+" present and the widget/home for that space writable, without a restart. Analytics check (wire unchanged): the previously-broken space's `ScreenChat` event now includes `permissions: Writer` alongside `spaceType`/`uxType`.

## Self-Review

**Spec coverage:**
- "Deterministic (awaitable) registration" → Task 1 Steps 3–4. ✓
- "Buffer events during the in-flight subscribe, replay after the seed" → Task 1 Step 5. ✓
- "Keep `removeAll()`" → preserved in Task 1 Step 5; guarded by `reSubscribeClearsStaleRecords`. ✓
- "Extract `applyEvents`, move all event cases verbatim incl. `subscriptionCounters`" → Task 1 Step 5 (all 8 cases present). ✓
- "Dedup guard on `subscriptionAdd`" → Task 2. ✓
- "Warm path unchanged" → `warmPathSeedsFromResponseRecords`. ✓
- "Tests: race survival, re-subscribe clears, dedup, warm path" → all four present. ✓
- Out of scope (chat `canEdit` fallback; concurrent different-data re-subscribe) → not included, as specified. ✓

**Placeholder scan:** No TBD/TODO; every code and command step is concrete. ✓

**Type consistency:** `SubscriptionTogglerResult(records:dependencies:total:prevCount:nextCount:)`, `EventsBunch(contextId:middlewareEvents:)`, `ObjectDetails(id:values:)`, `SubscriptionData.search(.init(identifier:spaceId:filters:limit:keys:))`, `addHandler(_:) async`, `applyEvents(_:)`, `pendingEvents`, `handlerRegistration`, `statePublisher.values → state.items` — names/signatures match across tasks and the grounding report. ✓

**Known residuals (documented, not bugs):** ordered subscriptions whose buffered `subscriptionAdd` carries a non-empty `afterID` referencing a streamed id will skip that add (`indexForAdd` returns nil) — pre-existing behavior, irrelevant to participant subs (empty `afterID`). The interleaving-B "missed before registration" case is closed by Task 1 Steps 3–4 but is not separately unit-tested (not deterministically reproducible via the singleton dispatcher); the race-survival test exercises the registration path transitively.
