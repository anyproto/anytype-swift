# IOS-6068 Discussion Mark-As-Read Anchor Fix

## Overview

Fix IOS-6068: in Object Discussions, reopening a discussion always lands on the same already-read comment, and the "jump down" arrow can scroll **upward** to that same comment instead of going to the bottom. This happens in 0.46 and 0.47.

Root cause is **discussion-specific** (chat module is unaffected): `MessageSectionItem.discussionDivider(id:)` cells exist between root comments, but `messageId` / `messageOrderId` accessors on `MessageSectionItem` return the divider's own id (`"divider-bafy..."`) for divider cases. When a divider lands at the visible-range edge, `markAsRead` silently no-ops, and `bottomVisibleOrderId` becomes a divider string that lex-compares incorrectly against real `oldestOrderID` values inside `onTapScrollToBottom`'s path-1 condition — making it spuriously fire and scroll upward.

Linear: IOS-6068. Parent: IOS-5869 Object Discussions. Branch: `ios-6068-discussions-starting-point-and-jump-down-button`.

**Acceptance criterion**: in a discussion with unread comments, reopening lands on the bottom (not on a previously-read mid-history comment) once those comments have been seen; the "jump down" arrow never scrolls upward; the dual-mode behavior (next-unread-chunk when above unreads, otherwise actual bottom) is preserved for offline-backfill scenarios.

## Decision: keep dual-mode jump-down behavior

User explicitly preserves:
- Open → scroll to first unread/mention via `chatState.messages.oldestOrderID` (anchoring UX).
- Jump-down → "next unread chunk" if user is above unreads, otherwise actual bottom + mark-all-read. Required for offline-backfill: a late-arriving message can land in the past and should remain unread until visually seen.

The fix does **not** change `onTapScrollToBottom` semantics. It fixes the underlying mark-as-read mechanism so `oldestOrderID` accurately reflects what the user has seen, which removes the conditions that make path-1 misfire.

Investigation lineage: multi-round between Claude and Codex. Codex's divider-contamination diagnosis is the primary root cause; Claude's `lastStateID` race observation is a secondary contributor; both informed the final scope.

## Context (from discovery)

**Files in scope (modify)**:
- `Anytype/Sources/PresentationLayer/Modules/Chat/Subviews/Section/MessageSectionItem.swift` — add tracked-id accessors that return `nil` for `.discussionDivider`.
- `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionViewModel.swift` — filter dividers in `visibleRangeChanged`, force a one-shot recalc after programmatic open scroll, debounce + accumulate visible ranges.
- `Anytype/Sources/PresentationLayer/Modules/Discussion/Services/DiscussionMessagesStorage.swift` — harden `updateVisibleRange` (no `?? 0`), surface `markAsRead` failures via assertion in debug.

**Files in scope (read-only reference, do NOT modify)**:
- `Anytype/Sources/PresentationLayer/Modules/Chat/Subviews/Collection/ChatCollectionViewCoordinator.swift` — generic, shared between Chat and Discussion. Filtering must NOT happen here.
- `Anytype/Sources/PresentationLayer/Modules/Discussion/Services/DiscussionMessageBuilder.swift:57` — divider creation site (`"divider-\(root.message.id)"`) — confirms divider id format.
- `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionView.swift:257-258` — wires coordinator's `handleVisibleRange` → `model.visibleRangeChanged`.
- `Modules/Services/Sources/Services/Chat/ChatService.swift:118-132` — `readMessages` API wrapper.
- `Dependencies/Middleware/protobuf/commands.pb.swift` (~line 39788) — `ChatReadMessages.Request` proto: `lastStateID` documented as race-condition prevention.

**Test infrastructure (pre-resolved)**: the Anytype app target has no XCTest suite (`AnytypeTests` does not exist; only `Modules/*/Tests` Swift packages have tests). Per project convention (see plan `20260424-ios-6106-my-favorites-per-row-vm.md`), **no new unit tests** for SwiftUI view models or app-target storage classes — manual QA is the verification path. `MessageSectionItem` is also in the app target, so its accessors are not directly unit-testable in the current setup; if extracted to a Swift package later, tests can follow.

**Patterns observed**:
- Other discussion code uses `Task { ... await chatStorage?.updateVisibleRange(...) }` directly inside `@MainActor` view-model methods (no debounce). This is the pattern to refine, not break.
- Storage is an `actor` — methods serialize, but reads of `self.chatState` reflect whatever the latest middleware event delivered, which can lag behind a burst of in-flight requests.

