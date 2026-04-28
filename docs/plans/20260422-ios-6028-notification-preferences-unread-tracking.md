# IOS-6028 — Notification Preferences & Unread Tracking for Object Discussions

Linear: [IOS-6028](https://linear.app/anytype/issue/IOS-6028)
Parent: IOS-5869 (Object Discussions, Waiting for testing)
Branch: `ios-6028-notification-preferences-unread-tracking-for-object` (already checked out)

---

## ⚠️ Execution Rules — Read Before Starting

This task is decomposed into **four sequential chunks**. Each chunk is **one PR**. Each chunk must be implemented in **its own session**.

- **Do NOT batch chunks in a single session**, even if one finishes with time to spare.
- After finishing a chunk: stage → commit (user confirms) → open PR → **stop and start a new session** for the next chunk.
- Session limits are a real constraint for this repo's size. Splitting sessions keeps each implementation clean and reviewable.
- **One commit per completed task.** After each Task's checkboxes all flip to `[x]`, commit (message: `IOS-6028 <Task title>`) before starting the next task. The chunk's PR ends up with one commit per task, which makes review incremental and rollback surgical.

---

## Overview

Object discussions on iOS currently have no notification preferences UI and no unread-state affordance. Users cannot control whether a given discussion pushes them every new reply vs only mentions, cannot tell at a glance that a document they're looking at has unread comments, and the aggregate surfaces (space hub unread section, space cards, pinned widgets, app icon badge) don't include objects with unread discussions the way they include chats.

This plan delivers the full loop across four chunks:

- **Chunk 1** (shipped) — in-object Notification Preferences submenu.
- **Chunk 2** (shipped) — in-object unread affordance: blue dot on Discuss button, open-at-first-unread.
- **Chunk 3** — aggregate unread surfaces, split into four independently shippable sub-chunks:
  - **3a Foundation** — `UnreadEntry` + `UnreadDecision` types, account-wide `ObjectsWithUnreadDiscussionsSubscription` actor (cross-space search on `layout == .discussion` with subscriber-aware filter, secondary `id IN backlinks` cross-space sub for parent details), login wiring, truth-table unit tests. **No consumers wired** (dormant infrastructure).
  - **3b Space Hub** — parent-object names on space card preview line + parent counts in space card totals.
  - **3c Inside-space (widget screen)** — parent rows in the Unread section + unread counters and `@` mention badge on pinned widgets (Favorites + list widgets).
  - **3d App icon badge** — parent-object contribution + refactor chat-mode switch onto `UnreadDecision`.
- **Chunk 4** — last-comment preview on object surfaces (sets/collections/list widgets). Source for preview text/creator/attachments still requires a per-discussion `subscribeLastMessages(limit: 1)` mechanism (deferred to Chunk 4's session).

Middleware dependencies (all merged on anyproto/anytype-heart):

**Consumed by this plan:**
- GO-7168 PR #3090 — `notificationSubscribers` relation + three RPCs (consumed by Chunk 1).
- GO-7168 PR #3107 — `unreadMessageCount` / `unreadMentionCount` bundled relations on chat object (`ot-discussion`).
- GO-7168 PR #3109 — forwards `unreadMessageCount` / `unreadMentionCount` from the discussion chat object onto its **parent object's local details**. Writes are triggered on every chat state change (add/delete, mark read/unread) via a per-discussion goroutine. Consumed by Chunks 2, 3, 4.

**Related but not consumed:**
- GO-7166 PR #3104 — `messageCount` response + `ChatUpdateMessageCount` event.

**Scope exclusion — reaction-heart indicator** for parent-object rows/widgets. Middleware PR #3109 does not forward `hasUnreadReactions`; we ship parity with chat rows minus that indicator.

## Context (from discovery)

**Files involved (Chunk 1, shipped):**
- `Modules/Services/Sources/Generated/BundledPropertyKey.swift`
- `Modules/Services/Sources/Generated/BundledPropertiesValueProvider.swift`
- `Modules/Services/Sources/Models/Details/BundledPropertyValueProvider+CustomProperties.swift`
- `Modules/Services/Sources/Services/Chat/ChatService.swift`
- `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionView.swift`
- `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionViewModel.swift`
- `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionNotificationMode.swift`
- `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/DiscussionNotificationsMenu.swift`
- `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/DiscussionHeaderView.swift`
- `Modules/Loc/Sources/Loc/Workspace.xcstrings` (+ generated `Strings.swift`)

**Files involved (Chunk 2):**
- `Anytype/Sources/PresentationLayer/Modules/HomeNavigationContainer/Panel/HomeBottomNavigationPanelViewModel.swift` (`subscribeToDetailsChanges` at lines 165–177; `updateState` at lines ~222–239; Discuss button wiring at lines 75–105 and 237).
- `Anytype/Sources/PresentationLayer/Modules/HomeNavigationContainer/Panel/HomeBottomNavigationPanelView.swift` (Discuss island around lines 96–106).
- `Anytype/Sources/PresentationLayer/Modules/Discussion/Services/DiscussionMessagesStorage.swift` (already branches on `oldestOrderID` at lines 108–124 — verify-only, no change).
- `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionViewModel.swift` (scroll logic at lines 277–290 — verify-only, no change).
- Push-tap handler — locate during implementation (candidates: `UserNotificationsCenter`, `NotificationsCenterService`, URL router).

**Files involved (Chunk 3a — Foundation):**
- New: `Anytype/Sources/ServiceLayer/ObjectsUnread/ObjectsWithUnreadDiscussionsSubscription.swift` — account-wide actor mirroring `ChatDetailsStorage` shape (actor + `Container.shared.*` Factory, started once in `LoginStateService`).
- New: `Anytype/Sources/ServiceLayer/ObjectsUnread/ObjectsWithUnreadDiscussionsSubscriptionBuilder.swift` — builds the primary `crossSpaceSearch` filter (`layout == .discussion AND ((unreadMentionCount > 0) OR (unreadMessageCount > 0 AND notificationSubscribers IN [myParticipantIds])))` plus the secondary `crossSpaceSearch` filter (`id IN backlinks`).
- New: `Anytype/Sources/ServiceLayer/ObjectsUnread/UnreadEntry.swift` and `.../UnreadDecision.swift` — sum type + 8-row truth-table helper, colocated.
- Modify: `Anytype/Sources/ServiceLayer/Auth/LoginStateService.swift:88–104` — call `objectsWithUnreadDiscussionsSubscription.startSubscription()` directly under `chatDetailsStorage.startSubscription()` (line 90). Symmetric stop in `stopSubscriptions`.
- New: `AnyTypeTests/ServiceLayer/ObjectsUnread/UnreadDecisionTests.swift` — 8 parent-row truth-table tests + 3 chat-mode parity tests.

**Files involved (Chunk 3b — Space Hub):**
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Helpers/SpaceHubSpacesStorage.swift` (`unreadPreviews` at lines 56–71; merge new sub with `chatMessagesPreviewsStorage.previewsSequence`).
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Subviews/SpaceCard/SpaceCardModelBuilder.swift` (`buildMultichatCompactPreview` at lines 101–120; `maxVisible = 3`).
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Helpers/SpacePreviewCountersBuilder.swift` (`build` at lines 43–102 — mode-aware per-space aggregation).

**Files involved (Chunk 3c — Inside-space surfaces):**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/HomeWidgetsViewModel.swift` (`startUnreadChatsTask` at lines 325–355 — extend to merge parent-object entries; rename concept from `unreadChats` to a row-data type that covers both chats and parent objects, or sibling-add a parallel pipeline).
- Modify or add sibling: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Unread/UnreadChatWidgetViewModel.swift` + `UnreadChatRowView.swift` + `UnreadChatsGroupedView.swift` (parent rows have a different data source — read from the new subscription, not `chatMessagesPreviewsStorage`).
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Builders/WidgetChatPreviewBuilder.swift` (adapter overload accepting parent-object entries).
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Builders/WidgetRowModelBuilder.swift` (`buildListRows` at lines 29–44; lookup at line 39 keyed by object id — parent objects fall back through to a parent-object preview).
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesViewModel.swift` + `MyFavoritesRowView.swift` (counter + `@` badge rendering; `hasVisibleCounters` at line 30 of row view).

**Files involved (Chunk 3d — App icon badge):**
- Modify: `Anytype/Sources/ServiceLayer/Badge/AppIconBadgeService.swift` (`updateBadge` at lines 63–97 — add parent-object aggregation, refactor existing chat switch through `UnreadDecision`, wire the new subscription's change stream into the badge re-fire trigger).

**Files involved (Chunk 4):**
- Modify: `Anytype/Sources/PresentationLayer/TextEditor/Set/Views/Models/SetContentViewDataBuilder.swift` (`buildChatPreview` at lines 288–319; `chatPreviewsDict` at line 129 — dict keyed by chatId).
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Builders/WidgetRowModelBuilder.swift` (line 39 — `previewsByChatId[config.id]` currently assumes id == chatId).
- New (deferred to Chunk 4 session): `Anytype/Sources/ServiceLayer/ObjectsUnread/DiscussionLastMessagesPool.swift` — id-pooled wrapper around `chatService.subscribeLastMessages(chatObjectId:, subId:, limit: 1)` for preview text/creator/attachments. The discussion's `lastMessageDate` relation alone is enough for sort (3a uses it directly); pool exists only to fetch the message *content*. Sized by Chunk 4's consumers — likely the same visibility-gate set 3a's primary already emits.

**Related patterns:**
- `NotificationModeMenu.swift` — 3-mode variant for space settings; not reused (Chunk 1 built a 2-option variant).
- `ChatMessageBuilder.swift:120–136` — unread-divider insertion (chat has a visible separator; discussion deliberately does not — open-at-first-unread is scroll-only).
- `ChatMessagesPreviewsStorage` (`actor`, account-wide, uses dedicated `chatService.subscribeToMessagePreviews` RPC + `EventBunchSubscribtion`) — emits `[ChatMessagePreview]` keyed by `(spaceId, chatId)`. Does **NOT** include `ot-discussion` chats — Chunks 3a and 4 do not depend on it for discussion data. Chunk 3a's `ObjectsWithUnreadDiscussionsSubscription` mirrors its `actor` + `Container.shared.*` Factory + `AsyncToManyStream` shape but uses generic `SubscriptionService.crossSpaceSearch` instead of the chat-specific RPC.
- `SpacePreviewCountersBuilder` — per-space unread aggregation (mode-aware). Chunk 3b extends with parent-object iteration.
- `SubscriptionService.crossSpaceSearch` — Chunk 3a uses two cross-space searches: primary on `layout == .discussion` with the visibility-aware filter, secondary on `id IN backlinks` for parent details. Both rebuilt via `subscriptionStorage.startOrUpdateSubscription(data:)` when their input set changes.
- `ChatDetailsSubscriptionBuilder:20–47` — existing `.chatDerived` layout filter built on `SubscriptionData.crossSpaceSearch`. Template for `ObjectsWithUnreadDiscussionsSubscriptionBuilder` (different layout + nested-OR filter on counts/subscribers).
- `ChatDetailsStorage:14–53` — existing actor pattern: `subscriptionStorage.startOrUpdateSubscription` → emits to `AsyncToManyStream<[ObjectDetails]>`. Template for the new subscription's lifecycle.
- `DiscussionMessageCountObserver:32–60` — single-id `chatSubscribeLastMessages(limit: 1)` observer with `EventBunchSubscribtion` event handling. Reference for Chunk 4's last-message-content path; **not used** in 3a (sort uses the `lastMessageDate` relation on the discussion object directly).
- `Anytype_Model_Block.Content.Dataview.Filter` (`Operator.or`/`.and`, `nestedFilters: [Filter]`, `Condition.in`) — middleware natively supports nested-OR filter trees. Used by `DataviewFilter+Condition.swift:42–54` recursively. Confirmed available for 3a's filter shape.
- `ParticipantsStorage` (account-wide, started at login in `LoginStateService:91`) — exposes `participantsSequence: AnyAsyncSequence<[Participant]>` across **all spaces** (each `Participant` carries `spaceId` + canonical participant object id). Chunk 3a reads the snapshot to build a `[spaceId: participantId]` map for `isSubscribed` checks. **No new subscription cost** — already running. Use `participants` (sync snapshot) or `participantsSequence` (live), not the per-space `participantSequence(spaceId:)` extension.
- `BundledPropertyKey.discussionId` and `BundledPropertyKey.chatId` — both already exist on parent details. `discussionId` is what parent → chat resolution uses (see `SpaceHubCoordinatorViewModel.swift:633–635`).

**Custom accessors already in place (Chunk 1):**
- `BundledPropertyValueProvider+CustomProperties.swift` — `unreadMessageCountValue: Int` and `unreadMentionCountValue: Int` with default-zero unwrap.

**Dependencies:**
- Middleware must contain PR #3109. Minimum tag: `v0.50.0-rc03`. The user bumps `Libraryfile` manually before the Chunk 2 session starts (Task 2.0 is a sanity check only).
- Middleware forwarding caveat: the per-discussion goroutine only runs when the chat smartblock is loaded on this device. For aggregate surfaces, the existing `ChatMessagesPreviewsStorage` subscription (which the app already starts on login) causes chat smartblocks to spin up; parent-object counters converge shortly after. No manual chat-open is required in practice, but freshly-synced devices may see a brief lag before counters populate.

## Development Approach

- **Testing approach: Minimal tests.** Only non-UI logic (service wrappers, subscription helpers if non-trivial) gets unit tests. SwiftUI views and menu wiring are not unit-tested in this repo. Matches existing `AnyTypeTests/` scope.
- Complete each chunk fully, open PR, **stop**.
- **Do NOT build the project after each task.** Builds take several minutes; the user builds locally once per chunk.
- Backwards compatibility is not a concern — the feature is gated by the existing `discussionButton` feature flag.

## Testing Strategy

- **Unit tests**: service wrappers and subscription helpers only if logic is non-trivial. Skip for view-only changes.
- **No e2e tests** exist in this repo; skip.
- **Manual verification** per chunk — see Post-Completion.

## Progress Tracking

- Mark completed items with `[x]` immediately when done.
- Add newly discovered tasks with ➕ prefix.
- Document blockers with ⚠️ prefix.
- Update plan if implementation deviates from scope.

## Technical Details

### Notification preference state (Chunk 1, shipped)

- Source of truth: `notificationSubscribers: [ObjectId]` on the chat object (middleware-maintained), stored as participant object IDs.
- Read: `details.notificationSubscribers.contains(participant.id)`.
- Write: `chatService.addNotificationSubscriber(chatObjectId:, identity: participant.identity)` — identity asymmetry documented in Chunk 1's post-review refinements section.

### In-object unread (Chunk 2)

- **Source**: parent object's bundled relations `unreadMessageCount` and `unreadMentionCount`, forwarded by middleware PR #3109 from the discussion chat object. Accessors already in place: `details.unreadMessageCountValue: Int`, `details.unreadMentionCountValue: Int`.
- **Discuss button blue dot**: `HomeBottomNavigationPanelViewModel` is already `@MainActor @Observable` and already subscribes to the current editor's document details via `subscribeToDetailsChanges(from:)` (lines 165–177), which iterates `document.detailsPublisher.values` and calls `updateState()` on every detail change. `updateState()` (lines ~222–239) already derives `showDiscussButton` from `document.details?.discussionId`. Add a sibling property `discussButtonHasUnread: Bool = (details?.unreadMessageCountValue ?? 0) > 0` in the same spot — no new subscription service, no probe work: `detailsPublisher.values` re-emits on arbitrary detail changes, so the dot refreshes in real time.
- **Icon rendering**: switch the SF Symbol between `message` and `message.badge`, applying `.symbolRenderingMode(.palette)` with two colors so the badge tints to `Color.Control.accent100` (design system's unread-blue per `DESIGN_SYSTEM_MAPPING.md:51`) while the bubble stays `Color.Control.primary`. The codebase already uses this palette pattern — see `DeleteIndicator.swift:10–14`. `message.badge` is available on iOS 17+ (the repo's minimum deployment target), so no fallback is needed.
- **Open-at-first-unread**: the scroll-to-first-unread logic already exists. `DiscussionMessagesStorage.swift:108–124` branches on `chatState.messages.oldestOrderID` and calls `loadPagesTo(orderId:)`; `DiscussionViewModel.swift:277–290` scrolls to the matching message. Task 2.3 is a verification pass — no divider, no visible separator; just confirm the scroll lands correctly. Preserve tail-scroll behavior when `oldestOrderID` is empty (already the case).
- **Push routing**: IOS-5838's unified deep-link pipeline already handles chat comment pushes. Probe once with a simulated push to confirm end-to-end; patch only if broken. Scope: patch in Chunk 2 if fix ≤10 lines; otherwise file a follow-up task and proceed without blocking Chunk 2.
- **Viewer permission parity**: Viewers see the blue dot (read-only doesn't hide unread state — only the Notifications menu is permission-gated, which was handled in Chunk 1).

### Aggregate surfaces (Chunk 3)

#### Architecture: account-wide subscription mirroring the chat path

The codebase has two account-wide chat subscriptions, both started once at login in `LoginStateService.startSubscriptions:88–96`:

| Storage | Mechanism | Output |
|---|---|---|
| `ChatDetailsStorage` (actor) | `SubscriptionService.crossSpaceSearch`, `.chatDerived` layout filter | `[ObjectDetails]` |
| `ChatMessagesPreviewsStorage` (actor) | Dedicated RPC `chatService.subscribeToMessagePreviews` + `EventBunchSubscribtion` | `[ChatMessagePreview]` keyed by `(spaceId, chatId)` |

Per-space surfaces (Space Hub cards, inside-space Unread section, widgets, badge) consume them by filtering on `spaceId`. Investigation confirmed that even the inside-space Unread section (`HomeWidgetsViewModel.startUnreadChatsTask:325–355`) reads the **account-wide** `chatMessagesPreviewsStorage.previewsSequenceWithEmpty` and filters by `spaceId == self.spaceId` — no per-space subscription anywhere.

Chunk 3a introduces a single account-wide `ObjectsWithUnreadDiscussionsSubscription` (actor, `Container.shared.*` Factory) that mirrors `ChatDetailsStorage`'s lifecycle 1:1 — same `subscriptionStorage` + `subscriptionStorageProvider`, same `AsyncToManyStream` output, same login-time start/stop. Per-space surfaces filter `entry.spaceId == self.spaceId`. **No per-space subscriptions, no aggregator layer** — convention parity with the chat path.

#### Subscription composition

```
ObjectsWithUnreadDiscussionsSubscription (actor, account-wide)
│
├── Primary — discussions visible to current user (cross-space)
│     filter: layout == .discussion AND (
│         unreadMentionCount > 0
│         OR (unreadMessageCount > 0 AND notificationSubscribers IN [myParticipantIds])
│     )
│     keys: id, spaceId, layout, backlinks,
│           lastMessageDate, notificationSubscribers,
│           unreadMessageCount, unreadMentionCount
│     → emits [ObjectDetails] (discussion chat objects)
│
├── Secondary id-diff — parent objects (cross-space, id-set filter)
│     filter: id IN (union of all backlink ids from primary)
│     keys: id, spaceId, name, iconImage, layout, discussionId
│     rebuilt via subscriptionStorage.startOrUpdateSubscription on set change
│     → snapshot map: parentId → ObjectDetails
│
├── ParticipantsStorage.participantsSequence (already running, account-wide)
│     drives BOTH the primary filter rebuild (when myParticipantIds set changes)
│     AND the per-emit isSubscribed lookup
│
└── combineLatest(primary, secondary, participants).removeDuplicates()
       → for each discussion in primary:
            parent = secondary.values.first { $0.discussionId == discussion.id }
            guard let parent else { skip — no usable parent → drop from UI }
            isSubscribed = discussion.notificationSubscribers
                              .contains(participants[parent.spaceId])
            spaceMuted = spaceViewsStorage.spaceView(spaceId: parent.spaceId)?
                              .pushNotificationMode == .nothing
            emit .parentObject(parent, isSubscribed:, spaceMuted:,
                               unreadMessageCount: discussion.unreadMessageCount,
                               unreadMentionCount: discussion.unreadMentionCount,
                               lastMessageDate: discussion.lastMessageDate)
       → emit [UnreadEntry.parentObject]
```

Three streams in `combineLatest` — within AsyncAlgorithms' supported arity (verified against existing usages at `HomeWidgetsViewModel.swift:334` and `AppIconBadgeService.swift:40`).

#### Filter shape (load-bearing)

Middleware-side filter pushed up so the subscription emits only renderable rows:

```
.and([
    layout == .discussion,
    .or([
        unreadMentionCount > 0,                                 // mentions always visible
        .and([
            unreadMessageCount > 0,
            notificationSubscribers .in [myParticipantIds]      // subscribed → counter row
        ])
    ])
])
```

Truth-table rows 3 and 7 (not subscribed AND no mention) are filtered server-side and never reach the client. Rows 1, 2, 4, 5, 6, 8 — the visible set — come through. `UnreadDecision.isVisible` is therefore guaranteed `true` for every emitted entry; the helper is still consulted for `unreadCounterVisible` / `mentionBadgeVisible` / `style` / `badgeContribution`.

`Anytype_Model_Block.Content.Dataview.Filter` natively supports `Operator.or` / `.and`, `nestedFilters: [Filter]`, and `Condition.in` (multi-value relation membership). Used elsewhere in the codebase (see `DataviewFilter+Condition.swift:42–54`).

#### Filter rebuild on participants change

`myParticipantIds` is the list of `Participant.id` values from `ParticipantsStorage.participants` — one per space the user is in. When the user joins/leaves a space, the list changes. The actor listens to `participantsSequence` and on each change calls `subscriptionStorage.startOrUpdateSubscription(data:)` with a freshly-built filter — middleware updates the active filter in place. Same idempotent pattern `ChatDetailsStorage` uses; no resubscribe ceremony.

#### Backlinks-based parent resolution

Discussion objects carry a `backlinks: [ObjectId]` relation listing every inbound reference (see `relations.json:1083–1093` — "List of links coming to object"). For our scope, the parent that embedded this discussion via `discussionId` is in that list (parent → discussion is what creates the link). Other inbound refs (mentions, attachments) may also be in `backlinks`, so we filter:

```
parent = secondary.values.first { $0.discussionId == discussion.id }
```

If no such parent exists in the secondary subscription's snapshot — orphaned discussion, parent deleted, or chat smartblock not yet loaded — we skip the entry. No standalone-discussion handling: discussions without a discoverable parent are out of scope for unread surfaces.

The secondary subscription's id set is `Set(primary.flatMap(\.backlinks))` — supersets of true parents (some refs are non-parents), but the cost of subscribing to non-parent refs is negligible (they're already loaded in the app for other reasons).

#### Last-message timestamp source

`lastMessageDate` (`relations.json:1830–1839`) is a `derived` relation on the chat object: "Date of the last message in a chat". Format `date`, populated by middleware on chat events (assumed reactive — confirmed in Task 3a.0 probe).

3a uses this directly for `UnreadEntry.lastUpdate` sort. No `DiscussionLastMessagesPool` needed in 3a.

Chunk 4 (last-comment preview *text*) is a separate concern — `lastMessageDate` is just the timestamp; preview content (text, creator, attachments) is not exposed as a relation on the chat object as of writing. Chunk 4 introduces its own per-discussion `subscribeLastMessages(limit: 1)` mechanism if needed; out of scope for 3a.

#### `ParticipantsStorage` for `isSubscribed` resolution

`notificationSubscribers` stores **participant object IDs** (Chunk 1 finding) — shape `_participant_<spaceId>_<identity>`. To check membership we need the current user's participant id per space.

`ParticipantsStorage` is **already account-wide and already running** (started at login in `LoginStateService:91`); its `participants: [Participant]` snapshot covers all spaces, each `Participant` carrying its own `spaceId` + canonical id. Chunk 3a uses it for two things:

1. **Filter input**: build `[myParticipantId per space]` list, pass into the primary filter's `notificationSubscribers .in […]` clause. Rebuild the filter when the set changes.
2. **Per-emit `isSubscribed` resolution**: at emit time, read `[spaceId: participantId]` from the snapshot and check `discussion.notificationSubscribers.contains(participants[parent.spaceId])` to populate the `isSubscribed` field on `UnreadEntry`.

Cost = snapshot reads + filter rebuild on set change. No new subscription.

Why not construct the id from `(spaceId, identity)` directly? The format is a middleware convention. Reading the canonical id from `Participant.id` is robust to format changes — same choice Chunk 1 made.

#### Entry type and decision helper

- **Entry type decision (load-bearing)**: introduce a sum type that carries raw state for both variants; interpretation lives in `UnreadDecision` (below), not on the entry:
  ```swift
  enum UnreadEntry {
      case chat(ChatMessagePreview, isSubscribed: Bool, spaceMuted: Bool)
      case parentObject(
          ObjectDetails,
          isSubscribed: Bool,
          spaceMuted: Bool,
          unreadMessageCount: Int,     // raw, unadjusted
          unreadMentionCount: Int,     // raw, unadjusted
          lastMessageDate: Date?
      )
      var id: String { ... }
      var name: String { ... }
      var spaceId: String { ... }
      var unreadCount: Int { ... }      // chat → preview.unreadCounter; parent → unreadMessageCount
      var mentionCount: Int { ... }     // chat → preview.mentionCounter; parent → unreadMentionCount
      var lastUpdate: Date { ... }
  }
  ```
  The symmetric `isSubscribed` / `spaceMuted` payload frees consumers from reading two sources of truth (entry vs `SpaceView.effectiveNotificationMode`). Per-discussion preferences do not apply to parent objects, so `spaceMuted` here is keyed by `spaceId`, not by chat id (cf. chat variant where `effectiveNotificationMode(for: chatId)` supports per-chat overrides — for chats, `spaceMuted` is derived with the chat-keyed API and frozen on the entry at construction time in `SpaceHubSpacesStorage`). Downstream renderers read the decision helper, not the raw booleans.
- **`lastUpdate` resolution for parent objects**: parent's own `lastModifiedDate` is the object body's modification time — NOT the discussion's last-message time. Source is the discussion's `lastMessageDate` relation (a `derived` field on the chat object, see `relations.json:1830–1839`), passed into `UnreadEntry.parentObject(..., lastMessageDate:)` from the primary subscription. Falls back to `details.lastModifiedDate` only if the discussion hasn't loaded its first emission yet — convergence is within one cross-space search round-trip.
- **Visibility + color rules for parent-object entries**. Two inputs combine to decide what each entry shows:
  - **`isSubscribed`** — is the current user in the discussion's `notificationSubscribers`? This tracks the per-discussion preference set via Chunk 1's menu ("All New Replies" = subscribed, "Mentions Only" = not subscribed). `notificationSubscribers` lives on the discussion's chat object, not forwarded to the parent by PR #3109 — the client must resolve it (see "Subscription plumbing" below).
  - **`spaceMuted`** — is the space's `pushNotificationMode` == `.nothing`?
  
  From those two, derive:
  - **Entry visibility**: `(isSubscribed && unreadMessageCount > 0) || unreadMentionCount > 0`. Not subscribed + no mention → hidden. Everyone else → visible.
  - **Unread counter visibility**: `isSubscribed && unreadMessageCount > 0`. Not subscribed → counter never shown (regardless of how many unread messages exist — the user opted out).
  - **Mention `@` badge visibility**: `unreadMentionCount > 0`. Mentions always surface.
  - **Color**: `spaceMuted` → grey (muted style). Otherwise → blue (highlighted style). Per-discussion subscription state does NOT change color.

  The full truth table (each parent row with `unreadMessageCount > 0`):

  | # | Muted | Subscribed | mention | Visible? | Unread counter | `@` badge | Color |
  |---|-------|-----------|---------|----------|----------------|----------|-------|
  | 1 | no | yes | 0 | ✅ | visible | — | blue |
  | 2 | no | yes | >0 | ✅ | visible | visible | blue |
  | 3 | no | no | 0 | ❌ | — | — | — |
  | 4 | no | no | >0 | ✅ | hidden | visible | blue |
  | 5 | yes | yes | 0 | ✅ | visible | — | grey |
  | 6 | yes | yes | >0 | ✅ | visible | visible | grey |
  | 7 | yes | no | 0 | ❌ | — | — | — |
  | 8 | yes | no | >0 | ✅ | hidden | visible | grey |

- **Badge double-count prevention**: `ChatMessagesPreviewsStorage` filters by `.chatDerived` layout (not `.discussion`), so discussion chat objects should not appear in the chat preview list. Confirm during Task 3d.1 with a one-line probe log; remove the log before commit. If they do appear, de-dup by skipping chat entries whose chatId equals some parent's `discussionId`.

- **Implementation approach — `UnreadDecision` helper**. The subscription emits `UnreadEntry.parentObject(...)` carrying **raw** values: `unreadMessageCount`, `unreadMentionCount`, `isSubscribed`, `spaceMuted`, `lastMessageDate`. No source-side zeroing; no mode coercion; no presentation-layer flag. A single helper encodes the 8-case truth table and every consumer calls it:
  ```swift
  struct UnreadDecision {
      enum Style { case blue, grey }
      let isVisible: Bool
      let unreadCounterVisible: Bool
      let mentionBadgeVisible: Bool
      let style: Style
      let badgeContribution: Int   // what this entry contributes to the app icon badge total

      static func decide(for entry: UnreadEntry, supportsMentions: Bool) -> UnreadDecision
  }
  ```
  `decide(for:supportsMentions:)` handles both variants: for `.chat(preview)` it reproduces the existing `SpacePreviewCountersBuilder` / `AppIconBadgeService` mode switch verbatim so chat behavior is preserved bit-for-bit; for `.parentObject(...)` it encodes the 8 rows directly. Consumers:
  - **3b** Space Hub Unread section: drop entries with `!decision.isVisible`; style each row via `decision.style`.
  - **3b** Space card counters: accumulate `decision.unreadCounterVisible ? entry.unreadCount : 0` + `decision.mentionBadgeVisible ? entry.mentionCount : 0`.
  - **3c** Inside-space Unread rows + pinned widget rows: populate `MessagePreviewModel` using the decision fields — no `isParentObjectEntry` flag on `MessagePreviewModel`, no tweak to `MessagePreviewModel+Presentation`.
  - **3d** App icon badge: accumulate `decision.badgeContribution` — one line, no per-case branching at the call site.

  The helper is the only place the truth table lives. Unit tests (3a) cover 8 parent rows + the chat-mode cases.

- **Surface-by-surface notes** (per sub-chunk):
  - **3b Space Hub Unread section** (`SpaceHubSpacesStorage.unreadPreviews:56–71`): merge the new sub's stream with `chatMessagesPreviewsStorage.previewsSequence` into `[UnreadEntry]`, filter via `UnreadDecision.decide(...).isVisible`, sort by `lastUpdate`. Coalesce same-frame emissions with `debounce(for: .milliseconds(16), scheduler: DispatchQueue.main)` — one runloop tick, not user-visible. `debounce` not `throttle` because we want the merged snapshot, not a dropped intermediate.
  - **3b Space card preview names** (`SpaceCardModelBuilder.buildMultichatCompactPreview:101–120`): `entry.name` is uniform across variants. Existing `maxVisible = 3` + " +N" tail unchanged.
  - **3b Space card aggregate count** (`SpacePreviewCountersBuilder.build:43–102`): iterate `[UnreadEntry]`, accumulate via `decision.unreadCounterVisible ? entry.unreadCount : 0` and `decision.mentionBadgeVisible ? entry.mentionCount : 0`. Existing chat mode-switch collapses into the helper.
  - **3c Inside-space Unread section** (`HomeWidgetsViewModel.startUnreadChatsTask:325–355`): currently emits `[UnreadChatWidgetData]`. Extend (or sibling-add) so the section can render parent-object rows alongside chats. Decide between extending `UnreadChatWidgetViewModel` or sibling-adding `UnreadObjectWidgetViewModel` during 3c — sibling preferred because the parent-row data source is the new subscription, not `chatMessagesPreviewsStorage`.
  - **3c Pinned widgets** (Favorites + list widgets): in-app home widgets driven by `HomeWidgetsViewModel`, NOT iOS WidgetKit extensions. Extend `WidgetChatPreviewBuilder.build(...)` with a parent-object overload producing the same `MessagePreviewModel` shape. `hasUnreadReactions = false` always. `MyFavoritesRowView:30` renders badges from `hasVisibleCounters` unchanged. `WidgetRowModelBuilder.buildListRows:29–44` falls back to a parent-object preview when `previewsByChatId[config.id]` misses; `ListWidgetRow:22–26` renders automatically when `model.chatPreview` is non-nil.
  - **3d App icon badge** (`AppIconBadgeService.updateBadge:63–97`): one parallel loop over parent-object entries, `total += decision.badgeContribution`. Refactor existing chat switch (lines 81–91) onto the same helper — `decide(for: .chat(...), supportsMentions:).badgeContribution` reproduces today's behavior verbatim. **Critical**: wire the new subscription's change stream into the existing badge re-fire trigger (probe current trigger during 3d) — otherwise the badge is stale when parent-only unread arrives.
- **Badge double-count prevention**: `ChatMessagesPreviewsStorage` filters by `.chatDerived`, so discussion chat objects should not appear in the chat preview list. Confirm during 3d with a one-line probe log; remove probe before commit. If they do appear, de-dup by skipping chat entries whose chatId equals some parent's `discussionId`.
- **Collapsed-vs-expanded Unread section**: the existing `shouldHideChatBadges` environment flag already gates double-count suppression. Parent-object badges flow through unchanged.
- **Viewer permission parity**: Viewers see aggregate unread surfaces exactly like Editors/Owners — unread state is read-only information, not permission-gated.

### Last-comment preview (Chunk 4)

- **Source**: discussions are NOT in `chatService.subscribeToMessagePreviews` (confirmed during 3a design). `lastMessageDate` is on the discussion object as a relation, but `lastMessageText` / `lastMessageCreator` / attachments are NOT (as of writing). Chunk 4 introduces a per-discussion `subscribeLastMessages(limit: 1)` mechanism — a small ServiceLayer pool actor (`DiscussionLastMessagesPool`) sized to the set of discussions Chunk 4's surfaces actually want to render.
- **Pool gate decision**: Chunk 4 surfaces are set/collection cells + list-widget rows — they render whatever parent objects appear in those collections, regardless of unread state. So the pool's gate is **not** the visibility filter from 3a. Options to settle in Chunk 4's session: (a) gate by "any parent object with a non-empty `discussionId` in the visible viewport"; (b) just use the visibility-filtered set from 3a's primary subscription and accept "no preview when fully read" as the product behavior; (c) ask middleware to expose `lastMessageText` as a relation and skip the pool entirely.
- **Adapter**: `DiscussionLastMessagesPool` snapshot returns `[chatId: ChatMessage]` (or a richer info struct). Build a small adapter into the cell-side preview shape used by `SetContentViewDataBuilder.buildChatPreview:288–319` and `WidgetChatPreviewBuilder` — same renderers, just a different data source.
- **Surfaces enabled**: Set/Collection gallery + list cells; widget list rows.
- **Surfaces intentionally untouched**: widget gallery layouts; MyFavorites widget (badges only by design); Space Card preview line (names only).

## What Goes Where

- **Implementation Steps** below contain all in-codebase tasks.
- **Post-Completion** lists manual verification that happens outside the diff.

---

## Implementation Steps

### 🟦 Chunk 1 — PR #1: Notification preferences menu

> Shipped on PR #4863. Post-review refinements (below) are the final shape for later chunks to build on.

### Task 1.1: Add bundled property keys for unread + subscribers

**Files:**
- Modify: the bundled-properties generator source (Sourcery stencil / relation source list — see `Modules/AnytypeCore/CODE_GENERATION_GUIDE.md` for exact path; do NOT edit `Generated/BundledPropertyKey.swift` directly, it will be overwritten)
- Regenerated (do not hand-edit): `Modules/Services/Sources/Generated/BundledPropertyKey.swift`, `Modules/Services/Sources/Generated/BundledPropertiesValueProvider.swift`
- Modify if needed: `Modules/Services/Sources/Models/Details/BundledPropertyValueProvider+CustomProperties.swift` (only if accessors need custom typing)

- [x] Follow `CODE_GENERATION_GUIDE.md` to add cases `notificationSubscribers`, `unreadMessageCount`, `unreadMentionCount` in the source (not the generated file). — already present in `Dependencies/Middleware/json/relations.json` (middleware-provided); no source change needed.
- [x] Run `make generate`. — executed; Services generation runs in Xcode build phases (swiftgen.yml at `Modules/Services/swiftgen.yml`), no file churn.
- [x] Confirm generated accessors exist on `BundledPropertyValueProvider` (`unreadMessageCountValue: Int64?`, `unreadMentionCountValue: Int64?`, `notificationSubscribersValue: [String]?` or equivalent). — verified: `notificationSubscribers: [ObjectId]` (ObjectId = String), `unreadMessageCount: Int?`, `unreadMentionCount: Int?`.
- [x] Add custom accessor in `BundledPropertyValueProvider+CustomProperties.swift` only if generated types need unwrapping (e.g., default-zero integer accessor). — added `unreadMessageCountValue: Int` and `unreadMentionCountValue: Int` with default-zero unwrap.
- [x] No unit tests for generated code.

### Task 1.2: Wire up Chat notification subscriber RPCs in ChatService

**Files:**
- Modify: `Modules/Services/Sources/Services/Chat/ChatService.swift` (verify exact path)
- Modify: protocol definition for `ChatServiceProtocol`
- Create/Modify: `Modules/Services/Tests/ChatServiceTests.swift` (if a test file exists)

- [x] Add protocol methods:
  - `func addNotificationSubscriber(chatObjectId: String, identity: String) async throws`
  - `func removeNotificationSubscriber(chatObjectId: String, identity: String) async throws`
  - **Do NOT add `getNotificationSubscribers`.** Current mode is derived from the object-details subscription (Task 1.4); a getter would be dead code.
- [x] Implement by wrapping `ClientCommands.chatAddNotificationSubscriber` / `chatRemoveNotificationSubscriber`.
- [x] ~~Write a minimal unit test for each new method if there's an existing `ChatServiceTests` fixture — happy path + error propagation only.~~ (no fixture exists)
- [x] No tests if repository has no existing ChatService test file (follow "minimal tests" decision).

### Task 1.3: Build DiscussionNotificationsMenu view

**Files:**
- Create: `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/DiscussionNotificationsMenu.swift`

- [x] Two-option menu (SwiftUI `Menu`) with items "All New Replies" and "Mentions Only".
- [x] Checkmark (`Image(systemName: "checkmark")`) on the currently-active option.
- [x] Parent label: `Label { Text(Loc.Discussion.Notifications.title) } icon: { Image(systemName: "bell") }` — match `NotificationModeMenu.swift` visual style.
- [x] Async callback `onModeChange: (DiscussionNotificationMode) async -> Void` where `DiscussionNotificationMode` is a local 2-case enum.
- [x] No tests — SwiftUI view only.

### Task 1.4: Surface Notifications menu in discussion 3-dot menu + wire to ViewModel

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionViewModel.swift`

- [x] Locate existing 3-dot menu in `DiscussionView.swift` (grep for "ellipsis" or `Menu` in that file). — found in both `ios26Content` toolbar trailing item and `legacyContent` via `DiscussionHeaderView.moreButton`.
- [x] Add `DiscussionNotificationsMenu` entry to the menu, bound to `viewModel.notificationMode` and `viewModel.toggleNotificationMode`. — inserted as the first item in both ios26 and legacy menus.
- [x] In `DiscussionViewModel`:
  - Publish `@Published var notificationMode: DiscussionNotificationMode = .mentionsOnly` (default while loading). — added as `@Observable` var (model is `@Observable`).
  - Subscribe to the chat object's details via `chatObject.detailsPublisher.values`. React to `notificationSubscribers` changes and update `notificationMode` based on current-user identity membership.
  - `func toggleNotificationMode(_ newMode: DiscussionNotificationMode) async` — calls `chatService.addNotificationSubscriber` or `removeNotificationSubscriber` with chatId + current identity. No-op when chatId or identity are missing. Errors handled via `anytypeAssertionFailure` + toast.
- [x] Resolve current user identity via `accountManager.account.id` (injected `AccountManagerProtocol`). `SpaceNotificationsSettingsViewModel` uses the workspace-mode path, so we followed the `accountManager` injection pattern already used by other VMs (e.g., `ProfileQRCodeViewModel`).
- [x] No tests for view/VM wiring.

### Task 1.5: Hide Notifications menu for Viewers

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionView.swift`

- [x] Reuse the existing edit-permission flag on `DiscussionViewModel` if one is already exposed (look for `canEdit` / `canWrite` / `canSendMessages` — whatever already gates message send and delete). Only add a new `@Published` flag if no suitable one exists. — reused `canEdit` (line 81, set in `subscribeOnPermissions`; already gates message input panel at `DiscussionView.bottomPanel`).
- [x] In `DiscussionView.swift`, conditionally include the `DiscussionNotificationsMenu` only when that flag is true. — gated in both ios26 toolbar menu (inside `Menu { if model.canEdit { ... } }`) and legacy path via new `canEdit` parameter on `DiscussionHeaderView`.
- [x] Manual verification (Post-Completion) covers the permission behavior. (manual test — covered in Post-Completion)

### Task 1.6: Add localization strings for the menu

**Files:**
- Modify: `Modules/Loc/Sources/Loc/en.xcstrings` (+ pl/ru/... per 3-file workflow in LOCALIZATION_GUIDE.md)
- Modify generated: `Modules/Loc/Sources/Loc/Generated/Strings.swift` (via `make generate`)

- [x] Add keys:
  - ~~`Discussion.Notifications.title` → "Notifications"~~ — **removed during review** (see Post-review refinements below); the menu parent label reuses the existing `Loc.notifications` key.
  - `Discussion.Notifications.allNewReplies` → "All New Replies"
  - `Discussion.Notifications.mentionsOnly` → "Mentions Only"
- [x] Follow the 3-file workflow exactly (LOCALIZATION_GUIDE.md). — added to `Workspace.xcstrings` (the file already hosting the existing `Discussion.Header.Comments` key) with all 24 locales seeded per the existing pattern (English `translated`, others `new`).
- [x] Run `make generate`; confirm the final two `Loc.Discussion.Notifications.*` constants compile. — regenerated `Modules/Loc/Sources/Loc/Generated/Strings.swift`; `allNewReplies` and `mentionsOnly` present.

### Task 1.7: Hand off to user for build + manual verification

- [x] Do NOT build from the agent; user builds locally.
- [x] Summarize changes to the user so they can verify in Xcode + simulator (Owner account): open a discussion → 3-dot menu → Notifications submenu shows both options with correct checkmark; toggling flips the checkmark; menu hidden for a Viewer test account.
- [x] Stage + commit only if the user explicitly asks. (chunk commits made inline per task prompts)
- [x] **STOP. Open PR. Start Chunk 2 in a new session.** (handoff — reviews run now, PR opening deferred to user)

### Post-review refinements (Chunk 1)

These adjustments came out of Codex/ClaudeBot review on PR #4863 — they supersede the original Task 1.4 sub-bullets and are the final shape for Chunk 2 to build on.

- **Identity model** — `notificationSubscribers` is declared `"objectTypes": ["participant"]` in `Dependencies/Middleware/json/relations.json`, so middleware stores **participant object IDs** there (e.g. `_participant_<spaceId>_<identity>`), not raw identity strings. The RPC write side still takes a raw identity (`Anytype_Rpc.Chat.AddNotificationSubscriber.Request.identity`) — middleware resolves it internally. This asymmetry mirrors `workspaceService.participantRemove(..., identity:)` and friends.
  - Read compare: `details.notificationSubscribers.contains(participant.id)`
  - Write: `chatService.addNotificationSubscriber(chatObjectId:, identity: participant.identity)`
  - **Do not** use `accountManager.account.id` for the read compare — that's the raw identity and the check silently always returns false.

- **Source of the participant** — `accountParticipantsStorage.participantSequence(spaceId:)` (returns `AnyAsyncSequence<Participant>`). It is backed by `AsyncToManyStream`, which replays `lastValue` on subscribe, so `.first(where: { _ in true })` serves as both fast-path and cold-launch fallback. Later chunks should use the same source if they need current-user participant info.

- **Subscription shape in `subscribeOnNotificationMode`** — `combineLatest(subscribersSequence, participantIdSequence)`, each with `.removeDuplicates()`, mirroring the `subscribeOnPermissions` pattern in the same file. Correctness is self-evident from the call site without depending on `subscribeFor`'s replay semantics. The body also guards `if notificationMode != newMode` before assigning, to avoid @Observable no-op invalidations when unrelated subscribers change.

- **Deferred subscription rebind** — for the first-comment creation path, `subscribeOnNotificationMode` is re-invoked from `startDeferredSubscriptions()` after `createDiscussionIfNeeded` assigns `chatObject`. The initial `startSubscriptions()` call exits early (`guard let chatObject else { return }`) when `chatId` was nil at init.

- **Error handling** — the `anytypeAssertionFailure` the original plan suggested for RPC errors was removed; network failures only surface a `ToastBarData` failure toast. Matches the `sendMessageTask` pattern.

- **Layer split** — `DiscussionNotificationMode` lives in its own file (`Modules/Discussion/DiscussionNotificationMode.swift`) alongside the ViewModel, not inside the Menu view. The localized `title` extension travels with the enum.

- **Loc keys** — `Discussion.Notifications.title` was added and then removed during review; the menu parent label reuses the existing `Loc.notifications` key. Only `Discussion.Notifications.allNewReplies` and `Discussion.Notifications.mentionsOnly` were added.

---

### 🟩 Chunk 2 — PR #2: In-object unread affordance

> **Single-session scope.** Do NOT start this in the same session as Chunks 3 or 4. Begin a new session after Chunk 1's PR merges.

### Task 2.0: Confirm middleware prerequisite

> **Prerequisite handled by the user before the session starts.** The `Libraryfile` is bumped to a tag containing `anyproto/anytype-heart` PR #3109. The session does not touch `Libraryfile` or run `make setup-middle`.

- [x] Sanity-check: `BundledPropertyValueProvider` exposes `unreadMessageCountValue: Int` and `unreadMentionCountValue: Int` (added in Chunk 1). If either is missing, stop — the middleware bump didn't land. — ➕ deviation: custom `*Value` helpers were removed during Chunk 1 review (commit 1a6cce45); generated `unreadMessageCount: Int?` / `unreadMentionCount: Int?` are present, so the middleware bump is fine. Call sites inline the `?? 0` unwrap instead of reintroducing the helper.
- [x] Tests: N/A — prerequisite verification only.
- [x] No commit for this task — sanity check produces no diff.

### Task 2.1: Publish `discussButtonHasUnread` from the bottom navigation panel VM

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeNavigationContainer/Panel/HomeBottomNavigationPanelViewModel.swift`

- [x] The VM is already `@MainActor @Observable` and already subscribes to the current editor's document details via `subscribeToDetailsChanges(from:)` (lines 165–177), which iterates `document.detailsPublisher.values` and calls `updateState()` on every emission. `updateState()` (lines ~222–239) already derives `showDiscussButton` from `document.details?.discussionId`. We piggy-back on this.
- [x] Add observable stored property: `var discussButtonHasUnread: Bool = false`.
- [x] In `updateState()`, alongside the existing `hasDiscussion` line, compute `discussButtonHasUnread = (document.details?.unreadMessageCount ?? 0) > 0`. — inlined `?? 0` because the `*Value` helper was removed in Chunk 1 review.
- [x] **Reset in all early-return paths** so the dot never persists across object switches:
  - `guard let participantSpaceView else { ... }` branch → `discussButtonHasUnread = false` before returning.
  - `DiscussionCoordinatorData` branch → flag left stale; inline comment extends the existing hidden-panel invariant note.
  - "no editor data / no objectId" branch → `discussButtonHasUnread = false` before returning.
- [x] No new subscription — `detailsPublisher.values` already re-emits on arbitrary detail changes, so the dot refreshes in real time as comments arrive.
- [x] Tests: N/A — view-model wiring on an existing subscription.
- [x] Commit as `IOS-6028 Publish discussButtonHasUnread from bottom nav VM`.

### Task 2.2: Render blue-dot indicator on the Discuss button

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeNavigationContainer/Panel/HomeBottomNavigationPanelView.swift`

- [x] In `discussIsland` (lines ~96–106), switch the SF symbol and apply palette tinting:
  ```swift
  Image(systemName: model.discussButtonHasUnread ? "message.badge" : "message")
      .symbolRenderingMode(.palette)
      .foregroundStyle(Color.Control.primary, Color.Control.accent100)
  ```
- [x] Palette mode stacks two colors — first tints the bubble, second tints the badge dot. Pattern precedent: `DeleteIndicator.swift:10–14`. `message.badge` is available on iOS 17 (repo's minimum deployment target) — no fallback needed.
- [x] Verify `Color.Control.accent100` still exists — confirmed via `Modules/Assets/Sources/Assets/Generated/Color+Assets.swift:177`.
- [x] Keep the frame (48×48) and `contentShape(Circle())` unchanged.
- [x] Preview both states if a preview file for this view exists. — no preview file for this view.
- [x] Tests: N/A — SwiftUI view.
- [x] Commit as `IOS-6028 Render unread blue dot on Discuss button`.

### Task 2.3: Open-at-first-unread scroll (verification deferred to user)

**Files:** (read-only reference)
- `Anytype/Sources/PresentationLayer/Modules/Discussion/Services/DiscussionMessagesStorage.swift` (lines 108–124)
- `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionViewModel.swift` (lines 277–290)

- [x] Expected behavior: opening a discussion with unread messages lands on the first unread with `.center` scroll position via the existing branch on `chatState.messages.oldestOrderID`. Tail-scroll when `oldestOrderID` is empty.
- [x] No unread divider — per design, we only scroll; we do not insert any visible separator.
- [x] Reading-level sanity check: `DiscussionMessagesStorage.swift:108–124` branches on `chatState.messages.oldestOrderID` and calls `loadPagesTo(orderId:)`; `DiscussionViewModel.swift:277–290` scrolls `.center` to matching oldest-unread message or `.bottom` to last. Both intact; Chunk 2 did not touch these files.
- [x] **User manually verifies this scenario on-device during the Chunk 2 hand-off (Task 2.5).** If broken, user files a note and we fix in-place; otherwise this task is a no-op.
- [x] Tests: N/A — verification only.
- [x] No commit for this task — zero-diff verification. If the sanity check triggers an actual fix, commit that fix as a fresh task.

### Task 2.4: Push notification tap routing (manual check by user)

**Files:** (read-only reference)
- `Anytype/Sources/PresentationLayer/Flows/SpaceHub/SpaceHubCoordinatorViewModel.swift` — `handleChatMessageDeepLink(chatObjectId:spaceId:messageId:)` at lines ~620–680. Pre-located: this is IOS-5838's central handler and it already branches on `details.editorViewType == .discussion || details.discussionId.isNotEmpty` (line 632) to push a `DiscussionCoordinatorData` with the `messageId` payload. Discussion pushes route through this single point.

- [x] Agent action is limited to spot-reading `SpaceHubCoordinatorViewModel:620–680` to confirm the discussion branch still compiles and the `messageId` is passed into `DiscussionCoordinatorData`. — ➕ confirmed: `handleChatMessageDeepLink` at lines 620–694, discussion branch at line 633 (`details.editorViewType == .discussion || details.discussionId.isNotEmpty`) resolves `discussionId` and pushes `DiscussionCoordinatorData(..., messageId: messageId)` in all three sub-paths (existing-in-path replace at 651, standalone at 666, object+discussion at 682).
- [x] **User manually verifies during the Chunk 2 hand-off (Task 2.5)**: copy a deeplink to a comment from another client (web/macOS/Android) or trigger a real push, tap it in iOS, and confirm against these explicit pass criteria:
  1. Space opens correctly.
  2. Parent object opens correctly.
  3. Discussion screen pushes on top.
  4. Scrolls to the referenced comment (message-id-specific landing).
  - If criteria 1–3 pass but criterion 4 fails, treat it as a **partial pass** — Chunk 2 still ships (unread-dot + first-unread scroll are the scope); criterion 4 becomes a Chunk 2 follow-up task scoped to `messageId` plumbing, not a Chunk 2 blocker.
  - If criterion 1, 2, or 3 fails, Chunk 2 is blocked until fixed.
- [x] If user reports any of 1–3 broken, agent diagnoses and patches in-place when the fix is ≤10 lines; otherwise files a separate Linear task and ships Chunk 2 without the patch.
- [x] Tests: N/A — not simulable from the agent; pass/fail decided by user verification.
- [x] Commit as `IOS-6028 Verify discussion push routing handler` (even if no code changes — the ➕ note is the artifact; use `--allow-empty` if the sanity check produced zero diff).

### Task 2.5: Hand off to user for build + manual verification

- [x] Do NOT build from the agent; user builds locally.
- [x] Scenarios: receive a new comment → blue dot on Discuss button; open discussion with unread → lands on first unread (no visible divider, scroll-only); open discussion fully read → lands at bottom; tap discussion push → correct deep-link (pass criteria per Task 2.4).
- [x] Stage + commit only if user explicitly asks.
- [x] Tests: N/A — hand-off task.
- [x] No commit for this task.
- [x] **STOP. Open PR. Start Chunk 3 in a new session.** — PR #4876 to `release` opened.

---

### 🟦 Chunk 3 — Aggregate unread surfaces (split into 3a / 3b / 3c / 3d)

> **Each sub-chunk is its own session and its own PR.** Do not batch. Begin a new session after the prior sub-chunk's PR opens.
>
> **Rollback / kill-switch**: every consumer added in 3b/3c/3d sits behind `FeatureFlags.discussionButton`. Disabling the flag must reproduce pre-Chunk-3 behavior bit-for-bit. The 3a foundation has no consumers; it is dormant until 3b lands. Document the flag check inline at each injection point (one-liner) so the rollback path is legible.
>
> **Reaction heart indicator** is out of scope — middleware does not forward `hasUnreadReactions` to the parent object. We ship parity with chat rows minus that indicator.

---

### 🟦 Chunk 3a — PR: Foundation (subscription + types + tests)

> **Single-session scope.** No consumers wired — this chunk lands dormant. 3b/3c/3d are independent PRs that consume what 3a introduces.

### Task 3a.1: Add `UnreadBadge` + `ParentObjectUnreadEntry` + builder

**Files (delivered):**
- `Anytype/Sources/ServiceLayer/ObjectsUnread/UnreadBadge.swift`
- `Anytype/Sources/ServiceLayer/ObjectsUnread/ParentObjectUnreadEntry.swift`
- `Anytype/Sources/ServiceLayer/ObjectsUnread/ParentObjectUnreadEntryBuilder.swift`

➕ **Design shifted during implementation** from the original `UnreadEntry`/`UnreadDecision` enum. Final decisions:
- **Scope**: parent-object only. Chat surfaces stay untouched in 3a — no enum, no chat-side migration. When 3b.1 needs a unified merged list, introduce a protocol or wrapper there.
- **Names**: `BadgeDecision`/`UnreadDecision` → `UnreadBadge` (it's data, not a decision). `UnreadEntry` → `ParentObjectUnreadEntry` (parent-only).
- **Mention shape**: `hasMention: Bool`, no count and no style. Mention indicator is always blue on parent objects; the count is never rendered as a number anywhere on the unread surfaces (verified against `MentionBadge.swift` — view shows only `@`).
- **App-icon contribution**: only blue unread counter contributes (`appIconContribution` on `UnreadBadge`). Parent-mention rows never bump the app icon — deviation from plan literal (was `unreadMentionCount` for rows 4/8) — aligns with what's actually rendered in UI.
- **Decision place**: extracted to `ParentObjectUnreadEntryBuilder.makeEntry(discussion:parent:myParticipantId:spaceMuted:)`. Pure helper; returns `nil` for filtered rows (3 and 7). The 8-row truth table is encoded in one place; 3a.3 just calls it.

- [x] `UnreadBadge` defined: `Style` + `UnreadCounter?` + `hasMention: Bool` + computed `appIconContribution`.
- [x] `ParentObjectUnreadEntry` defined: `details + lastMessageDate + badge` with computed `id/spaceId/name/lastUpdate/unreadCount/hasMention`.
- [x] `ParentObjectUnreadEntryBuilder.makeEntry(...)` defined — pure static helper.
- [x] No DI — all types are value types / pure helpers.
- [x] Tests: covered in Task 3a.4.
- [x] Commit as `IOS-6028 Add UnreadBadge, ParentObjectUnreadEntry, builder + tests`.

### Task 3a.0: Probe filter shape and `lastMessageDate` reactivity

> **No code changes — verification only.** Recorded as ➕ note before 3a.2 starts.

- [x] Logged discussion-object details on a dev account. — ➕ user verified: `lastMessageDate`, `notificationSubscribers`, `backlinks` all present and behave as expected.
- [x] Sent a new message and watched `lastMessageDate` update. — ➕ confirmed reactive.
- [x] Tried the nested-OR `crossSpaceSearch` filter shape. — ➕ middleware accepts the request.
- [x] Tests: N/A.
- [x] No commit (probe only).

### Task 3a.2: Add `ObjectsWithUnreadDiscussionsSubscriptionBuilder`

**Files (delivered):**
- `Anytype/Sources/ServiceLayer/ObjectsUnread/ObjectsWithUnreadDiscussionsSubscriptionBuilder.swift`

➕ **Design shifted during implementation** — collapsed primary/secondary into one builder method. Final shape:
- **Single subscription**: protocol exposes `subscriptionId` and `build(myParticipantIds:)` only. No primary/secondary split, no `buildSecondary`.
- **Filter shape**: top-level `OR` of two `AND` branches —
  - parent branch: `layout IN [editor + list layouts]` AND `OR(unreadMessageCount > 0, unreadMentionCount > 0)` — every parent with any unread counter.
  - discussion branch: `layout IN [.discussion]` AND `notificationSubscribers IN [myParticipantIds]` — discussions where I'm subscribed.
- **Why one query**: the consumer is "show parent if it has unread AND I'm subscribed to its discussion (or it has a mention regardless)." Putting both layouts in one query lets the actor build a `subscribedDiscussionIds` set client-side from the discussion-side items and join via `parent.discussionId`. Avoids the chicken-and-egg of two-subscription `combineLatest` and is verified to work with middleware's existing `IN` semantics on multi-value relations.
- **Keys**: id, spaceId, resolvedLayout, name, discussionId, lastMessageDate, unreadMessageCount, unreadMentionCount. (`backlinks` and `notificationSubscribers` dropped from keys — neither is needed in the response now: backlinks isn't part of the join, subscribers is filter-only.)
- **resolvedLayout, not layout**: middleware filters by and exposes `resolvedLayout`; `layout` is deprecated and not populated for cross-space search responses.
- **Tests**: rewritten to assert OR-of-AND structure, both branches' relations/conditions, participant id propagation into the subscribers filter, and the new key set (8 tests).

- [x] Mirrors `ChatDetailsSubscriptionBuilder:20–47`'s shape — `final class : Sendable`, protocol-backed. Single `subscriptionId` + single `build(myParticipantIds:)`.
- [x] Mixed-layout filter built via private `andFilter`/`orFilter`/`countGreaterThanZero`/`isInFilter` helpers.
- [x] No DI on the builder — pure construction.
- [x] Tests: shape regression coverage in `ObjectsWithUnreadDiscussionsSubscriptionBuilderTests.swift`.
- [x] Commit as `IOS-6028 Add ObjectsWithUnreadDiscussionsSubscriptionBuilder`.

### Task 3a.3: Add `ObjectsWithUnreadDiscussionsSubscription`

**Files (delivered):**
- `Anytype/Sources/ServiceLayer/ObjectsUnread/ObjectsWithUnreadDiscussionsSubscription.swift`
- Modified: `Anytype/Sources/ServiceLayer/Auth/LoginStateService.swift` (start/stop wiring after `accountParticipantsStorage`)
- Modified: `Anytype/Sources/ServiceLayer/ServicesDI.swift` (factory registration)

➕ **Design shifted during implementation** — collapsed to a single subscription, deferred entries emission. Final shape:
- **One `SubscriptionStorageProtocol`** (not primary + secondary). Consumes the mixed-layout query from 3a.2; both parents and subscribed discussions arrive in `state.items` and the actor partitions them by `resolvedLayoutValue`.
- **No `combineLatest`**. Reactivity is one-way: `participantsStorage.participantsSequence` drives `applyParticipants(_:)`, which calls `storage.startOrUpdateSubscription(...)` with the participant set baked into the discussion-branch filter. Dedupe via `lastAppliedParticipantIds: Set<String>?` — Optional sentinel distinguishes "never applied" from "applied empty" so the first emission always issues.
- **Cold-start fix**: dropped the synchronous `participantsStorage.participants` read at start. The earlier shape returned an empty array before participants finished loading, which caused the discussion branch to never see real ids; now the only entry point for participants is the async sequence.
- **Protocol stayed minimal**: `start/stop` only. `entries()` and `entriesSequence` removed for now — entries emission is a follow-up step where the entry builder will be reshaped to fit the new join (counters live on parent, subscription state implied by presence in the discussion-side response). The actor currently emits via a temporary `logMatched(_:)` debug print of qualifying parent names.
- **Match logic** (in `logMatched`, will move to entries emission): a parent is included if `unreadMentionCount > 0` OR `parent.discussionId ∈ subscribedDiscussionIds`, where `subscribedDiscussionIds = Set(items.filter(.discussion).map(\.id))`. Mention-only parents pass regardless of subscription; unread-only parents pass only when their discussion is in the subscribed set. Verified end-to-end on a dev account (4 parents with counters, 5 subscribed discussions, 2 correctly matched).
- **Single subscription vs. two-subscription**: the two-sub alternative (parents + all-discussions client-joined) was prototyped and verified equivalent. Picked single-sub for less data over the wire (`notificationSubscribers IN` filters server-side instead of returning every cross-space discussion), one storage instance, and simpler control flow.
- **DI registration**: `Container.objectsWithUnreadDiscussionsSubscription` factory lives in `ServicesDI.swift` next to `chatDetailsStorage`, not in an inline `extension Container` in the actor file.

- [x] Actor declaration with simple protocol, single `SubscriptionStorageProtocol` storage, single `participantsTask`, dedupe via `lastAppliedParticipantIds`.
- [x] `startSubscription()` spawns participants task; `applyParticipants` re-issues `startOrUpdateSubscription` on participant set change.
- [x] `stopSubscription()` cancels task, stops storage, clears state.
- [x] Login wiring in `LoginStateService.startSubscriptions` after `accountParticipantsStorage.startSubscription()`.
- [x] DI registration in `ServicesDI.swift` (singleton-scoped).
- [x] Tests: N/A — actor wiring; integration is exercised by 3b/3c/3d consumers.
- [x] Commit as `IOS-6028 Add ObjectsWithUnreadDiscussionsSubscription`.

### Task 3a.4: Truth-table tests for `ParentObjectUnreadEntryBuilder`

**Files (delivered):**
- `AnyTypeTests/ServiceLayer/ObjectsUnread/ParentObjectUnreadEntryBuilderTests.swift`

- [x] 8 truth-table tests driving the builder with raw `ObjectDetails` fixtures (real protobuf values for `unreadMessageCount`, `unreadMentionCount`, `notificationSubscribers`). Each row asserts `entry?.badge.unreadCounter` (presence + count + style), `hasMention`, and `appIconContribution`.
- [x] Rows 3 and 7 (!subscribed + no mention) assert `entry == nil` — service-side filter mirror.
- [x] Carry-through tests: parent id round-trip, `lastMessageDate` propagation, nil `myParticipantId` treated as not subscribed.
- [x] Builder is a pure function (no DI, no actor hops). Tests synchronous.
- [x] Chat-mode parity tests dropped — chat surfaces stay untouched in 3a, so no chat helper to test.
- [x] Commit folded into `IOS-6028 Add UnreadBadge, ParentObjectUnreadEntry, builder + tests`.

### Task 3a.5: Hand off

- [ ] User builds locally; foundation has no UI to verify.
- [ ] Stage + commit only if user explicitly asks.
- [ ] Tests: `ParentObjectUnreadEntryBuilderTests` must pass (covered in 3a.4). 3a.0 probe ➕ note recorded in the plan file.
- [ ] **STOP. Open PR. Start Chunk 3b in a new session.**

---

### 🟦 Chunk 3b — PR: Space Hub aggregate surfaces

> **Single-session scope.** Begin after 3a's PR merges.

Surfaces: Space Hub Unread section (preview names list), space card aggregate counters (totals + style).

### Task 3b.1: Merge entries in `SpaceHubSpacesStorage.unreadPreviews`

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Helpers/SpaceHubSpacesStorage.swift` (`unreadPreviews` at lines 56–71)
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Helpers/ParticipantSpaceViewDataWithPreview.swift` (the **public** type carrying `unreadPreviews: [ChatMessagePreview]` at line 14 — this is the surface 3b consumers read)

- [ ] **Type swap blast radius**: `unreadPreviews` is a property on `ParticipantSpaceViewDataWithPreview`, not just a local variable inside `SpaceHubSpacesStorage`. Change its type from `[ChatMessagePreview]` to `[UnreadEntry]`. Update the empty initializer's default at line 34 (`.init(...)` constructors). Update every consumer of `ParticipantSpaceViewDataWithPreview.unreadPreviews` — `SpaceCardModelBuilder.buildMultichatCompactPreview:101–120`, plus any other read site (grep for `.unreadPreviews` to enumerate before commit).
- [ ] **Local merge in `SpaceHubSpacesStorage.spacesStream`**: inject `objectsWithUnreadDiscussionsSubscription`. Add its `entriesSequence` to the existing `combineLatest(...)` (currently 3 streams at line 26–30; adding the new one brings it to 4 — split into nested 2+2 OR consume it via `for await` inside the map closure to keep arity ≤ 3).
- [ ] Wrap each `ChatMessagePreview` in `.chat(preview, isSubscribed: true, spaceMuted: spaceView.effectiveNotificationMode(for: preview.chatId) == .nothing)` at construction time. (Chat participants are always subscribed; `spaceMuted` is per-chat-keyed for chats.)
- [ ] Take parent-object entries directly from the new sub's `[UnreadEntry.parentObject]`. They arrive pre-filtered for visibility (server-side filter in 3a) — no additional drop pass needed for parents.
- [ ] Filter the merged list via `UnreadDecision.decide(for: entry, supportsMentions: …).isVisible` — applies the chat `muteAndHide` gate to `.chat(...)` entries; for `.parentObject(...)` it's a no-op since they're already visible. One uniform filter pass.
- [ ] Sort surviving entries jointly by `entry.lastUpdate` descending.
- [ ] Coalesce same-frame emissions with `debounce(for: .milliseconds(16), scheduler: DispatchQueue.main)` — one runloop tick. `debounce` not `throttle` (we want the merged snapshot, not a dropped intermediate).
- [ ] **Feature flag gate**: when `FeatureFlags.discussionButton == false`, skip the new sub's stream — keep today's chat-only output.
- [ ] Tests: N/A — view-adjacent glue.
- [ ] Commit as `IOS-6028 Merge chat and parent entries in unread previews`.

### Task 3b.2: Parent-object names in space card preview line

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Subviews/SpaceCard/SpaceCardModelBuilder.swift` (`buildMultichatCompactPreview` at lines 101–120)

- [ ] Replace the existing `chatDetailsStorage.chat(id:).name` call with `entry.name` (uniform accessor on `UnreadEntry`). For `.chat(...)` continue resolving via `chatDetailsStorage` if naming differs; for `.parentObject(...)` use `details.name.withPlaceholder`.
- [ ] Keep `maxVisible = 3` + " +N" tail behavior unchanged.
- [ ] Input ordering: `unreadPreviews` already sorted by `lastUpdate` (Task 3b.1). Pass through unchanged.
- [ ] Tests: N/A — view-only name projection.
- [ ] Commit as `IOS-6028 Show parent-object names on space card preview`.

### Task 3b.3: Parent-object counts in space card aggregate total

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Helpers/SpacePreviewCountersBuilder.swift` (`build` at lines 43–102)

- [ ] Switch the per-space iteration to `[UnreadEntry]`. For each entry compute `let decision = UnreadDecision.decide(for: entry, supportsMentions: supportsMentions)` and accumulate:
  - `totalUnread += decision.unreadCounterVisible ? entry.unreadCount : 0`.
  - `totalMentions += decision.mentionBadgeVisible ? entry.mentionCount : 0`.
- [ ] The existing chat-only mode switch at lines 57–71 collapses into the helper — `UnreadDecision.decide(for: .chat(...), supportsMentions:)` reproduces today's behavior verbatim (3a.4 chat tests assert this).
- [ ] Counter style (blue vs grey) stays the renderer's job, driven by `decision.style` when widgets render in 3c — this task produces totals only. `unreadStyle` / `mentionStyle` outputs of `SpacePreviewCountersBuilder` follow today's `muteAndHide` logic for chats; for parents, derive analogously per `decision.style`.
- [ ] Tests: N/A here — `UnreadDecision` is exhaustively tested in 3a.4; this is accumulation wiring.
- [ ] Commit as `IOS-6028 Include parent-object counts in space card totals`.

### Task 3b.4: Hand off

- [ ] User builds locally.
- [ ] Scenarios: parent object with unread → name appears in space card preview line and total counter increments; mute the space → totals greyed; multi-discussion ordering by `lastMessageDate`.
- [ ] Stage + commit only if user asks.
- [ ] **STOP. Open PR. Start Chunk 3c in a new session.**

---

### 🟦 Chunk 3c — PR: Inside-space surfaces (Unread section + pinned widgets)

> **Single-session scope.** Begin after 3b's PR merges.

Surfaces: inside-space Unread section (`HomeWidgetsViewModel.startUnreadChatsTask`), MyFavorites widget rows, list-widget rows.

### Task 3c.1: Parent rows in the inside-space Unread section

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/HomeWidgetsViewModel.swift` (`startUnreadChatsTask` at lines 325–355)
- Decide during implementation: extend `UnreadChatWidgetViewModel.swift` + `UnreadChatRowView.swift` + `UnreadChatsGroupedView.swift`, OR sibling-add `UnreadObjectWidgetViewModel.swift` + `UnreadObjectRowView.swift`. Sibling preferred (parent rows read from `objectsWithUnreadDiscussionsSubscription`, not `chatMessagesPreviewsStorage`).

- [ ] Extend `startUnreadChatsTask` to merge parent-object entries from the new sub alongside chat previews. Filter both by `entry.spaceId == spaceId` and by `decision.isVisible`. Emit a typed row-data list (chat vs parent variant).
- [ ] Sibling-add `UnreadObjectWidgetData` (mirrors `UnreadChatWidgetData:1–N` shape) carrying `(id, spaceId, output)` for parent objects.
- [ ] Sibling-add `UnreadObjectWidgetViewModel` reading from `objectsWithUnreadDiscussionsSubscription.entriesStream` (filtering by `id == data.id`). Sets `name`, `icon`, `unreadCounter`, `hasMentions`, `notificationMode` analogously to `UnreadChatWidgetViewModel:46–80`.
- [ ] Update `UnreadChatsGroupedView.swift` (and any wrapping view) to render either variant — switch over a small enum `UnreadRowKind { case chat(UnreadChatWidgetData); case parentObject(UnreadObjectWidgetData) }` if structure differs enough; otherwise extend in place.
- [ ] **Feature flag gate**: when `discussionButton == false`, skip the merge — keep today's chat-only Unread section.
- [ ] Tests: N/A — view-wiring.
- [ ] Commit as `IOS-6028 Show parent objects in inside-space Unread section`.

### Task 3c.2: Extend `WidgetChatPreviewBuilder` for parent objects

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Builders/WidgetChatPreviewBuilder.swift`

- [ ] "Pinned widgets" = in-app home widgets driven by `HomeWidgetsViewModel` (NOT iOS WidgetKit extensions). Data flow runs in the app process; no timeline budget.
- [ ] Add overload to `build(...)` accepting `UnreadEntry.parentObject(...)`. Compute `let decision = UnreadDecision.decide(for: entry, supportsMentions: true)` (widget rows always support mentions) and populate `MessagePreviewModel`:
  - `unreadCounter = decision.unreadCounterVisible ? entry.unreadCount : 0`.
  - `mentionCounter = decision.mentionBadgeVisible ? entry.mentionCount : 0`.
  - Style (blue vs grey) maps `decision.style` to existing `MessagePreviewModel` styling fields. **Concrete mapping**: read `MessagePreviewModel+Presentation.swift:46–82` during implementation; pick existing tokens producing the two outcomes already used by chat rows in `.all` vs `.nothing` mode (blue-highlighted vs grey-muted). No new tokens, no new flag on `MessagePreviewModel`.
- [ ] `hasUnreadReactions = false` unconditionally (middleware does not forward reaction state to parent).
- [ ] **No `MessagePreviewModel+Presentation` tweak**. Parent rows set counter/mention directly per the decision; do not exercise the chat-row `muteAndHide` gate.
- [ ] One entry point with overload — do NOT fork a sibling builder.
- [ ] Tests: N/A — field-copy.
- [ ] Commit as `IOS-6028 Extend WidgetChatPreviewBuilder for parent objects`.

### Task 3c.3: Wire parent-object rows into `MyFavorites`

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesViewModel.swift`
- Modify (only if verification reveals need): `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesRowView.swift`

- [ ] In `startChatCountersSubscription` (around lines 109–145), also consume `objectsWithUnreadDiscussionsSubscription.entriesStream`. Look up rows by object id; build `MessagePreviewModel` via the 3c.2 overload.
- [ ] `MyFavoritesRowView:30` already renders badges from `hasVisibleCounters` — no view change if model is populated. Verify visually first.
- [ ] **Feature flag gate**: skip the parent-object merge when `discussionButton == false`.
- [ ] Tests: N/A — view-wiring.
- [ ] Commit as `IOS-6028 Show parent-object unread on MyFavorites widget`.

### Task 3c.4: Wire parent-object rows into list-widget row builder

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Builders/WidgetRowModelBuilder.swift`

- [ ] Extend `buildListRows` (lines 29–44). When `previewsByChatId[config.id]` misses (id is a parent-object, not a chat), fall back to a parent-object preview built from `objectsWithUnreadDiscussionsSubscription` via the 3c.2 builder overload.
- [ ] `ListWidgetRow:22–26` renders automatically when `model.chatPreview` is non-nil.
- [ ] Respect existing `shouldHideChatBadges` environment flag (collapsed-vs-expanded Unread section logic flows through unchanged).
- [ ] Widget gallery rows (`buildGalleryRows:23`) stay unchanged — chats don't render counters there either.
- [ ] **Feature flag gate**: skip the parent-preview merge when `discussionButton == false`.
- [ ] Tests: N/A — view-wiring.
- [ ] Commit as `IOS-6028 Show parent-object unread on list widgets`.

### Task 3c.5: Hand off

- [ ] User builds locally.
- [ ] Scenarios: receive comment on a parent object → row appears in inside-space Unread section with count + `@` if mention; pin the object to MyFavorites → row shows counter; same row in a list widget → renders preview.
- [ ] Truth-table spot-check: toggle "All New Replies" / "Mentions Only" + space mute → 8 rows render correctly (blue vs grey, counter vs no counter, `@` badge presence).
- [ ] Viewer account: confirm rows + counters show for Viewers (read-only).
- [ ] Stage + commit only if user asks.
- [ ] **STOP. Open PR. Start Chunk 3d in a new session.**

---

### 🟦 Chunk 3d — PR: App icon badge

> **Single-session scope.** Begin after 3c's PR merges.

### Task 3d.1: Aggregate parent-object unread into the app icon badge

**Files:**
- Modify: `Anytype/Sources/ServiceLayer/Badge/AppIconBadgeService.swift` (`updateBadge` at lines 63–97)

- [ ] Inject `objectsWithUnreadDiscussionsSubscription`.
- [ ] **Badge trigger location** (already known): `AppIconBadgeService.swift:40` runs `combineLatest(previewsSequence, spaceViews, chatDetails).throttle(300)`. Add the new sub's `entriesSequence` as a fourth stream — split into nested `combineLatest(combineLatest(a, b), combineLatest(c, d))` to stay within AsyncAlgorithms' 3-stream arity, or restructure to consume the new sub via a `for await` loop that triggers `updateBadge` on its emissions.
- [ ] Add a parallel aggregation loop over parent-object entries — one line: `total += UnreadDecision.decide(for: entry, supportsMentions: supportsMentions).badgeContribution`. The helper carries all 8 rows; call site does NO per-case branching.
- [ ] Refactor the existing chat loop at lines 81–91 onto the same helper — `UnreadDecision.decide(for: .chat(...), supportsMentions:).badgeContribution`. 3a.4 chat tests assert verbatim parity.
- [ ] **Double-count probe**: confirm `ChatMessagesPreviewsStorage` does NOT emit `.discussion`-layout entries (it filters by `.chatDerived`). Add a one-line probe log during implementation; **remove it before commit** (review asserts absence). If discussions DO appear there, de-dup by skipping chat entries whose `chatId` equals some parent's `discussionId`.
- [ ] Badge write path unchanged: `UNUserNotificationCenter.current().setBadgeCount(total)` (line 96) + `badgeCountStorage` (line 95).
- [ ] **Feature flag gate**: when `discussionButton == false`, skip the parent loop AND skip the trigger merge — keep today's chat-only badge.
- [ ] Tests: N/A at call site — `UnreadDecision` is fully covered in 3a.4.
- [ ] Commit as `IOS-6028 Include parent-object unread in app icon badge`.

### Task 3d.2: Hand off

- [ ] User builds locally.
- [ ] Scenarios: receive comment on a parent object → app icon badge increments; mute the space → badge contribution drops to mention-only; mark all read → badge clears.
- [ ] No double-count: chat + parent-with-discussion in the same space, both unread → badge equals chat unread + parent unread.
- [ ] Stage + commit only if user asks.
- [ ] **STOP. Open PR. Start Chunk 4 in a new session — or defer to Post-Completion.**

---

### 🟪 Chunk 4 — PR: Last-comment preview on object surfaces

> **Single-session scope.** Begin after 3a/3b/3c/3d ship. Introduces its own `DiscussionLastMessagesPool` for preview text (the discussion's `lastMessageDate` relation gives 3a the timestamp, but content fields are not exposed as relations).

Surfaces: last-comment preview text in Set/Collection gallery + list cells, and list-widget rows, for parent objects that have a discussion.

### Task 4.1: Decide pool gate and add `DiscussionLastMessagesPool`

**Files:**
- Create: `Anytype/Sources/ServiceLayer/ObjectsUnread/DiscussionLastMessagesPool.swift`

- [ ] Lock the gate decision before writing code. Three options to evaluate (briefly probe and pick one):
  - (a) Subscribe for all parent objects in visible scopes (sets/collections currently on screen, widget list contents). Bounded but UI-driven; lifecycle non-trivial.
  - (b) Reuse 3a's primary set (visibility-gated discussions). Simple — just hand `objectsWithUnreadDiscussionsSubscription.entries()`'s discussion ids to the pool. Caveat: fully-read discussions show no preview.
  - (c) Ask middleware to expose `lastMessageText` / creator / attachments as relations on the chat object. Skips the pool entirely; cleanest. Middleware work.
- [ ] Record the chosen option as a ➕ note before proceeding.
- [ ] If (a) or (b): build the pool — `actor DiscussionLastMessagesPool` mirroring `DiscussionMessageCountObserver:32–60`'s per-id internals (same RPC `chatService.subscribeLastMessages(chatObjectId:, subId:, limit: 1)`, same `EventBunchSubscribtion` event handling for `chatAdd` + `chatStateUpdate` + `chatUpdateMessageCount`, same `unsubscribeLastMessages` cleanup), multiplexed across N chatIds via `setObservedIds(_:)`.
- [ ] Define `LastMessageInfo` carrying only what consumers actually use: `createdAt`, `text`, `creator: Participant?`, `attachments: [ObjectDetails]`, `attachmentCount: Int`. Use `Container.shared.messageTextBuilder()` for text formatting (same dep `ChatMessagesPreviewsStorage:21` uses).
- [ ] DI: `Container.shared.discussionLastMessagesPool` Factory, `.shared` scope. Start when the first consumer subscribes; stop when the last consumer unsubscribes (or just keep `.shared` alive — bounded cost given the gate).
- [ ] Tests: a small `DiscussionLastMessagesPoolTests` covering set-diff lifecycle (start/stop accounting on `setObservedIds`).
- [ ] Commit as `IOS-6028 Add DiscussionLastMessagesPool for chunk 4 previews`.

### Task 4.2: Wire pool lookup into set/collection builder

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/TextEditor/Set/Views/Models/SetContentViewDataBuilder.swift` (`buildChatPreview` at lines 288–319; `chatPreviewsDict` at line 129)

- [ ] Inject `discussionLastMessagesPool`.
- [ ] In the cell-build path, when `details.discussionId.isNotEmpty`, look up `pool.snapshot()[details.discussionId]?` and adapt into the cell's existing preview shape. Native chats fall through to the existing `chatId`-keyed path.
- [ ] Cell renderers (`SetGalleryViewCell:34`, `SetListViewCell:18`) require no change.
- [ ] **Feature flag gate**: skip pool lookup when `discussionButton == false`.
- [ ] Tests: N/A — lookup wiring.
- [ ] Commit as `IOS-6028 Show parent-object last-comment in set/collection cells`.

### Task 4.3: Wire pool lookup into list-widget row builder

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Builders/WidgetRowModelBuilder.swift` (line 39 — `previewsByChatId[config.id]` currently assumes id == chatId)

- [ ] Inject `discussionLastMessagesPool`.
- [ ] When `previewsByChatId[config.id]` misses AND `details.discussionId.isNotEmpty`, look up `pool.snapshot()[discussionId]?` and adapt into the widget's existing preview shape.
- [ ] `ListWidgetRow:22–26` renders automatically once the model is populated.
- [ ] Widget gallery rows stay unchanged.
- [ ] **Feature flag gate**: skip pool lookup when `discussionButton == false`.
- [ ] Tests: N/A — lookup wiring.
- [ ] Commit as `IOS-6028 Show parent-object last-comment on list widgets`.

### Task 4.4: Hand off to user for build + manual verification

- [ ] Scenarios: add a parent object with discussion to a set/collection (gallery + list layouts) → row shows last-comment with author; add to a list-widget → same; native chats remain unaffected.
- [ ] Stage + commit only if user asks.
- [ ] Tests: N/A — hand-off task.
- [ ] No commit for this task.
- [ ] **STOP. Open PR. Mark IOS-6028 ready for testing in Linear. Move this plan to `docs/plans/completed/`.**

---

## Deferred (out of scope for this plan)

- **Reaction heart indicator on parent-object rows / widgets.** Middleware PR #3109 does not forward `hasUnreadReactions` to the parent. Re-evaluate only if a future middleware PR adds this field.

## Post-Completion

**Manual verification** (after each chunk's PR is merged):
- **Chunk 1** (shipped): multi-account — Owner creates object, opens discussion → "All New Replies" checked; Viewer → Notifications menu hidden.
- **Chunk 2**: open a parent object with unread comments → blue dot on Discuss button; open discussion → scrolls to first unread; fully read → lands at bottom; tap a discussion push → correct deep-link.
- **Chunk 3a** (Foundation): no UI surfaces — verify `UnreadDecisionTests` passes; subscriptions start cleanly at login (no warnings, no crashes); pool spins up without churn.
- **Chunk 3b** (Space Hub): receive comment on a parent object → name appears in space card preview line; aggregate total counter increments; mute space → totals styled grey.
- **Chunk 3c** (Inside-space): same scenario → row appears in inside-space Unread section with count + `@` badge if mention; pinned object on MyFavorites and list widgets shows counter + mention indicator; truth-table spot-check across all 8 rows.
- **Chunk 3d** (App icon badge): same scenario → app icon badge increments; mute → drops to mention-only contribution; no double-count vs chats; mark all read clears badge.
- **Chunk 4**: sets/collections gallery + list cells show last-comment preview on parent objects with a discussion; list widgets ditto; chats remain unaffected.

**External system updates**: none — pure client-side against already-merged middleware.

**Follow-up Linear tasks**:
- After Chunk 3d merges: consider filing a middleware task for reaction-heart forwarding (optional, only if design still wants parity).
- After Chunk 3a merges: optional follow-up to deprecate `DiscussionMessageCountObserver` in favor of `DiscussionLastMessagesPool` (which subsumes its single-id count subscription). Out of scope for 3a; revisit only if there's a reason to consolidate.
- After Chunk 4 merges: move this plan to `docs/plans/completed/`.
