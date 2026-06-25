# SubscriptionStorage event/response race — design

- **Date:** 2026-06-25
- **Ticket:** [IOS-6522](https://linear.app/anytype/issue/IOS-6522) (P1 / Urgent)
- **Status:** Approved design, ready for implementation plan
- **Scope:** Central fix in `SubscriptionStorage` (protects all ~20 subscription consumers). The chat `canEdit` per-space fallback is a separate optional ticket.

## Problem

On a cold start a space can render fully **read-only** — no chat message input, no create-document "+", no widget/home create affordances — until the app is restarted. The middleware-side authorization is correct (the user is a Writer); the bug is entirely client-side state.

It became **critical with lazy cross-space subscriptions**: on a cold cache the cross-space participant subscribe returns a **partial** snapshot in the response body and streams the remaining members as `subscriptionAdd` events. Previously the response carried the full set, so the race below almost never fired.

## Root cause

`Anytype/Sources/ServiceLayer/SubscriptionsToggler/Internals/SubscriptionStorage.swift` (an `actor`) has two unsynchronized writers to the same `detailsStorage` + `orderIds`:

- **Response path** — `startOrUpdateSubscription`: line 70 `await toggler.startSubscription(data:)` **suspends** the actor; on resume it runs `detailsStorage.removeAll()` + `orderIds.removeAll()` (lines 75–76) **unconditionally**, then reseeds **only** from `result.records` (lines 78–80).
- **Event path** — `handle(events:)` (lines 106–153): applies `objectDetailsSet`/`subscriptionAdd`/etc. for our subId.

Two interleavings, identical permanent end state:
- **(A) applied-then-wiped:** an event for a record arrives during the line-70 suspension, is applied, then destroyed by the `removeAll()` on resume (the record is absent from the partial `result.records`).
- **(B) missed-before-registration:** the event handler is registered lazily — `init` does `Task { await setupHandler() }` (line 41) and `EventBunchSubscribtion.addHandler` defers again via `Task` (line 19) — so an event can fan out before the handler exists and is never applied at all.

For the participant subscription the wiped record means `ParticipantSpacesStorage.updateData` computes `participant == nil` for the affected space → `SpacePermissions.canEdit == false` → read-only chat **and** widgets (both read the same global aggregate). A warm relaunch returns the complete set synchronously in `result.records` with zero events → no race → writable.

**Evidence:** two captured PROTO logs (cold = read-only, warm = writable). Diagnostic signal — the read-only space's `ScreenChat` analytics carries `spaceType`/`uxType` but **no `permissions`** field; `AnytypeAnalytics.swift:94` logs `permissions` only when `participantSpaceView?.participant != nil`, proving the spaceView is present but the participant is nil. Background/foreground was a red herring (the participant was lost at startup; the chat was simply opened later). Full forensics in the memory note `subscription-storage-event-response-race`.

## Goal & guarantee

Make `SubscriptionStorage` race-safe so that **once a subscribe is issued for a subId, every event for that subId from that instant is applied on top of the response snapshot, in order — nothing wiped, nothing missed, no duplicates.** Closing the race centrally fixes the read-only symptom and every other consumer of the shared storage.

## Non-goals / out of scope

- Chat `canEdit` per-space fallback (gate off the per-space `ParticipantsSubscription` filtered to our identity) — separate optional ticket; defense-in-depth, does not replace this fix.
- Broader hardening of two concurrent **different-data** `startOrUpdateSubscription` calls on one storage (pre-existing, rare).
- Any server/middleware change to the snapshot-vs-deltas contract.

## Design

Two files change. Approach: capture inside `SubscriptionStorage` (each storage owns its subId), plus deterministic handler registration.

### Change 1 — `EventBunchSubscribtion`: deterministic (awaitable) registration

`Anytype/Sources/Models/Documents/Events/Model/EventBunchSubscribtion.swift`. The existing `addHandler` is `nonisolated` and defers `addSubscriber` via `Task`, so registration is not ordered relative to a subsequent subscribe (interleaving B). Add an **actor-isolated async** registration that appends synchronously inside the actor, and keep the existing `addHandler`/`stream()` for other callers:

```swift
// new — actor-isolated, so addSubscriber runs synchronously before we return
func addHandler(_ handler: @escaping @Sendable (_ events: EventsBunch) async -> Void) async -> AnyCancellable {
    let subscriber = EventBunchSubscriber(handler: handler)
    addSubscriber(subscriber)
    return AnyCancellable(subscriber)
}
```

(Implementer note: this is an overload of the existing nonisolated `addHandler`; only `SubscriptionStorage` migrates to it. Confirm no other caller depends on the deferred variant; `stream()` is unaffected.)

### Change 2 — `SubscriptionStorage`: awaited registration + buffer/replay

`Anytype/Sources/ServiceLayer/SubscriptionsToggler/Internals/SubscriptionStorage.swift`.

1. **Await handler registration before the first subscribe.** Replace the fire-and-forget `Task { await setupHandler() }` (line 41) with a one-time setup that is **awaited at the top of `startOrUpdateSubscription`** (before line 70). Idempotent (guarded so it registers once). This closes interleaving B.

2. **Buffer events while a subscribe RPC is in flight.** Add `private var pendingEvents: [EventsBunch]?` (non-nil only during the in-flight window):

```swift
func startOrUpdateSubscription(data:update:) async throws {
    // ...id guard, and the `guard self.data != data` early-return (no buffer here)...

    await ensureHandlerRegistered()          // (1) handler is live before the RPC

    pendingEvents = []                        // (2) capture during the await instead of mutating live state
    let result: SubscriptionTogglerResult
    do { result = try await toggler.startSubscription(data: data) }
    catch { pendingEvents = nil; throw error }

    self.data = data
    self.update = update

    detailsStorage.removeAll()                // unchanged — still clears stale rows on a real re-subscribe
    orderIds.removeAll()
    result.records.forEach { detailsStorage.amend(details: $0) }
    result.dependencies.forEach { detailsStorage.amend(details: $0) }
    result.records.forEach { orderIds.append($0.id) }
    state.total = result.total
    state.prevCount = result.prevCount
    state.nextCount = result.nextCount

    let buffered = pendingEvents              // (3) drain & replay, then go live
    pendingEvents = nil
    buffered?.forEach { applyEvents($0) }

    updateItemsCache()
    await update(state)
    stateSubject.send(state)
}

private func handle(events: EventsBunch) async {
    anytypeAssert(events.localEvents.isEmpty, "...")
    if pendingEvents != nil { pendingEvents?.append(events); return }   // buffer during in-flight subscribe
    let oldState = state
    applyEvents(events)
    if oldState != state {
        updateItemsCache()
        await update?(state)
        stateSubject.send(state)
    }
}
```

3. **Extract `applyEvents(_:)`** containing the current event switch, shared by `handle()` and the replay loop. **Move all event cases verbatim** — `objectDetailsSet`/`objectDetailsAmend`/`objectDetailsUnset`, `subscriptionPosition`/`subscriptionAdd`/`subscriptionRemove`, `subscriptionCounters`, `objectRemove`/default — and recompute `state.items = orderIds.compactMap { detailsStorage.get(id:) }` once at the end. Omitting `subscriptionCounters` would silently break `total`/`nextCount`/`prevCount` for every consumer.

4. **Dedup guard (load-bearing).** In the `subscriptionAdd` case add:

```swift
case .subscriptionAdd(let data):
    guard idsContainsMySub([data.subID]) else { break }
    guard !orderIds.contains(data.id) else { break }   // NEW — applySubscriptionUpdate(.add) inserts unconditionally
    let update: SubscriptionUpdate = .add(data.id, after: data.afterID.isNotEmpty ? data.afterID : nil)
    orderIds.applySubscriptionUpdate(update)
```

Required because `Array.applySubscriptionUpdate(.add)` does not dedupe; without it, an id present in both the snapshot and a replayed add duplicates (visible as duplicate rows in Set/widget consumers). Keep the guard for live events too — harmless and prevents duplicate-row regressions if the middleware ever re-sends an add.

## Data flow

**Cold start (after fix).** subscribe issued → handler already registered, `pendingEvents = []` → the member's `objectDetailsSet` + `subscriptionAdd` arrive during the await → **buffered** → partial response (member absent) → `removeAll()` + seed records → **drain**: details written, add inserted (dedup passes) → `state.items` includes the member → `stateSubject` emits → `ParticipantsStorage` forwards → `ParticipantSpacesStorage.updateData` matches the participant → `canEdit = true` → writable.

**Warm relaunch (unchanged).** Response is complete, zero events → buffer empty, replay is a no-op → identical to today's behavior.

## Concurrency, ordering, dedup

- The actor serializes `handle()` against `startOrUpdateSubscription`. Buffering during the line-70 suspension captures any event that reentrantly runs `handle()`; awaiting registration first guarantees `handle()` is reachable. Replay happens before the storage resumes accepting live events into the live path (the buffer is drained and nil'd within the same isolated continuation after the seed).
- Replay applies buffered `EventsBunch`es in arrival order; `applyEvents` self-filters by subId, so buffered events for other subIds are no-ops on replay (each other storage has its own buffer/handler and processes normally).
- Dedup as above.

## Edge cases

- **Re-subscribe (query A→B):** `removeAll()` still clears A's rows; the buffer only holds events arriving during B's RPC. (A merge-instead-of-removeAll alternative is rejected: it would leak A's stale rows.)
- **Ordered subs with non-empty `afterID` referencing a streamed id:** `indexForAdd` returns nil → the add is skipped (pre-existing behavior). Participant subs use empty `afterID` (insert at 0) → unaffected. Documented residual for ordered consumers.
- **Throw on subscribe / early-return (`guard self.data != data`):** the buffer is created only on the real-subscribe path and cleared on success and throw — no leak, bounded to one RPC round-trip.

## Testing

Unit tests at the `SubscriptionStorage` level with a fake `SubscriptionTogglerProtocol` whose `startSubscription` suspends on a continuation:

1. **Race survival:** while suspended, deliver an `EventsBunch` (`objectDetailsSet` + `subscriptionAdd`) for an id **absent** from the eventual `result.records`; resume with a partial snapshot; assert `state.items` contains the id (with `total` from the response). Pre-fix fails, post-fix passes.
2. **Re-subscribe clears stale:** query A returns `[x]`, then `startOrUpdateSubscription` with query B returns `[y]`; assert `state.items == [y]`.
3. **Dedup:** id `z` delivered via a buffered `subscriptionAdd` **and** present in `result.records`; assert `orderIds` contains `z` exactly once.
4. **Warm path unchanged:** no in-flight events; assert `state.items == result.records` and a single emission.

## Risks & mitigations

- **Shared storage change (blast radius ~20 consumers):** mitigated by keeping `removeAll()`+records-seed semantics identical for the warm path (buffer empty ⇒ no behavior change) and by the dedup guard; smoke other consumers (SpaceViews, Contacts, ObjectsWithUnreadDiscussions, ChatDetails, Recent) on cold and warm launch.
- **`subscriptionCounters` dropped in the `applyEvents` extraction:** explicitly move all cases verbatim; covered by total-count assertions.
- **`addHandler` overload confusion:** keep the existing nonisolated `addHandler` for other callers; only `SubscriptionStorage` uses the async one.

## Verification

- **Manual repro:** cold-launch (fresh install / cleared cache) with a one-to-one space whose participant streams as a delta; open the chat immediately → input bar + create-doc "+" present and the widget/home for that space writable, without a restart.
- **Analytics (the wire is unchanged):** the previously-broken space's `ScreenChat` event now includes `permissions: Writer` alongside `spaceType`/`uxType`.

## References

- Code: `SubscriptionStorage.swift`, `EventBunchSubscribtion.swift`, `ParticipantSpacesStorage.swift`, `ParticipantsStorage.swift`, `AnytypeAnalytics.swift:90-103`, `Array+SubscriptionUpdate.swift`.
- Memory note: `subscription-storage-event-response-race`.
- Logs: cold `text-45C6-B5A3-0C-0.txt` (read-only), warm `text-42AA-A54C-65-0.txt` (writable).