## Out of scope (explicitly NOT doing)

- Changing `onTapScrollToBottom` logic — dual-mode is the desired UX.
- Changing `subscribeOnMessages` initial-scroll behavior beyond the post-scroll force-recalc.
- Touching `ChatViewModel`, `ChatCollectionViewCoordinator`, or any chat-only file — chat doesn't have dividers, so the bug doesn't manifest there.
- Coalescing across multiple debounce windows or any retry logic for failed `readMessages` calls.
- Removing the cached `firstUnreadMessageOrderId` field — used by `onTapScrollToBottom` path-1, which we're preserving.
- Adding a feature flag — pure bug fix.

## Development Approach

- **Testing approach**: Regular (code first, manual QA second). No unit tests added per the test-infrastructure constraint above.
- Each task is a logical commit; complete and self-build-verify each before moving to the next. Build verification is manual: report changes; user verifies in Xcode.
- Maintain backward compatibility for `MessageSectionItem`'s existing `messageId` / `messageOrderId` accessors — adding new accessors, not changing old contracts.
- Update this plan in-place as scope shifts during implementation; mark `[x]` immediately when each item completes; use `➕` for newly discovered tasks and `⚠️` for blockers.

## Testing Strategy

- **Unit tests**: skipped per project convention for app-target SwiftUI / storage code. Documented in Overview.
- **E2E tests**: project has no e2e suite for discussions.
- **Manual verification**: comprehensive scenarios listed in Task 6 below; this is the primary safety net.

## Solution Overview

Six surgical changes in three files:

1. **Type-level fix**: add `trackedMessageId` / `trackedOrderId` to `MessageSectionItem` returning `nil` for dividers. Existing accessors stay untouched.
2. **View-model filter**: in `DiscussionViewModel.visibleRangeChanged`, skip ticks where either edge resolves to `nil` (divider). This also stops `bottomVisibleOrderId` from holding a divider string.
3. **Storage hardening**: replace `?? 0` defaults in `updateVisibleRange` with `guard let ... else { return }`.
4. **Anchor read on open**: after the programmatic scroll-to-first-unread on initial open, trigger one visible-range recalc once layout settles, so the anchor message itself gets marked read even if the user doesn't move.
5. **Debounce + accumulate**: in `DiscussionViewModel`, collapse rapid `visibleRangeChanged` ticks during a 250 ms window into one `updateVisibleRange` call covering the union span (min top → max bottom orderID across the burst). This defuses the `lastStateID` race and reduces network chatter from ~60 Hz to ~4 Hz.
6. **Surface failures**: in `DiscussionMessagesStorage.markAsRead`, replace the silent `try?` with `do/catch` + `anytypeAssertionFailure` so future stale-state failures are observable in debug.

## Technical Details

### Divider id format
Dividers are emitted in `DiscussionMessageBuilder.swift:57` as `.discussionDivider(id: "divider-\(root.message.id)")`. The accessors `messageId` and `messageOrderId` currently return that string directly for the divider case (`MessageSectionItem.swift:27-29`, `:38-40`).

### Why the lex compare misfires
Real chat orderIDs are lexorank-style strings typically starting with letters in the middle of the alphabet (e.g. `'k'` = ASCII 107). Divider strings start with `"divider-"` (ASCII `'d'` = 100). So `"divider-..." < "k..."` lexicographically, which means both halves of the path-1 condition in `onTapScrollToBottom` (`firstUnreadMessageOrderId > bottomVisibleOrderId` AND `bottomVisibleOrderId < oldestOrderID`) become spuriously TRUE the moment a divider is the bottom-visible cell. Path-1 then scrolls to `oldestOrderID` (= the original first-unread = upward).

### Debounce design
- Add private state in `DiscussionViewModel`:
  - `private var pendingMarkAsReadTask: Task<Void, Never>?`
  - `private var minObservedTop: (messageId: String, orderId: String)?`
  - `private var maxObservedBottom: (messageId: String, orderId: String)?`
