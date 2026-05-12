# IOS-6002 — Comment Count Badge on Discuss Button + Discussion Header Total Count

## Overview

Add a real-time total-comment-count indicator in two places, both fed from the same source of truth:

1. **Discuss button** in `HomeBottomNavigationPanelView.discussIsland` — a counter appended inline to the right of the 48×48 message icon region; the enclosing glass container morphs from circle to capsule when count > 0. Hidden when count is `0`.
2. **Discussion screen header subtitle** (both iOS 18 legacy `DiscussionHeaderView` and iOS 26+ native toolbar title) — currently displays `messages.count` (the number of messages loaded into memory), which is wrong. Replace with the backend's total message count.

The value must update live as comments arrive, and stay consistent across bottom panel and header.

## Phasing — Two PRs

Ships in two independently reviewable PRs on the same feature branch.

**Part 1 — Business logic (observer + storage, VM wiring)** → PR #1

- Tasks R1–R5 under "Part 1 — REVISED" in Implementation Steps.
- Original Tasks 1–4 and 6 were attempted in-session and proved wrong (see "Part 1 — INVALIDATED" below and "Discovery Knowledge" above for why). They remain in the plan for history.

User-visible result after Part 1:
- **Discussion header subtitle** shows the correct backend total, live-updated via `chatUpdateMessageCount` sourced from `DiscussionMessagesStorage`.
- Bottom panel VM tracks `commentsCount` reactively via a new `DiscussionMessageCountObserver` that owns its own `SubscribeLastMessages(limit: 0)` for the editor's discussion chat. Value updates live while the editor is on screen. Nothing renders it yet — dead until Part 2.

**Part 2 — UI (discuss button morph)** → PR #2

- Task 5 — `HomeBottomNavigationPanelView.discussIsland` circle↔capsule morph with inline counter.
- Task 7 — Full acceptance pass + Figma cross-check + housekeeping.

User-visible result after Part 2: badge on the discuss button. Both surfaces now consistent.

## Context (from discovery)

**Backend contract (GO-7166, already shipped in middleware rc bundled in the repo)**

- `Anytype_Rpc.Chat.SubscribeLastMessages.Response.messageCount: Int32` — bootstrap when the Discussion screen opens its heavyweight subscription.
- `Anytype_Rpc.Chat.GetMessages.Response.messageCount: Int32` — bootstrap via a one-shot RPC (can be used with `limit: 0` to avoid loading messages).
- `Anytype_Event.Chat.UpdateMessageCount { messageCount: Int32, subIds: [String] }` — push update. Routed to any live subscription whose `subId` appears in `subIds`.
- Not exposed on `SubscribeToMessagePreviews.Response.ChatPreview` — an initial count is *not* delivered by the global preview subscription. Follow-up GO ticket can close this gap.
- Event comment: *"total number of non-deleted messages (includes replies)"*. IOS-6080 will later filter replies out — for now we ship whatever the backend returns (user confirmed).

**Currently unconsumed on iOS**

- `ChatMessagesPreviewsStorage.handle(events:)` falls into `default: break` for `chatUpdateMessageCount`.
- `DiscussionMessagesStorage.handle(events:)` same.
- `ChatService.getMessages(...)` drops `messageCount` from the response.
- `DiscussionViewModel.subscribeOnMessages()` sets `commentsCount = messages.count` (loaded count) at line 275 — wrong value.

**Files/components involved**

- `Anytype/Sources/PresentationLayer/Modules/Chat/Services/ChatMessagesPreviewsStorage.swift` — account-wide actor subscribed via `subscribeToMessagePreviews` at login; receives chat events filtered by `subIds.contains(subscriptionId)`. Already emits through `previewsStream` on state changes. Good place to own the `messageCount` cache.
- `Modules/Services/Sources/Services/Chat/ChatService.swift` — needs a thin new method that exposes `response.messageCount` (existing `getMessages` drops it).
- `Anytype/Sources/PresentationLayer/Modules/HomeNavigationContainer/Panel/HomeBottomNavigationPanelViewModel.swift` — already subscribes to editor details and derives `showDiscussButton` from `document.details?.discussionId`. Piggy-back on this.
- `Anytype/Sources/PresentationLayer/Modules/HomeNavigationContainer/Panel/HomeBottomNavigationPanelView.swift` — render badge.
- `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionViewModel.swift` — replace `messages.count` with the storage's value for `chatId`.
- `Anytype/Sources/PresentationLayer/Common/SwiftUI/CounterView.swift` — existing counter component. **Not used here** (final design uses plain inline `Text` matching the icon foreground style). Referenced only as a precedent for similar counter UI.

**Related but out of scope**

- IOS-6028 tasks 2.1 & 2.2 — **unread** dot on the button fed by `document.details?.unreadMessageCountValue`. Different data source, different visual. Do not conflate.

**Intentional product decisions**

- The count includes replies (matches middleware `messageCount` exactly). User confirmed this is the desired behavior — no reply filtering now or later. Ignore / close IOS-6080 as "won't do" once this ships.

## Discovery Knowledge (iterated during implementation review)

Learnings captured mid-implementation that reshaped the approach. Read this before assuming the original tasks still apply — several core assumptions from "## Context" turned out to be wrong.

### How middleware events reach iOS storages

```
middleware  →  ServiceMessageHandlerAdapter.shared  →  MiddlewareEventsListener.handle(_:)
            →  EventsBunch(event:).send()
            →  EventBunchSubscribtion.default  (singleton actor — fan-out bus)
            →  every subscriber sees every event
```

Each storage taps the bus via `EventBunchSubscribtion.default.stream()` and filters inside its own `handle(events:)` via `data.subIds.contains(ownSubId)` — the `subId` the storage handed to its RPC subscription.

