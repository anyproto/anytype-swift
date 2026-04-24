# IOS-6002 — Comment Count Badge on Discuss Button + Discussion Header Total Count

## Overview

Add a real-time total-comment-count indicator in two places, both fed from the same source of truth:

1. **Discuss button** in `HomeBottomNavigationPanelView.discussIsland` — a counter appended inline to the right of the 48×48 message icon region; the enclosing glass container morphs from circle to capsule when count > 0. Hidden when count is `0`.
2. **Discussion screen header subtitle** (both iOS 18 legacy `DiscussionHeaderView` and iOS 26+ native toolbar title) — currently displays `messages.count` (the number of messages loaded into memory), which is wrong. Replace with the backend's total message count.

The value must update live as comments arrive, and stay consistent across bottom panel and header.

## Phasing — Two PRs

Ships in two independently reviewable PRs on the same feature branch.

**Part 1 — Business logic (service, storage, VM wiring)** → PR #1

- Task 1, Task 2, Task 3 — `ChatService` + `ChatMessagesPreviewsStorage` plumbing.
- Task 4 — `HomeBottomNavigationPanelViewModel` wiring (`commentsCount` tracked but not yet rendered).
- Task 6 — `DiscussionViewModel` wiring (replaces the wrong `messages.count`).

User-visible result after Part 1: **Discussion header subtitle** shows the correct backend total on both iOS 18 and iOS 26+ builds. The bottom-panel VM tracks `commentsCount` but nothing renders it yet — dead until Part 2.

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

`ChatMessagesPreviewsStorage` becomes the single source of truth for per-chat total message count. It already lives for the app's session, already handles chat events, already is injected widely. Extending it avoids a new storage class and avoids any per-chat subscription bookkeeping from the bottom panel side.

**Where we subscribe for `chatUpdateMessageCount`.** We do **not** open a new RPC subscription for this event. `ChatMessagesPreviewsStorage` already consumes the global event bus through `EventBunchSubscribtion.default.stream()` (see its `startSubscription()` at `ChatMessagesPreviewsStorage.swift:64`). All middleware events for the account flow through that stream, get routed into `handle(events:)`, and are dispatched by `switch event.value`. We are adding one more case to that switch — `.chatUpdateMessageCount(let data)` — and that's it. The existing `chatService.subscribeToMessagePreviews(subId:)` RPC already registered a subscription token; whether middleware tags `chatUpdateMessageCount` with that token's subId or not doesn't matter for our dispatch (we accept the event unconditionally and key updates by `events.contextId`, which is the chatObjectId).

Because the global preview subscription does not deliver initial counts, the storage exposes an async `messageCount(chatId:) async -> Int?` accessor that:
- returns the cached value (populated by `chatUpdateMessageCount` events) if present,
- otherwise fires a one-shot `ChatGetMessages(chatId, limit: 0)` and caches `response.messageCount`.

Thereafter, events keep the cache current. Consumers observe changes through the existing `previewsSequence`; the count is a field on `ChatMessagePreview`.

`DiscussionViewModel` and `HomeBottomNavigationPanelViewModel` both read from this storage keyed by the editor's `discussionId` (header uses its own `chatId`, which is the same object).

## Technical Details

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

## What Goes Where

**Implementation Steps** (`[ ]` checkboxes) — all code lives in this repo.

**Post-Completion** — manual simulator verification, optional GO follow-up.

## Implementation Steps

### Task 1: Extend `ChatService` with `getMessageCount`  *(Part 1 — PR #1)*

**Files:**
- Modify: `Modules/Services/Sources/Services/Chat/ChatService.swift`

- [ ] Add `func getMessageCount(chatObjectId: String) async throws -> Int` to `ChatServiceProtocol`.
- [ ] Implement it by calling `ClientCommands.chatGetMessages` with `limit = 0` and returning `Int(result.messageCount)`.
- [ ] Keep the existing `getMessages` methods unchanged — callers that want messages still get messages.