- On each `visibleRangeChanged(from:to:)`:
  - If `from.trackedOrderId` or `to.trackedOrderId` is `nil`, skip entirely.
  - Update `bottomVisibleOrderId` synchronously with `to.trackedOrderId` (so `onTapScrollToBottom` always reads a valid orderID).
  - Update `forceHiddenActionPanel = false`.
  - Update `minObservedTop` if the new top's orderID is lexicographically smaller (or if nil); update `maxObservedBottom` if the new bottom's orderID is lexicographically larger.
  - Cancel `pendingMarkAsReadTask`; create new task that sleeps 250 ms then awaits `chatStorage.updateVisibleRange(startMessageId: minObservedTop.messageId, endMessageId: maxObservedBottom.messageId)`. Clear the observed state and the task handle when done.
- Why 250 ms: short enough that unread counter feels responsive after stopping; long enough that a typical scroll burst (60 Hz over a fraction of a second) collapses into one call.
- Network reduction: ~60 Hz → ~4 Hz worst case; offline-backfill semantics unchanged because the union span is still bounded by what the user actually scrolled over, never `""` (start).

### Anchor force-recalc
After `collectionViewScrollProxy.scrollTo(itemId: message.message.id, position: .center, animated: false)` on initial open (around `DiscussionViewModel.swift:287`):
- Cleanest path: add a small `refreshVisibleRange()` method on `ChatCollectionScrollProxy` (which is held by the discussion view model already) that the coordinator interprets as "re-emit current visible range with `forceUpdate: true`". This stays in proxy-level plumbing without leaking discussion-specific concepts into `ChatCollectionViewCoordinator`.
- Fallback: in the view model, `await Task.sleep(for: .milliseconds(100))` after the scroll, then call `refreshVisibleRange()`. The sleep lets layout settle.
- Decide implementation detail when reading `ChatCollectionScrollProxy.swift` in Task 4 — the proxy may already expose a hook we can reuse.

### markAsRead error logging
Replace the two `try?` sites in `DiscussionMessagesStorage.swift` (lines ~423 messages branch and ~437 mentions branch) with:
```swift
do {
    try await chatService.readMessages(...)
} catch {
    anytypeAssertionFailure("Failed to mark messages as read: \(error)")
}
```
`anytypeAssertionFailure` is a debug-only assertion; in release it's a no-op (or a log, depending on its implementation — verify when editing). No production crashes added.

## What Goes Where

- **Implementation Steps** below: code changes plus self-verifying compile.
- **Post-Completion**: manual verification scenarios (the primary safety net) and PR creation.

## Implementation Steps

### Task 1: Add tracked id accessors to MessageSectionItem

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Chat/Subviews/Section/MessageSectionItem.swift`

- [ ] verify with `rg "\.messageId|\.messageOrderId" Anytype/Sources/PresentationLayer/Modules/Discussion Anytype/Sources/PresentationLayer/Modules/Chat` that no existing call site requires divider cases to return their id (would inform whether Option β is safe). Document findings inline if any tricky callers exist.
- [ ] add `trackedMessageId: String?` and `trackedOrderId: String?` to the existing `extension MessageSectionItem` block; both return `nil` for `.discussionDivider`, real values for `.message` / `.unread`.
- [ ] do NOT modify `messageId` / `messageOrderId` (callers outside read-tracking still rely on their current contract).
- [ ] no tests (app target has no XCTest suite — see Testing Strategy).
- [ ] report change to user; user verifies in Xcode it builds.

### Task 2: Filter dividers in DiscussionViewModel.visibleRangeChanged

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionViewModel.swift`

- [ ] in `visibleRangeChanged(from:to:)` (around line 509), early-return when `from.trackedOrderId` or `to.trackedOrderId` is `nil`. Do not update `bottomVisibleOrderId`, do not call storage.
- [ ] when both are non-nil, update `bottomVisibleOrderId = to.trackedOrderId!` (force-unwrap is safe inside the guarded branch) and proceed to the existing storage call.
- [ ] keep the existing `forceHiddenActionPanel = false` behavior.
- [ ] no tests.
- [ ] report change; user verifies build.