### Three chat-event storages, three lifetimes

| Storage | Lifetime | RPC sub it opens | Scope |
| --- | --- | --- | --- |
| `ChatMessagesPreviewsStorage` | Account session (singleton) | `chatSubscribeToMessagePreviews(subId:)` | All chats in all spaces |
| `ChatMessagesStorage` | Chat screen mounted | `chatSubscribeLastMessages(chatObjectId:, subId:, limit: 100)` | One chat |
| `DiscussionMessagesStorage` | Discussion screen mounted | `chatSubscribeLastMessages(chatObjectId:, subId:, limit: 100)` | One discussion chat |

When chat A is open, middleware tags events for A with BOTH the account-wide previews `subId` AND the per-chat last-messages `subId`. Both storages accept the same event — different handlers, different purposes (preview-cache vs full-message-list).

### What each subscription delivers

| Subscription | Events delivered | Bootstrap in response |
| --- | --- | --- |
| `SubscribeToMessagePreviews` (always-on) | `chatAdd`, `chatDelete`, `chatStateUpdate` | `previews: [ChatPreview]` — last message, `ChatState`. **No `messageCount`**. |
| `SubscribeLastMessages` (per chat, while open) | Full suite including `chatUpdateMessageCount` | `chatState`, `messages`, `messageCount: Int32` |
| `GetMessages` (one-shot) | n/a | `messages`, `messageCount: Int32` |

**Critical fact, confirmed empirically**: middleware tags `chatUpdateMessageCount` **only** with the per-chat `SubscribeLastMessages` subscriber's `subId`. It is never delivered to the account-wide preview sub. If nobody has the chat open (no active `SubscribeLastMessages`), the event never fires at all.

### Response snapshot + event updates is the right pair

`SubscribeLastMessages.Response.messageCount` is the count at subscribe time — a snapshot. `chatUpdateMessageCount` events keep it current for the subscription's lifetime. Together they give drift-free live count. Deriving from `chatAdd`/`chatDelete` is possible but risks drift (reply semantics, server-side reconciliation, missed events) and never self-corrects — prefer the dedicated event.

### Why `ChatMessagesPreviewsStorage` is the wrong home for this data

1. Its sub does not receive `chatUpdateMessageCount` events ⇒ no live updates.
2. Its charter is account-wide *previews* — adding total-count conflates concerns.
3. A static `messageCount(...)` RPC accessor returns cached values that go stale the moment the chat is closed (no events refresh them) AND, on cache hit, doesn't emit — subscribers never know to update. Both effects observed empirically.

### Why not `BaseDocument`

`BaseDocument` is the per-object abstraction (details, blocks, relations). Bolting `SubscribeLastMessages` onto it would either run always (wasteful for non-discussion objects) or require it to know about chat semantics (leaky). Keep concerns separate.

### Why not reuse `DiscussionMessagesStorage` for the panel

It is heavyweight: pages 100 messages, resolves attachments via `searchService`, opens `objectIdsSubscriptionService` for attachment details, heats media cache. Wrong scale for a number.

### Subscription lifecycle cost

`chatSubscribeLastMessages` / `chatUnsubscribeLastMessages` are cheap one-shot RPCs — server-side registers/drops a `subId` in a map, no disk/DB work. Today every discussion-screen open already pays this cost. Creating/destroying on editor switch is fine: don't cache, don't debounce. If pathological rapid-switching ever becomes an issue, add a short teardown debounce later.

### User-observed problem resolution mapping

- **P1 (brief 0 before details arrive)** — accepted. Same behavior as today; `updateState` re-runs when details load and the observer is spun up then.
- **P2 (cache-hit returns stale value without emission)** — resolved. No cache. Each editor change ⇒ new observer ⇒ fresh `response.messageCount` emitted directly.
- **P3 (events stop when chat is closed)** — resolved. The panel now owns its own `SubscribeLastMessages(limit: 0)` for the current editor's chat, so middleware tags `chatUpdateMessageCount` with *our* subId and events arrive whether or not the discussion screen is mounted.
- **P4 (subscription active on widgets screen)** — resolved. No long-lived iterator; observer exists only when `discussionId` is present, is nil on widgets.

## Development Approach