### Task 2: Extend `ChatMessagePreview` and storage with `messageCount`  *(Part 1 — PR #1)*

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Chat/Services/ChatMessagesPreviewsStorage.swift`
- Likely also: the `ChatMessagePreview` struct definition (find its file via `rg -l "struct ChatMessagePreview"` — if not in the storage file).

- [ ] Locate the `ChatMessagePreview` struct and add `var messageCount: Int?` (default `nil`).
- [ ] In `ChatMessagesPreviewsStorage.handle(events:)` add a switch case for `.chatUpdateMessageCount(let data)` that calls a new `handleChatUpdateMessageCountEvent(spaceId:contextId:data:)`.
- [ ] Implement the handler **without a `data.subIds.contains(subscriptionId)` gate** — the count is per-chat keyed by `contextId`, and middleware may not tag this event with the previews subId. Upsert the preview for `(spaceId, chatId = contextId)`; set `messageCount = Int(data.messageCount)`; return `true` so `hasChanges` flips.
- [ ] Add a one-time dev log of `data.subIds` inside the handler so we can confirm middleware tagging behavior during QA; remove the log before landing.
- [ ] Verify the existing trailing `if hasChanges { previewsStream.send(...) }` at the end of `handle(events:)` fires for this case — no new emit call needed.

### Task 3: Lazy bootstrap + public accessor on the storage  *(Part 1 — PR #1)*

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Chat/Services/ChatMessagesPreviewsStorage.swift`

- [ ] Add `func messageCount(spaceId: String, chatId: String) async -> Int?` to `ChatMessagesPreviewsStorageProtocol`.
- [ ] Implement in the actor:
  - If `previewsBySpace[(spaceId, chatId)]?.messageCount` exists, return it.
  - Dedupe in-flight fetches via a `[ChatMessagePreviewKey: Task<Int?, Never>]` map — if a task for the same key is already running, `await` its value instead of firing a second RPC.
  - On miss: `try? await chatService.getMessageCount(chatObjectId: chatId)`, upsert into `previewsBySpace`, emit `previewsStream.send(...)`, return the value. Errors from `getMessageCount` are intentionally swallowed — caller receives `nil` and gets a retry on the next invocation (e.g., next editor open).
- [ ] For task cleanup, mirror the existing `subscription?.cancel()` pattern in `deinit`. Do not invent new cancellation machinery; if in-flight bootstrap tasks don't cleanly fit the existing pattern, rely on the tasks completing naturally (each is a single RPC).

### Task 4: Wire bottom panel VM to the count  *(Part 1 — PR #1)*

Follow the `UnreadChatWidgetViewModel.startPreviewsSubscription()` precedent: a single long-lived `for await` — no cancel/restart on editor changes.

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeNavigationContainer/Panel/HomeBottomNavigationPanelViewModel.swift`

- [ ] Add `@ObservationIgnored @Injected(\.chatMessagesPreviewsStorage) private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol`.
- [ ] Add `var commentsCount: Int = 0` observable property.
- [ ] Add `@ObservationIgnored private var currentDiscussionId: String?` — latest resolved discussionId; read inside the loop.
- [ ] Add `private func subscribeOnCommentsCount() async` that iterates `chatMessagesPreviewsStorage.previewsSequence`, matches by `currentDiscussionId`, and assigns `commentsCount = preview.messageCount ?? 0` (or `0` when no current id / no matching preview). VM is `@MainActor` so assignments are already main-actor-safe.
- [ ] Add `async let commentsCountSub: () = subscribeOnCommentsCount()` to the `startSubscriptions()` group.
- [ ] In `updateState()`, when `discussionId` is present: set `currentDiscussionId = discussionId` and kick a detached bootstrap `Task { _ = await chatMessagesPreviewsStorage.messageCount(spaceId: editorData.spaceId, chatId: discussionId) }`. In the early-return branches (no editor data, no objectId, `DiscussionCoordinatorData`), set `currentDiscussionId = nil` and `commentsCount = 0`.

### Task 5: Morph `discussIsland` into circle↔capsule with inline counter  *(Part 2 — PR #2)*

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeNavigationContainer/Panel/HomeBottomNavigationPanelView.swift`