### Task 3: Harden DiscussionMessagesStorage.updateVisibleRange

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/Services/DiscussionMessagesStorage.swift`

- [ ] in `updateVisibleRange(startMessageId:endMessageId:)` (around lines 77-93), replace the two `?? 0` defaults on `messages.index(messageId:)` with `guard let ... else { return }` so unresolved ids early-return without mutating subscription anchors or calling `markAsRead`.
- [ ] `markAsRead` itself already has a `guard let ... else { return }` for orderID lookup — leave that alone (Task 6 changes the `try?` inside it).
- [ ] no tests.
- [ ] report change; user verifies build.

### Task 4: Force visible-range recalc after programmatic open scroll

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Chat/Subviews/Collection/ChatCollectionScrollProxy.swift` (add a small `refreshVisibleRange()` hook — proxy is the boundary the discussion view model already owns, so this is OK)
- Modify: `Anytype/Sources/PresentationLayer/Modules/Chat/Subviews/Collection/ChatCollectionView.swift` and/or `ChatCollectionViewCoordinator.swift` (only if needed to wire the proxy hook through to a force-update call — keep changes generic, no discussion-specific concepts)
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionViewModel.swift`

- [ ] read `ChatCollectionScrollProxy.swift` and the coordinator wiring to choose the cleanest hook: either reuse an existing mechanism, or add a tiny `refreshVisibleRange()` API on the proxy that the coordinator translates into a `forceVisibleRangeUpdate: true` re-emit.
- [ ] in `DiscussionViewModel.subscribeOnMessages` (around line 287), after the `scrollTo(itemId:..., position: .center, animated: false)` for the first-unread anchor case, schedule a one-shot recalc once layout settles. Likely shape:
  ```swift
  Task { @MainActor in
      try? await Task.sleep(for: .milliseconds(100))
      collectionViewScrollProxy.refreshVisibleRange()
  }
  ```
  (decide exact placement and whether the sleep is needed when reading the actual proxy/coordinator behavior).
- [ ] do the same for the `initialMessageId` (deep-link) branch a few lines above — same problem applies.
- [ ] keep the coordinator changes (if any) generic; no `discussionDivider`-aware code in chat-shared files.
- [ ] no tests.
- [ ] report change; user verifies build and runs manual scenario "open with unreads, wait without scrolling, close, reopen → lands at bottom" before continuing.

### Task 5: Debounce + accumulate visible-range mark-as-read (~250 ms)

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionViewModel.swift`

- [ ] add private `@ObservationIgnored` state to `DiscussionViewModel`:
  ```swift
  private var pendingMarkAsReadTask: Task<Void, Never>?
  private var minObservedTop: (messageId: String, orderId: String)?
  private var maxObservedBottom: (messageId: String, orderId: String)?
  ```
- [ ] refactor `visibleRangeChanged(from:to:)` to:
  1. extract `(from.trackedMessageId, from.trackedOrderId)` and `(to.trackedMessageId, to.trackedOrderId)`; early-return if any nil (already done in Task 2 — merge logic).
  2. update `bottomVisibleOrderId` and `forceHiddenActionPanel` synchronously (unchanged behavior).
  3. extend `minObservedTop` if the new top's orderId is lexicographically smaller (or if currently nil); extend `maxObservedBottom` similarly for larger.
  4. cancel `pendingMarkAsReadTask`; assign a new Task that:
     - `try? await Task.sleep(for: .milliseconds(250))`
     - returns if cancelled
     - reads and clears `minObservedTop` / `maxObservedBottom` snapshot
     - awaits `chatStorage?.updateVisibleRange(startMessageId: snapshot.top.messageId, endMessageId: snapshot.bottom.messageId)`
     - clears `pendingMarkAsReadTask`