- **Testing approach**: Regular — no unit tests for this task (per user's brainstorm confirmation and repo convention for this module). Manual verification in simulator is the acceptance bar.
- Complete each task fully before moving to the next.
- **Commit after each task completes.** One commit per task, message format `IOS-6002 <short description>` (single line, no AI signatures).
- Small, focused changes.
- User compiles locally in Xcode; do not run `swift build`/`xcodebuild` from this plan. Report completion when the edit is in and logical.
- Keep backward compatibility. Existing consumers of `ChatMessagesPreviewsStorage.previewsSequence` must not break when `messageCount` is added to `ChatMessagePreview`.

## Testing Strategy

No unit tests are being added. Manual QA covers:

- Open an object with no discussion → discuss button hidden, no count.
- Open an object with a discussion that has `0` comments → discuss button visible, badge hidden.
- Open an object with a discussion that has `>0` comments → discuss button visible, badge shows the total.
- Open the discussion screen → header subtitle matches the badge value (both on iOS 18 build and iOS 26+ build).
- Post a new comment from this device → badge and header both increment in real time.
- Receive a comment from another device (sync) → badge and header both increment without reopening the screen.
- Delete a comment → both decrement.

## Solution Overview

> ⚠️ **Superseded.** The approach below was the original Part 1 plan and is kept for history. It assumes `chatUpdateMessageCount` events flow through the account-wide preview sub — which is not the case in practice. See "Discovery Knowledge" above for the new understanding and "## Solution Overview — REVISED" below for the current plan.

`ChatMessagesPreviewsStorage` becomes the single source of truth for per-chat total message count. It already lives for the app's session, already handles chat events, already is injected widely. Extending it avoids a new storage class and avoids any per-chat subscription bookkeeping from the bottom panel side.

**Where we subscribe for `chatUpdateMessageCount`.** We do **not** open a new RPC subscription for this event. `ChatMessagesPreviewsStorage` already consumes the global event bus through `EventBunchSubscribtion.default.stream()` (see its `startSubscription()` at `ChatMessagesPreviewsStorage.swift:64`). All middleware events for the account flow through that stream, get routed into `handle(events:)`, and are dispatched by `switch event.value`. We are adding one more case to that switch — `.chatUpdateMessageCount(let data)` — and that's it. The existing `chatService.subscribeToMessagePreviews(subId:)` RPC already registered a subscription token; whether middleware tags `chatUpdateMessageCount` with that token's subId or not doesn't matter for our dispatch (we accept the event unconditionally and key updates by `events.contextId`, which is the chatObjectId).

Because the global preview subscription does not deliver initial counts, the storage exposes an async `messageCount(chatId:) async -> Int?` accessor that:
- returns the cached value (populated by `chatUpdateMessageCount` events) if present,
- otherwise fires a one-shot `ChatGetMessages(chatId, limit: 0)` and caches `response.messageCount`.

Thereafter, events keep the cache current. Consumers observe changes through the existing `previewsSequence`; the count is a field on `ChatMessagePreview`.

`DiscussionViewModel` and `HomeBottomNavigationPanelViewModel` both read from this storage keyed by the editor's `discussionId` (header uses its own `chatId`, which is the same object).

## Solution Overview — REVISED

Two independent mechanisms, one per surface:

1. **Bottom panel — new small service.** `DiscussionMessageCountObserver` (actor) is owned per-panel-VM. When the editor's `discussionId` resolves, the VM constructs one scoped to that chat. The observer opens its own lightweight `chatSubscribeLastMessages(chatObjectId:, subId:, limit: 0)`, seeds from `response.messageCount`, and keeps the value live by handling `chatUpdateMessageCount` events tagged with *its* `subId`. On editor change or VM teardown, the observer is released — ARC triggers deinit, which unsubscribes. No caching, no ref-counting.

2. **Discussion header — extend the existing per-chat storage.** `DiscussionMessagesStorage` already opens `SubscribeLastMessages` for the discussion screen. We capture its `response.messageCount` at subscribe time, add a `chatUpdateMessageCount` case to its existing `handle(events:)` switch, and emit a new `ChatUpdate.messageCount` notification through the existing `updateStream`. `DiscussionViewModel` reads from there. Zero extra RPCs, the count is effectively free given the screen's existing subscription.

`ChatMessagesPreviewsStorage` is reverted to its original shape — it has no reason to know about total message count. The `ChatUpdateMessageCountData` typealias in `ChatModels.swift` is retained; both the observer and the storage extension use it.

## Technical Details

> ⚠️ **Superseded.** This section documents the original (invalidated) approach. See "## Technical Details — REVISED" below the original for the current design. Kept for history.

**Data model**

```swift
// ChatMessagePreview (existing struct — add one field)
struct ChatMessagePreview {
    let spaceId: String
    let chatId: String
    var lastMessage: LastMessagePreview?
    var state: ChatState?
    var messageCount: Int?   // NEW — nil = not yet fetched, otherwise the backend total
}
```

**Storage protocol additions** (`ChatMessagesPreviewsStorage.swift`)

```swift
protocol ChatMessagesPreviewsStorageProtocol: AnyObject, Sendable {
    // existing members…
    func messageCount(spaceId: String, chatId: String) async -> Int?
}
```

**Service addition** (`ChatService.swift`)

```swift
protocol ChatServiceProtocol {
    // existing members…
    func getMessageCount(chatObjectId: String) async throws -> Int
}

// impl:
func getMessageCount(chatObjectId: String) async throws -> Int {
    let result = try await ClientCommands.chatGetMessages(.with {
        $0.chatObjectID = chatObjectId
        $0.limit = 0
    }).invoke()
    return Int(result.messageCount)
}
```

**Event handling** (extend `handle(events:)` switch)

```swift
case let .chatUpdateMessageCount(data):
    if handleChatUpdateMessageCountEvent(
        spaceId: event.spaceID,
        contextId: events.contextId,
        data: data
    ) {
        hasChanges = true
    }
```

The helper upserts a preview row for `(spaceId, chatId = contextId)` and sets `messageCount = Int(data.messageCount)`.

**Subscription gate — deliberately different from other chat events.** `chatStateUpdate`/`chatAdd`/`chatDelete` gate on `data.subIds.contains(subscriptionId)` because those events can arrive on multiple subscriptions covering the same chat, so we only want the preview-sub's view. `chatUpdateMessageCount` is different: the count is a single per-chat value keyed by `contextId`, there is no cross-subscription ambiguity, and middleware *may* not even tag this event with the previews subId (it was added for the per-chat `SubscribeLastMessages`/`GetMessages` API surface). So we accept this event **unconditionally**. During dev, log `data.subIds` the first time the handler fires to confirm middleware behavior; if the previews subId is indeed listed, the unconditional path is still correct (the gate would be a no-op).

**Lazy bootstrap**

`messageCount(spaceId:chatId:)` returns the cached value when present; otherwise awaits `chatService.getMessageCount(chatObjectId:)`, writes it into `previewsBySpace`, emits through `previewsStream`, and returns the new value. A concurrent fetch for the same chatId should not double-dispatch — track in-flight fetches in a `[chatId: Task<Int?, Never>]` map.

**Consumer wiring** (`HomeBottomNavigationPanelViewModel.swift`)

Match the precedent in `UnreadChatWidgetViewModel.startPreviewsSubscription()` and `HomeWidgetViewModel` — a single long-lived `for await` over `previewsSequence`, filtered by the currently-tracked chatId on each emission. The VM is already `@MainActor`, so assignments inside the loop are main-actor-safe without wrapping.

- Add `@ObservationIgnored @Injected(\.chatMessagesPreviewsStorage) private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol`.
- Add `var commentsCount: Int = 0` observable property.
- Add `@ObservationIgnored private var currentDiscussionId: String?` (latest resolved discussionId; read inside the loop).
- In `startSubscriptions()`, add `async let commentsCountSub: () = subscribeOnCommentsCount()` alongside the existing subscriptions.
- Implement `subscribeOnCommentsCount()`:
  ```swift
  private func subscribeOnCommentsCount() async {
      for await previews in await chatMessagesPreviewsStorage.previewsSequence {
          guard let chatId = currentDiscussionId,
                let preview = previews.first(where: { $0.chatId == chatId }) else {
              commentsCount = 0
              continue
          }
          commentsCount = preview.messageCount ?? 0
      }
  }
  ```
- In `updateState()`, when `discussionId` is resolved for the current editor: set `currentDiscussionId = discussionId` and fire a detached bootstrap `Task { _ = await chatMessagesPreviewsStorage.messageCount(spaceId: spaceId, chatId: discussionId) }`. When the editor has no discussion or data is missing, set `currentDiscussionId = nil` and `commentsCount = 0`.
- No cancel/restart of the long-lived task on editor changes — only `currentDiscussionId` flips. This matches the widget VMs and keeps the code shape small.

**Task lifetime — answering "how do we cancel when user navigates away?"**

The `for await` loop does not need manual cancellation. It is started from `startSubscriptions()`, which is invoked from the view's `.task { await model.startSubscriptions() }` modifier in `HomeBottomNavigationPanelViewInternal.body` (`HomeBottomNavigationPanelView.swift:69-71`). SwiftUI's `.task` modifier automatically cancels that async task when the view disappears. The parent task's cancellation propagates into the `async let` group, which cancels all children — including our `subscribeOnCommentsCount()` iterator. So:

- Switching between objects in the same space: panel stays on screen → VM stays alive → subscription keeps running, `currentDiscussionId` just updates. Correct behavior.
- Switching spaces: outer view rebuilds due to `.id(info.accountSpaceId)` (`HomeBottomNavigationPanelView.swift:14`) → old VM is torn down → SwiftUI cancels its `.task` → our subscription task exits cleanly.
- Navigating back to widgets / screen where the panel is not rendered: same as above — SwiftUI cancels `.task` when the panel view leaves the hierarchy.

No manual cancellation code required.

**Consumer wiring** (`HomeBottomNavigationPanelView.swift`)

**The discuss button itself stays 48×48 always.** The icon continues to sit in a fixed 48×48 region — that's the button's "core" and its visual/tap center does not move. What changes is the **enclosing container**: when `commentsCount > 0`, a counter label is appended inside the same glass surface, and the surrounding shape morphs from Circle (48×48) to Capsule (48 tall, wider).

Layout spec (from user):

- `commentsCount == 0` → Circle, 48×48, icon only (identical to today).
- `commentsCount > 0` → Capsule, 48 tall. Inside: `[48×48 icon region] + 3pt gap + [count text] + 12pt trailing padding`. The 12pt "left padding" inside the capsule is implicit — the icon is already centered inside its 48×48 region, so the capsule's left semicircle naturally provides whitespace around it.

No overlay. No `CounterView` — the number is a plain `Text` inside the same HStack as the icon, styled to match `Color.Control.primary`. The shape passed to `contentShape` and `glassEffectInteractiveIOS26` must change with the state so the hit area and Liquid Glass tint follow the visible outline.

Rough shape:

```swift
private var discussIsland: some View {
    Button { model.onTapDiscuss() } label: {
        HStack(spacing: 3) {
            Image(systemName: "message")
                .foregroundStyle(Color.Control.primary)
                .frame(width: 48, height: 48)   // ← button core stays 48×48
            if model.commentsCount > 0 {
                Text("\(model.commentsCount)")
                    .foregroundStyle(Color.Control.primary)
                    .padding(.trailing, 12)
                    // typography: match Figma node 11172-5099 before landing
            }
        }
        .frame(height: 48)
        .contentShape(model.commentsCount > 0 ? AnyShape(Capsule()) : AnyShape(Circle()))
    }
    .glassEffectInteractiveIOS26(in: model.commentsCount > 0 ? AnyShape(Capsule()) : AnyShape(Circle()))
    .animation(.default, value: model.commentsCount > 0)
}
```

Notes:

- The icon's own `.frame(width: 48, height: 48)` keeps the button's visual core at 48×48 regardless of counter state. Only the outer container (the HStack + glass shape) grows.
- `AnyShape` lets us swap between `Circle()` and `Capsule()` without a ternary at the call site of `glassEffectInteractiveIOS26`. If that modifier's generic signature rejects `AnyShape`, branch the whole view with `if/else` instead. Verify against `liquid-glass-developer` precedents.
- Animate only on the shape-defining condition (`commentsCount > 0`), not on the raw count, to avoid jittery animations when the number grows from `9` to `10`.
- Icon stays `message` — do not use `message.badge` (that is the unread-dot variant from IOS-6028).
- Figma: `https://www.figma.com/design/AmcNix4nhUIKx02POalQ3T/-M--Discussions?node-id=11172-5099&m=dev`. Confirm typography, exact colors, and padding against the node before committing.

**Consumer wiring** (`DiscussionViewModel.swift`)

Same single long-lived `for await` shape as the bottom panel, but chatId is read from `self.chatId` on each emission (it may transition from `nil` → non-nil when the user writes a first comment via `createDiscussionIfNeeded`).

- Inject `@Injected(\.chatMessagesPreviewsStorage) @ObservationIgnored`.
- In `startSubscriptions()` add `async let commentsCountSub: () = subscribeOnCommentsCount()`.
- New private method:
  ```swift
  private func subscribeOnCommentsCount() async {
      for await previews in await chatMessagesPreviewsStorage.previewsSequence {
          guard let chatId,
                let preview = previews.first(where: { $0.chatId == chatId }) else {
              continue
          }
          commentsCount = preview.messageCount ?? 0
      }
  }
  ```
- Delete the `self.commentsCount = messages.count` assignment at line 275.
- Kick the lazy bootstrap in two places (whichever fires first wins, the other is a cheap cache hit):
  - In `startSubscriptions()` if `chatId != nil` at start: `Task { _ = await chatMessagesPreviewsStorage.messageCount(spaceId: spaceId, chatId: chatId) }`.
  - At the end of `createDiscussionIfNeeded(...)` after `self.chatId = newChatId`: same bootstrap call.
- **Do not** relaunch `subscribeOnCommentsCount()` from `startDeferredSubscriptions()` — the original long-lived task already reads `self.chatId` each iteration, so it picks up the new id as soon as `previewsSequence` emits (which it will, because the bootstrap just populated it). This avoids two concurrent iterators racing to write `commentsCount`.

## Technical Details — REVISED

### New: `DiscussionMessageCountObserver`

Location: `Anytype/Sources/PresentationLayer/Modules/Chat/Services/DiscussionMessageCountObserver.swift` (peer to `ChatMessagesPreviewsStorage`).

```swift
actor DiscussionMessageCountObserver {
    init(spaceId: String, chatId: String)
    func start() async throws
    var messageCountStream: AnyAsyncSequence<Int> { get async }
    // deinit: cancels the event-bus task and fires unsubscribeLastMessages
}
```

Implementation notes:

- Owns a unique `subId` (`"DiscussionMessageCountObserver-\(UUID().uuidString)"`).
- `start()` calls `chatService.subscribeLastMessages(chatObjectId:, subId:, limit: 0)`. Emits `Int(response.messageCount)` into its internal stream, then starts a task iterating `EventBunchSubscribtion.default.stream()`.
- In `handle(events:)`: only the `.chatUpdateMessageCount(data)` case is handled, gated by `data.subIds.contains(subId)` (our own sub's id — the gate is safe because we own the subscription we're filtering for).
- `deinit`: cancel the bus-iteration task. Detached `Task` calling `chatService.unsubscribeLastMessages(chatObjectId:, subId:)` — follow the pattern at `DiscussionMessagesStorage.swift:221-228`. Bail out if `basicUserInfoStorage.usersId.isEmpty` to avoid calling through on logout.
- Verify with middleware team: `chatSubscribeLastMessages(limit: 0)` must mean "subscribe without loading messages" (i.e. just establish the sub, return `messageCount` and `chatState`, send events). If middleware interprets `0` as "unlimited", use `limit: 1` instead — count of one loaded message is still tiny.

### `DiscussionMessagesStorage` extension

```swift
private(set) var messageCount: Int?
```

- In `startSubscriptionIfNeeded(...)`, after `subscribeLastMessages(...)` returns: `messageCount = Int(response.messageCount)`. Include in the initial `syncStream.send(ChatUpdate.allCases)` dispatch (a new case `.messageCount` is added).
- In `handle(events:)`, new switch arm:
  ```swift
  case let .chatUpdateMessageCount(data):
      guard data.subIds.contains(subId) else { break }
      let newCount = Int(data.messageCount)
      if messageCount != newCount {
          messageCount = newCount
          updates.insert(.messageCount)
      }
  ```
- Add `.messageCount` to the `ChatUpdate` enum (find the enum via `rg "enum ChatUpdate" --type swift`; it lives in the shared chat module alongside the storage).

### `HomeBottomNavigationPanelViewModel` wiring

- Drop `@Injected(\.chatMessagesPreviewsStorage)` and the earlier `subscribeOnCommentsCount` / long-lived iterator.
- New state:
  ```swift
  @ObservationIgnored private var messageCountObserver: DiscussionMessageCountObserver?
  @ObservationIgnored private var messageCountIterationTask: Task<Void, Never>?
  var commentsCount: Int = 0
  ```
- In `updateState()` (inside the `hasDiscussion, let discussionId` branch):
  - If observer is nil or observer's `chatId != discussionId`:
    1. `messageCountIterationTask?.cancel()`; `messageCountObserver = nil` (deinit unsubscribes previous chat).
    2. `commentsCount = 0` (optimistic reset while the new observer boots).
    3. Create new observer, kick `Task { @MainActor [weak self] in try? await observer.start(); for await count in await observer.messageCountStream { self?.commentsCount = count } }`.
    4. Store observer + iteration task on the VM.
- In the else branches (no editor / no discussion): tear down observer and iteration task, reset `commentsCount = 0`.

### `DiscussionViewModel` wiring

- Drop the earlier injection of `ChatMessagesPreviewsStorage`, `subscribeOnCommentsCount`, and `bootstrapCommentsCount`.
- In `subscribeOnMessages`, handle the new update: `if updates.contains(.messageCount) { self.commentsCount = await chatStorage?.messageCount ?? 0 }`.
- Keep the existing long-lived `for await updates in chatStorage.updateStream` loop — no new subscription needed.

## What Goes Where

**Implementation Steps** (`[ ]` checkboxes) — all code lives in this repo.

**Post-Completion** — manual simulator verification, optional GO follow-up.

## Implementation Steps

### Part 1 — INVALIDATED (original approach — DO NOT IMPLEMENT)

The five tasks below were the original Part 1 plan. Mid-implementation, manual testing surfaced four problems (see "Discovery Knowledge → User-observed problem resolution mapping") that all trace back to two wrong assumptions:

1. **`ChatMessagesPreviewsStorage` does not receive `chatUpdateMessageCount` events.** Middleware tags the event only with the per-chat `SubscribeLastMessages` subscriber's `subId`, never the account-wide previews sub's. Our unconditional handler never fires for a chat that isn't actively open via `SubscribeLastMessages` somewhere else.
2. **An RPC-cache accessor is structurally broken for this use case.** On cache hit it returns stale data without emitting, so subscribers never update. On cache miss it hits the backend once — fine — but the value goes stale the instant anyone else writes to the chat.

The revised approach gives the panel its own per-discussion `SubscribeLastMessages(limit: 0)` (so `chatUpdateMessageCount` is tagged with *our* `subId`) and lets `DiscussionMessagesStorage` feed the header (its own already-open `SubscribeLastMessages` carries the authoritative value).

Kept here as a record of what was tried and rejected. When implementing, skip directly to "Part 1 — REVISED".

#### Task 1: Extend `ChatService` with `getMessageCount`  *(Part 1 — PR #1)*  ⚠️ INVALIDATED

**Files:**
- Modify: `Modules/Services/Sources/Services/Chat/ChatService.swift`

- [ ] Add `func getMessageCount(chatObjectId: String) async throws -> Int` to `ChatServiceProtocol`.
- [ ] Implement it by calling `ClientCommands.chatGetMessages` with `limit = 0` and returning `Int(result.messageCount)`.
- [ ] Keep the existing `getMessages` methods unchanged — callers that want messages still get messages.

#### Task 2: Extend `ChatMessagePreview` and storage with `messageCount`  *(Part 1 — PR #1)*  ⚠️ INVALIDATED

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Chat/Services/ChatMessagesPreviewsStorage.swift`
- Likely also: the `ChatMessagePreview` struct definition (find its file via `rg -l "struct ChatMessagePreview"` — if not in the storage file).

- [ ] Locate the `ChatMessagePreview` struct and add `var messageCount: Int?` (default `nil`).
- [ ] In `ChatMessagesPreviewsStorage.handle(events:)` add a switch case for `.chatUpdateMessageCount(let data)` that calls a new `handleChatUpdateMessageCountEvent(spaceId:contextId:data:)`.
- [ ] Implement the handler **without a `data.subIds.contains(subscriptionId)` gate** — the count is per-chat keyed by `contextId`, and middleware may not tag this event with the previews subId. Upsert the preview for `(spaceId, chatId = contextId)`; set `messageCount = Int(data.messageCount)`; return `true` so `hasChanges` flips.
- [ ] Add a one-time dev log of `data.subIds` inside the handler so we can confirm middleware tagging behavior during QA; remove the log before landing.
- [ ] Verify the existing trailing `if hasChanges { previewsStream.send(...) }` at the end of `handle(events:)` fires for this case — no new emit call needed.

#### Task 3: Lazy bootstrap + public accessor on the storage  *(Part 1 — PR #1)*  ⚠️ INVALIDATED

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Chat/Services/ChatMessagesPreviewsStorage.swift`

- [ ] Add `func messageCount(spaceId: String, chatId: String) async -> Int?` to `ChatMessagesPreviewsStorageProtocol`.
- [ ] Implement in the actor:
  - If `previewsBySpace[(spaceId, chatId)]?.messageCount` exists, return it.
  - Dedupe in-flight fetches via a `[ChatMessagePreviewKey: Task<Int?, Never>]` map — if a task for the same key is already running, `await` its value instead of firing a second RPC.
  - On miss: `try? await chatService.getMessageCount(chatObjectId: chatId)`, upsert into `previewsBySpace`, emit `previewsStream.send(...)`, return the value. Errors from `getMessageCount` are intentionally swallowed — caller receives `nil` and gets a retry on the next invocation (e.g., next editor open).
- [ ] For task cleanup, mirror the existing `subscription?.cancel()` pattern in `deinit`. Do not invent new cancellation machinery; if in-flight bootstrap tasks don't cleanly fit the existing pattern, rely on the tasks completing naturally (each is a single RPC).

#### Task 4: Wire bottom panel VM to the count  *(Part 1 — PR #1)*  ⚠️ INVALIDATED

Follow the `UnreadChatWidgetViewModel.startPreviewsSubscription()` precedent: a single long-lived `for await` — no cancel/restart on editor changes.

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeNavigationContainer/Panel/HomeBottomNavigationPanelViewModel.swift`

- [ ] Add `@ObservationIgnored @Injected(\.chatMessagesPreviewsStorage) private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol`.
- [ ] Add `var commentsCount: Int = 0` observable property.
- [ ] Add `@ObservationIgnored private var currentDiscussionId: String?` — latest resolved discussionId; read inside the loop.
- [ ] Add `private func subscribeOnCommentsCount() async` that iterates `chatMessagesPreviewsStorage.previewsSequence`, matches by `currentDiscussionId`, and assigns `commentsCount = preview.messageCount ?? 0` (or `0` when no current id / no matching preview). VM is `@MainActor` so assignments are already main-actor-safe.
- [ ] Add `async let commentsCountSub: () = subscribeOnCommentsCount()` to the `startSubscriptions()` group.
- [ ] In `updateState()`, when `discussionId` is present: set `currentDiscussionId = discussionId` and kick a detached bootstrap `Task { _ = await chatMessagesPreviewsStorage.messageCount(spaceId: editorData.spaceId, chatId: discussionId) }`. In the early-return branches (no editor data, no objectId, `DiscussionCoordinatorData`), set `currentDiscussionId = nil` and `commentsCount = 0`.

#### Task 6: Replace loaded-count with backend count in `DiscussionViewModel`  *(Part 1 — PR #1)*  ⚠️ INVALIDATED

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionViewModel.swift`

- [ ] Add `@Injected(\.chatMessagesPreviewsStorage) @ObservationIgnored private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol`.
- [ ] Delete the `self.commentsCount = messages.count` assignment in `subscribeOnMessages()` (line 275).
- [ ] Add `private func subscribeOnCommentsCount() async` that iterates `chatMessagesPreviewsStorage.previewsSequence` and, on each emission, reads the current `self.chatId` (may be nil if no first comment yet), finds the matching preview, and assigns `commentsCount = preview.messageCount ?? 0`. If `chatId` is nil or no matching preview, `continue` (don't overwrite).
- [ ] Add it to the `startSubscriptions()` group as `async let commentsCountSub: () = subscribeOnCommentsCount()`.
- [ ] In `startSubscriptions()` **after** the group starts, if `chatId` is already non-nil at init time, kick a bootstrap `Task { _ = await chatMessagesPreviewsStorage.messageCount(spaceId: spaceId, chatId: chatId) }`.
- [ ] At the end of `createDiscussionIfNeeded(...)` (after `self.chatId = newChatId`), kick the same bootstrap call so the existing long-lived `subscribeOnCommentsCount()` task picks up the new chatId on the next `previewsSequence` emission.
- [ ] **Do not** relaunch `subscribeOnCommentsCount()` from `startDeferredSubscriptions()`. One long-lived iterator is enough — a second would race on `commentsCount` writes.

### Part 1 — REVISED

Five sequential tasks. Commit after each (`IOS-6002 <short>`), single-line messages as in the Development Approach.

#### Task R1: Revert invalidated code  *(Part 1 — PR #1)*

**Files to modify:**
- `Modules/Services/Sources/Services/Chat/ChatService.swift`
- `Anytype/Sources/PresentationLayer/Modules/Chat/Services/Models/ChatMessagePreview.swift`
- `Anytype/Sources/PresentationLayer/Modules/Chat/Services/ChatMessagesPreviewsStorage.swift`
- `Anytype/Sources/PresentationLayer/Modules/HomeNavigationContainer/Panel/HomeBottomNavigationPanelViewModel.swift`
- `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionViewModel.swift`

- [x] Remove `func getMessageCount(chatObjectId:) async throws -> Int` from `ChatServiceProtocol` and its implementation.
- [x] Remove `messageCount: Int?` field and its default-init from `ChatMessagePreview`.
- [x] Remove from `ChatMessagesPreviewsStorage`: the `messageCount(spaceId:chatId:)` method, the `inFlightMessageCountFetches` map, `applyFetchedMessageCount`, and the `.chatUpdateMessageCount` case in `handle(events:)`. Restore the storage to its pre-IOS-6002 shape.
- [x] **Keep** the `ChatUpdateMessageCountData` typealias in `Modules/Services/Sources/Models/ChatModels.swift` — Task R2 and Task R4 both reference it.
- [x] Remove from `HomeBottomNavigationPanelViewModel`: the `@Injected(\.chatMessagesPreviewsStorage)`, `currentDiscussionId`, `commentsCount`, `subscribeOnCommentsCount()`, and the bootstrap `Task { ... messageCount(...) }` inside `updateState`. `updateState` returns to its pre-IOS-6002 shape.
- [x] Remove from `DiscussionViewModel`: `@Injected(\.chatMessagesPreviewsStorage)`, `subscribeOnCommentsCount`, `bootstrapCommentsCount`, the `commentsCountSub` async-let in `startSubscriptions`, and the bootstrap call at the end of `createDiscussionIfNeeded`. Keep `commentsCount` as a stored property. Do NOT restore `self.commentsCount = messages.count` — that was the original bug; Task R5 replaces it with the right source.

#### Task R2: Create `DiscussionMessageCountObserver`  *(Part 1 — PR #1)*

**Files:**
- New: `Anytype/Sources/PresentationLayer/Modules/Chat/Services/DiscussionMessageCountObserver.swift`

- [x] Implement as an `actor` with the shape in "## Technical Details — REVISED → New: `DiscussionMessageCountObserver`".
- [x] `start()` opens `chatService.subscribeLastMessages(chatObjectId:, subId:, limit: 0)`, emits `Int(response.messageCount)` into an internal `AsyncToManyStream<Int>`, then kicks a `for await events in EventBunchSubscribtion.default.stream()` task.
- [x] Event handler: only `.chatUpdateMessageCount(data)` case, gated by `data.subIds.contains(subId)`. Emit the updated count through the same stream.
- [x] `deinit`: cancel the events task; detached `Task` calling `chatService.unsubscribeLastMessages(chatObjectId:, subId:)`, guarded by `basicUserInfoStorage.usersId.isNotEmpty`. Mirror the pattern at `DiscussionMessagesStorage.swift:221-228`.
- [x] Verify with a first run: if `chatSubscribeLastMessages(limit: 0)` returns no messages and delivers events, we're good. If it returns everything (0 interpreted as unlimited), switch to `limit: 1`.

#### Task R3: Wire `HomeBottomNavigationPanelViewModel` with the observer  *(Part 1 — PR #1)*

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeNavigationContainer/Panel/HomeBottomNavigationPanelViewModel.swift`

- [x] Add `var commentsCount: Int = 0` observable property.
- [x] Add `@ObservationIgnored private var messageCountObserver: DiscussionMessageCountObserver?` and `@ObservationIgnored private var messageCountIterationTask: Task<Void, Never>?`.
- [x] Add a helper `private func setMessageCountObserver(spaceId: String, chatId: String)` that: cancels the existing iteration task; constructs the new observer; kicks `Task { @MainActor [weak self] in try? await observer.start(); for await count in await observer.messageCountStream { self?.commentsCount = count } }`; stores both onto the VM. Track the observer's chatId via a small struct or a separate `private var currentDiscussionId: String?`.
- [x] Add a helper `private func clearMessageCountObserver()` that cancels the iteration task, releases the observer (ARC → deinit → unsubscribe), and resets `commentsCount = 0` and `currentDiscussionId = nil`.
- [x] In `updateState()`:
  - When `hasDiscussion, let discussionId` and `discussionId != currentDiscussionId`: call `setMessageCountObserver(spaceId:chatId:)`.
  - In the else branches (no editor data, no discussion): call `clearMessageCountObserver()`.
  - When `DiscussionCoordinatorData` early-return fires: **do not** clear the observer — the panel is hidden anyway, and popping back to the editor should show the same count without a reload bounce.

#### Task R4: Extend `DiscussionMessagesStorage` with `messageCount`  *(Part 1 — PR #1)*

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/Services/DiscussionMessagesStorage.swift`
- Modify: the `ChatUpdate` enum (find via `rg "enum ChatUpdate" --type swift`).

- [x] Add `case messageCount` to the `ChatUpdate` enum. If `allCases` is still synthesized via `CaseIterable`, the initial `syncStream.send(ChatUpdate.allCases)` will pick it up automatically.
- [x] Add `private(set) var messageCount: Int?` to `DiscussionMessagesStorage`.
- [x] In `startSubscriptionIfNeeded(...)` after the `subscribeLastMessages(...)` call: `messageCount = Int(response.messageCount)`.
- [x] In `handle(events:)` switch, add:
  ```swift
  case let .chatUpdateMessageCount(data):
      guard data.subIds.contains(subId) else { break }
      let newCount = Int(data.messageCount)
      if messageCount != newCount {
          messageCount = newCount
          updates.insert(.messageCount)
      }
  ```

#### Task R5: Wire `DiscussionViewModel` from `DiscussionMessagesStorage`  *(Part 1 — PR #1)*

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionViewModel.swift`

- [x] In `subscribeOnMessages`, after reading `chatStorage.chatState` / `chatStorage.fullMessages`, add: `if updates.contains(.messageCount) { self.commentsCount = await chatStorage.messageCount ?? 0 }`.
- [x] Ensure `commentsCount` remains an observable stored property (do not reintroduce the old `messages.count` assignment).
- [x] No other changes — the existing `for await updates in chatStorage.updateStream` loop is the only consumer we need.

### Part 2 — UI

#### Task 5: Morph `discussIsland` into circle↔capsule with inline counter  *(Part 2 — PR #2)*

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeNavigationContainer/Panel/HomeBottomNavigationPanelView.swift`

- [ ] Replace the inner of `discussIsland`'s button label with an `HStack(spacing: 3)` containing `Image(systemName: "message").frame(width: 48, height: 48)` — the icon's 48×48 region is the button core and does NOT grow — plus a conditional `Text("\(model.commentsCount)").padding(.trailing, 12)` when `model.commentsCount > 0`.
- [ ] Apply `.frame(height: 48)` on the HStack so the outer container is 48 tall in both states. Width is determined by content: 48 (just the icon region) when no counter, wider (icon region + gap + text + 12 trailing) when counter is shown.
- [ ] Swap the shape used by `contentShape(...)` and `glassEffectInteractiveIOS26(in: ...)` from `Circle()` to `Capsule()` when `commentsCount > 0`. Prefer a plain `if/else` over `AnyShape` — it avoids the type-erasure cost and lets SwiftUI animate the shape identity change more reliably. Grep existing `glassEffectInteractiveIOS26` callsites for a precedent before writing.
- [ ] Add `.animation(.default, value: model.commentsCount > 0)` so the shape morph is smooth, but keyed off the boolean (not the int) to avoid jitter when the count changes from e.g. 9 → 10.
- [ ] Match counter typography and colors against Figma node `11172-5099`. Text color: `Color.Control.primary` as a starting point. Confirm font with design-system-developer reference.
- [ ] Keep the plain `message` SF symbol (no `message.badge` — that is IOS-6028).
- [ ] Do NOT merge the unread-dot behavior from IOS-6028 task 2.2 here.

#### Task 7: Final — acceptance + housekeeping  *(Part 2 — PR #2)*

- [ ] Manually verify the scenarios in the Testing Strategy section on both iOS 18 and iOS 26+ builds.
- [ ] Re-check counter `Text` typography and color against Figma (`node-id=11172-5099`) — adjust font and foreground style if off.
- [ ] Confirm no new warnings in Xcode.
- [ ] Delete this plan from `docs/plans/` into `docs/plans/completed/` on merge.

## Post-Completion

**Manual verification** (user performs in simulator — see Testing Strategy above for the full scenario list).

**Optional GO follow-up (non-blocking)**
- File a middleware ticket asking to tag `chatUpdateMessageCount` events with the `SubscribeToMessagePreviews` subscriber's `subId` too (and add `messageCount: int32` to `ChatPreview` for bootstrap). Rationale: would let `ChatMessagesPreviewsStorage` itself carry the count, and we could delete `DiscussionMessageCountObserver` entirely — the panel would just read from the existing `previewsSequence` like SpaceHub does. Today the observer exists purely because of this gap.

**Related tasks tracked elsewhere**
- IOS-6028 tasks 2.1/2.2 — **unread dot** on discuss button (different data source: `document.details?.unreadMessageCountValue`).
- IOS-6080 — filter replies out of the total count (blocked on backend API).