- [ ] Replace the inner of `discussIsland`'s button label with an `HStack(spacing: 3)` containing `Image(systemName: "message").frame(width: 48, height: 48)` — the icon's 48×48 region is the button core and does NOT grow — plus a conditional `Text("\(model.commentsCount)").padding(.trailing, 12)` when `model.commentsCount > 0`.
- [ ] Apply `.frame(height: 48)` on the HStack so the outer container is 48 tall in both states. Width is determined by content: 48 (just the icon region) when no counter, wider (icon region + gap + text + 12 trailing) when counter is shown.
- [ ] Swap the shape used by `contentShape(...)` and `glassEffectInteractiveIOS26(in: ...)` from `Circle()` to `Capsule()` when `commentsCount > 0`. Prefer a plain `if/else` over `AnyShape` — it avoids the type-erasure cost and lets SwiftUI animate the shape identity change more reliably. Grep existing `glassEffectInteractiveIOS26` callsites for a precedent before writing.
- [ ] Add `.animation(.default, value: model.commentsCount > 0)` so the shape morph is smooth, but keyed off the boolean (not the int) to avoid jitter when the count changes from e.g. 9 → 10.
- [ ] Match counter typography and colors against Figma node `11172-5099`. Text color: `Color.Control.primary` as a starting point. Confirm font with design-system-developer reference.
- [ ] Keep the plain `message` SF symbol (no `message.badge` — that is IOS-6028).
- [ ] Do NOT merge the unread-dot behavior from IOS-6028 task 2.2 here.

### Task 6: Replace loaded-count with backend count in `DiscussionViewModel`  *(Part 1 — PR #1)*

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionViewModel.swift`

- [ ] Add `@Injected(\.chatMessagesPreviewsStorage) @ObservationIgnored private var chatMessagesPreviewsStorage: any ChatMessagesPreviewsStorageProtocol`.
- [ ] Delete the `self.commentsCount = messages.count` assignment in `subscribeOnMessages()` (line 275).
- [ ] Add `private func subscribeOnCommentsCount() async` that iterates `chatMessagesPreviewsStorage.previewsSequence` and, on each emission, reads the current `self.chatId` (may be nil if no first comment yet), finds the matching preview, and assigns `commentsCount = preview.messageCount ?? 0`. If `chatId` is nil or no matching preview, `continue` (don't overwrite).
- [ ] Add it to the `startSubscriptions()` group as `async let commentsCountSub: () = subscribeOnCommentsCount()`.
- [ ] In `startSubscriptions()` **after** the group starts, if `chatId` is already non-nil at init time, kick a bootstrap `Task { _ = await chatMessagesPreviewsStorage.messageCount(spaceId: spaceId, chatId: chatId) }`.
- [ ] At the end of `createDiscussionIfNeeded(...)` (after `self.chatId = newChatId`), kick the same bootstrap call so the existing long-lived `subscribeOnCommentsCount()` task picks up the new chatId on the next `previewsSequence` emission.
- [ ] **Do not** relaunch `subscribeOnCommentsCount()` from `startDeferredSubscriptions()`. One long-lived iterator is enough — a second would race on `commentsCount` writes.

### Task 7: Final — acceptance + housekeeping  *(Part 2 — PR #2)*

- [ ] Manually verify the scenarios in the Testing Strategy section on both iOS 18 and iOS 26+ builds.
- [ ] Re-check counter `Text` typography and color against Figma (`node-id=11172-5099`) — adjust font and foreground style if off.
- [ ] Confirm no new warnings in Xcode.
- [ ] Delete this plan from `docs/plans/` into `docs/plans/completed/` on merge.

## Post-Completion

**Manual verification** (user performs in simulator — see Testing Strategy above for the full scenario list).

**Optional GO follow-up (non-blocking)**
- File a middleware ticket asking to add `messageCount: int32` to `Anytype_Rpc.Chat.SubscribeToMessagePreviews.Response.ChatPreview`. Rationale: mirrors the field already present on `SubscribeLastMessages.Response` and `GetMessages.Response`. Would let us delete the `chatService.getMessageCount(...)` bootstrap path in `ChatMessagesPreviewsStorage` once rolled out.

**Related tasks tracked elsewhere**
- IOS-6028 tasks 2.1/2.2 — **unread dot** on discuss button (different data source: `document.details?.unreadMessageCountValue`).
- IOS-6080 — filter replies out of the total count (blocked on backend API).