- [ ] make sure the lexicographic comparison on orderIDs uses Swift's default `String` `<` operator (matches the storage's existing comparisons, e.g. `oldestOrderID <= beforeOrderId`).
- [ ] confirm `DiscussionViewModel` is `@MainActor` so all this state is single-threaded.
- [ ] cancel `pendingMarkAsReadTask` on `deinit` if straightforward (since it's `@MainActor`, the Task cancellation just needs to fire on main; if `deinit` is non-isolated, accept the small leak — Task<Void, Never> is harmless).
- [ ] no tests.
- [ ] report change; user verifies build and runs manual fast-scroll scenarios in Post-Completion.

### Task 6: Replace silent try? in DiscussionMessagesStorage.markAsRead with logged failure

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/Services/DiscussionMessagesStorage.swift`

- [ ] confirm `anytypeAssertionFailure` exists and is debug-only by `rg "func anytypeAssertionFailure" Modules/AnytypeCore`. Pick the best-fit logging primitive (`anytypeAssertionFailure`, or `Logger`-style if more appropriate).
- [ ] in `markAsRead` (around line 421-441), replace the two `try? await chatService.readMessages(...)` calls with `do { try await ... } catch { anytypeAssertionFailure("Discussion mark-as-read failed: \(error)") }`. Apply to both messages branch and mentions branch.
- [ ] no tests.
- [ ] report change; user verifies build.

### Task 7: Verify acceptance criteria
- [ ] verify all six fixes are in place by inspecting the diff.
- [ ] confirm no chat-only files were modified (`git diff --stat develop...HEAD` should show only the Discussion module + `MessageSectionItem.swift` + the small proxy hook, no `ChatViewModel.swift`).
- [ ] user runs the full manual verification suite in Post-Completion.
- [ ] if any scenario fails, document with `⚠️` and iterate on the relevant task.

### Task 8: Commit, push, open PR
- [ ] commit grouping (single PR, suggested commits in order):
  1. `IOS-6068 Add tracked id accessors to MessageSectionItem`
  2. `IOS-6068 Filter dividers from discussion visible-range tracking`
  3. `IOS-6068 Force visible-range recalc after programmatic open scroll`
  4. `IOS-6068 Debounce and accumulate visible-range mark-as-read`
  5. `IOS-6068 Harden DiscussionMessagesStorage and surface read failures`
- [ ] push `ios-6068-discussions-starting-point-and-jump-down-button`.
- [ ] open PR against `develop` with title `IOS-6068 Fix discussion mark-as-read so unread anchor advances correctly` and a Summary section per CLAUDE.md (1-3 bullets). Link IOS-6068.
- [ ] do NOT add the `🧠 No brainer` label — touches logic, caching, data flow, and bug-fix behavior.
- [ ] move this plan to `docs/plans/completed/` after PR is opened.

## Post-Completion

*Manual verification scenarios (PRIMARY safety net for this plan — there are no unit tests). Run all of these before opening the PR.*

**Initial-open behavior**:
- Open discussion with unreads → lands on first unread (anchor preserved).
- Open with `initialMessageId` deep link → lands on that message (anchor preserved).
- Open discussion with NO unreads → lands at bottom.

**Anchor-clears-on-open (validates Task 4)**:
- Open discussion with unreads → wait briefly without scrolling at all → close → reopen → lands at bottom (the previous anchor was marked read on the first open).

**Slow scroll (validates Task 2 + Task 5)**:
- Open with many unreads → scroll one message at a time through the list → unread counter decrements steadily → close → reopen → lands at bottom.

**Fast scroll (validates Task 5 accumulation)**:
- Open with a long unread list → flick-scroll fast all the way to the bottom → close → reopen → lands at bottom (no comment-deep-in-the-middle stuck state).

**Jump-down arrow (validates Task 1 + Task 2 — divider lex-compare gone)**:
- Stay above all unreads → tap jump-down → scrolls down to the next unread chunk (Telegram-style).
- Position view inside the unread region or at/below it → tap jump-down → scrolls to actual bottom and marks all read.
- Manually scroll past the original first-unread → tap jump-down at any later position → button MUST scroll downward or stay; never upward.
- Tap jump-down repeatedly with no unreads remaining → always lands at the actual bottom.

**Edge cases**:
- Discussion where divider would naturally fall at the visible top or bottom on open (long root comment near the top of the screen) — open / scroll / jump-down all behave correctly.
- Offline-backfill simulation: post a comment from another client into the past while iOS is open → the new mid-history message remains unread (visible-range semantics still bounded by what the user scrolled).

**Observability**:
- During testing in debug build, watch for any `anytypeAssertionFailure` triggered by the new logging in Task 6 — if these fire, capture the stack and the surrounding action; this might reveal stale-state failures we should address in a follow-up.

**Out-of-scope follow-ups (track separately if observed)**:
- If `anytypeAssertionFailure` triggers in normal use, design a retry-on-stale-state mechanism for `markAsRead`.
- If the same divider-id-leak pattern exists in any other discussion-specific tracking surface, fix it in a separate ticket.
- Consider extracting `MessageSectionItem` to a Swift package so its accessors become unit-testable; currently blocked by the no-app-target-tests setup.

**External system updates**: none. Pure iOS bug fix; no middleware/proto changes; no consuming projects.
