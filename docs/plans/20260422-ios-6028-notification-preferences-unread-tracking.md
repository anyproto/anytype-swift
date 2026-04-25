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
- **Chunk 2** — in-object unread affordance: blue dot on Discuss button, open-at-first-unread.
- **Chunk 3** — aggregate unread surfaces: unread section, space card preview names + total, pinned object widgets, app icon badge.
- **Chunk 4** — last-comment preview on object surfaces (sets/collections/list widgets).

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

**Files involved (Chunk 3):**
- `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Helpers/SpaceHubSpacesStorage.swift` (`unreadPreviews` at lines 56–71).
- `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Subviews/SpaceCard/SpaceCardModelBuilder.swift` (`buildMultichatCompactPreview` at lines 101–120; `maxVisible = 3`).
- `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Helpers/SpacePreviewCountersBuilder.swift` (`build` at lines 43–102 — mode-aware per-space aggregation).
- `Anytype/Sources/ServiceLayer/Badge/AppIconBadgeService.swift` (`updateBadge` at lines 63–97 — iterates `chatMessagesPreviewsStorage.previews()` + `spaceViewsStorage.allSpaceViews`; sets `UNUserNotificationCenter.current().setBadgeCount(total)`).
- `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Builders/WidgetChatPreviewBuilder.swift` (adapter `ChatMessagePreview → MessagePreviewModel`).
- `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Builders/WidgetRowModelBuilder.swift` (`buildListRows` at lines 29–44; lookup at line 39 keyed by object id).
- `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesViewModel.swift` + `MyFavoritesRowView.swift` (counter + `@` badge rendering; `hasVisibleCounters` at line 30 of row view).
- New: `Anytype/Sources/ServiceLayer/ObjectsUnread/ObjectsWithUnreadDiscussionsSubscription.swift` (ServiceLayer so both `SpaceHubSpacesStorage` and `AppIconBadgeService` can depend on it without crossing layer boundaries).
- New: `Anytype/Sources/ServiceLayer/ObjectsUnread/UnreadEntry.swift` and `.../UnreadDecision.swift` (sum type + truth-table helper; colocated).

**Files involved (Chunk 4):**
- `Anytype/Sources/PresentationLayer/TextEditor/Set/Views/Models/SetContentViewDataBuilder.swift` (`buildChatPreview` at lines 288–319; `chatPreviewsDict` at line 129 — dict keyed by chatId).
- `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Builders/WidgetRowModelBuilder.swift` (line 39 — `previewsByChatId[config.id]` assumes id == chatId).
- `Modules/Services/Sources/Services/Chat/ChatService.swift` (lines 91–96 — `chatSubscribeToMessagePreviews` RPC call site; probe during Task 4.0).

**Related patterns:**
- `NotificationModeMenu.swift` — 3-mode variant for space settings; not reused (Chunk 1 built a 2-option variant).
- `ChatMessageBuilder.swift:120–136` — unread-divider insertion (chat has a visible separator; discussion deliberately does not — open-at-first-unread is scroll-only).
- `ChatMessagesPreviewsStorage` — space-wide preview stream keyed by `(spaceId, chatId)`. Chunk 4 reads it with `details.discussionId` as lookup key.
- `SpacePreviewCountersBuilder` — per-space unread aggregation (mode-aware). Chunk 3 extends with parent-object iteration.
- `ObjectIdsSubscriptionService` / `SubscriptionService` — use `SubscriptionService` (space-wide filter subscription) for the new `ObjectsWithUnreadDiscussionsSubscription`; use `ObjectIdsSubscriptionService` only for explicit id lists.
- `ChatDetailsSubscriptionBuilder:22` — existing `.chatDerived` layout filter. Template for the new parent-objects filter (different layouts + `unreadMessageCount > 0`).
- `accountParticipantsStorage.participantSequence(spaceId:)` (documented in Chunk 1 post-review) — source for current-user participant when needed.
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
- **`lastUpdate` resolution for parent objects**: `details.lastModifiedDate` is the object's own modification time — NOT the discussion's last-message time. A discussion can be actively receiving messages while the parent object's body is untouched, so `lastModifiedDate` is stale for sort purposes. Resolve the real last-message date via `details.discussionId` → lookup in `ChatMessagesPreviewsStorage.previews()` → use that preview's `lastMessage.createdAt`. Pass it into `UnreadEntry.parentObject(..., lastMessageDate:)`. If the preview isn't available (chat smartblock not yet loaded, or middleware doesn't emit previews for `ot-discussion` chats), fall back to `details.lastModifiedDate` and note it in a ➕. Chunk 3's sort quality therefore depends on the same probe Task 4.0 runs — if Chunk 4 ships, Chunk 3 sort is always accurate; if Chunk 4 is blocked, Chunk 3 sort is degraded but functional.
- **Data source**: a new `ObjectsWithUnreadDiscussionsSubscription` uses `SubscriptionService` to query all objects in the space where `unreadMessageCount > 0` and layout is non-chat (exclude `.chatDerived`). Emits `[ObjectDetails]` with exactly the fields the sum type needs: `id, name, iconImage, unreadMessageCount, unreadMentionCount, spaceId, lastModifiedDate, layout, discussionId`. Shape and registration match `ChatMessagesPreviewsStorage` (class, `@Injected`, async sequence) — don't choose-your-own-adventure between actor/`@Observable`. `SpaceHubSpacesStorage` (not the subscription itself) joins the stream with `chatMessagesPreviewsStorage.previews()` to resolve `lastMessageDate` when constructing each `UnreadEntry.parentObject`.
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

- **Badge double-count prevention**: `ChatMessagesPreviewsStorage` filters by `.chatDerived` layout (not `.discussion`), so discussion chat objects should not appear in the chat preview list. Confirm this during Task 3.4 with a one-line probe log. If they do appear, de-dup by skipping chat entries whose chatId equals some parent's `discussionId`.

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
  - Space Hub Unread section (Task 3.1): drop entries with `!decision.isVisible`; style each row via `decision.style`.
  - Space card counters (Task 3.3): accumulate `decision.unreadCounterVisible ? entry.unreadCount : 0` + `decision.mentionBadgeVisible ? entry.mentionCount : 0`.
  - App icon badge (Task 3.4): accumulate `decision.badgeContribution` — one line, no per-case branching at the call site.
  - Widget rows (Task 3.5): populate `MessagePreviewModel` using the decision fields — no `isParentObjectEntry` flag on `MessagePreviewModel`, no tweak to `MessagePreviewModel+Presentation`.

  The helper is the only place the truth table lives. Unit tests (Task 3.0b) cover 8 parent rows + the chat-mode cases.

- **Subscription plumbing — resolving `isSubscribed`**. `notificationSubscribers` lives on the discussion's chat object (not forwarded to the parent by PR #3109). `ObjectsWithUnreadDiscussionsSubscription` composes three inputs to compute `isSubscribed` per parent:
  1. Parent's `details.discussionId`.
  2. That discussion chat object's `notificationSubscribers` (participant object IDs).
  3. Current user's participant id per space (from `accountParticipantsStorage.participantSequence(spaceId:)` — same source Chunk 1's `subscribeOnNotificationMode` used).

  **Secondary-subscription strategy** (id-diff, not churn): hold the current discussion-id set as a `CurrentValueSubject<Set<String>, Never>`. Each time the primary stream emits, diff the new set against the current one; call `objectIdsSubscriptionService.startSubscription(objectIds:)` **only on set change** (not on every emission). This mirrors how `ChatDetailsSubscriptionBuilder` replaces its filter on space change and keeps the service stable during rapid unread-count churn. The decision helper reads the latest snapshot of the chat-object subscription; entries where the chat object hasn't yet loaded treat `isSubscribed` as `false` (converges within one round-trip).
- **Space Hub Unread section** (`SpaceHubSpacesStorage.unreadPreviews:56–71`): merge the new stream with `chatMessagesPreviewsStorage.previewsSequence` into a `[UnreadEntry]`, filter out entries where `UnreadDecision.decide(for:).isVisible == false`, and sort jointly by `lastUpdate`. Coalesce same-frame emissions with `debounce(for: .milliseconds(16), scheduler: DispatchQueue.main)` — equivalent to one runloop tick, not user-visible latency; picks `debounce` (not `throttle`) because we want the merged snapshot, not a dropped intermediate.
- **Space card preview names** (`SpaceCardModelBuilder.buildMultichatCompactPreview:101–120`): the preview-names list is built from `unreadPreviews`. With the sum type in place, each entry exposes `name` uniformly. Existing `maxVisible = 3` + " +N" tail behavior unchanged.
- **Space card aggregate count** (`SpacePreviewCountersBuilder.build:43–102`): iterate `[UnreadEntry]`, call `UnreadDecision.decide(for:)` per entry, accumulate `decision.unreadCounterVisible ? entry.unreadCount : 0` + `decision.mentionBadgeVisible ? entry.mentionCount : 0`. The existing chat mode-switch collapses into the decision helper (for `.chat` variants it behaves identically to today's code).
- **App icon badge** (`AppIconBadgeService.updateBadge:63–97`): one parallel loop over parent-object entries, `total += decision.badgeContribution` per entry — no per-case branching at the call site. **Critical**: wire the new subscription's change stream into the same trigger that drives `updateBadge` (probe the current trigger during Task 3.4) — otherwise the badge is stale when parent-only unread arrives.
- **Pinned object widgets** (Favorites + list widgets): the plan's "pinned widgets" are in-app home widgets on the home widgets view (driven by `HomeWidgetsViewModel`) — not iOS WidgetKit extensions. Data flow runs in the app process via `@Injected` storage. Extend `WidgetChatPreviewBuilder.build(...)` with an overload accepting a parent-object `ObjectDetails` and producing the same `MessagePreviewModel` shape. `hasUnreadReactions = false` always. `MyFavoritesRowView:30` renders badges based on `hasVisibleCounters` unchanged. For list widgets, `WidgetRowModelBuilder.buildListRows:29–44` includes parent-object previews; `ListWidgetRow:22–26` renders automatically when `model.chatPreview` is non-nil.
- **Collapsed-vs-expanded Unread section**: the existing `shouldHideChatBadges` environment flag already gates double-count suppression when the Unread section is open. Parent-object badges flow through the same environment unchanged.
- **Viewer permission parity**: Viewers see aggregate unread surfaces exactly like Editors/Owners — unread state is read-only information and is not permission-gated.

### Last-comment preview (Chunk 4)

- **Mechanism**: `chatMessagesPreviewsStorage.previews()` is already a space-wide stream indexed by `chatId`. Parent objects with a discussion carry `details.discussionId` pointing at the chat object. Extend the builder paths so that when a row is rendered for a parent object, the preview lookup key becomes `details.discussionId` (falling back to `objectId` for native chats).
- **Surfaces enabled**: Set/Collection gallery + list cells (`SetContentViewDataBuilder.buildChatPreview:288–319`); widget list rows (`ListWidgetRow:22–26`). Both cell renderers and the `ListWidgetRow` view already render whatever preview the builder supplies — the change is entirely in the lookup key.
- **Surfaces intentionally untouched**: widget gallery layouts (`WidgetRowModelBuilder.buildGalleryRows:23` — no preview for chats either); MyFavorites widget (badges only by design); Space Card preview line (names only, no message text).
- **Verification** (Task 4.0): before wiring client paths, confirm `chatSubscribeToMessagePreviews` already returns `ChatMessagePreview` entries for `ot-discussion` chat objects. If it does, Chunk 4 is purely a client-side lookup-key change. If not, block on a middleware ask.

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
- [ ] **User manually verifies during the Chunk 2 hand-off (Task 2.5)**: copy a deeplink to a comment from another client (web/macOS/Android) or trigger a real push, tap it in iOS, and confirm against these explicit pass criteria:
  1. Space opens correctly.
  2. Parent object opens correctly.
  3. Discussion screen pushes on top.
  4. Scrolls to the referenced comment (message-id-specific landing).
  - If criteria 1–3 pass but criterion 4 fails, treat it as a **partial pass** — Chunk 2 still ships (unread-dot + first-unread scroll are the scope); criterion 4 becomes a Chunk 2 follow-up task scoped to `messageId` plumbing, not a Chunk 2 blocker.
  - If criterion 1, 2, or 3 fails, Chunk 2 is blocked until fixed.
- [ ] If user reports any of 1–3 broken, agent diagnoses and patches in-place when the fix is ≤10 lines; otherwise files a separate Linear task and ships Chunk 2 without the patch.
- [x] Tests: N/A — not simulable from the agent; pass/fail decided by user verification.
- [x] Commit as `IOS-6028 Verify discussion push routing handler` (even if no code changes — the ➕ note is the artifact; use `--allow-empty` if the sanity check produced zero diff).

### Task 2.5: Hand off to user for build + manual verification

- [ ] Do NOT build from the agent; user builds locally.
- [ ] Scenarios: receive a new comment → blue dot on Discuss button; open discussion with unread → lands on first unread (no visible divider, scroll-only); open discussion fully read → lands at bottom; tap discussion push → correct deep-link (pass criteria per Task 2.4).
- [ ] Stage + commit only if user explicitly asks.
- [ ] Tests: N/A — hand-off task.
- [ ] No commit for this task.
- [ ] **STOP. Open PR. Start Chunk 3 in a new session.**

---

### 🟦 Chunk 3 — PR #3: Aggregate unread surfaces

> **Single-session scope.** Do NOT start this in the same session as Chunks 2 or 4. Begin a new session after Chunk 2's PR merges.

Surfaces covered: Space Hub Unread section, space card preview names + total count, app icon badge, pinned object widgets (counter + `@` mention badge). Reaction heart indicator is skipped — middleware does not forward `hasUnreadReactions` to the parent object.

**Rollback / kill-switch**: every new aggregation path added in Chunk 3 lives behind the existing `FeatureFlags.discussionButton` gate. Disabling the flag must produce exact pre-Chunk-3 behavior. Injection points that must early-return when the flag is off:
- `SpaceHubSpacesStorage.unreadPreviews` — merge step (skip the `ObjectsWithUnreadDiscussionsSubscription` branch, keep chat-only today's output).
- `SpacePreviewCountersBuilder.build` — parent-object accumulation loop.
- `AppIconBadgeService.updateBadge` — parent-object aggregation loop + trigger wiring.
- `WidgetChatPreviewBuilder.build(...)` parent-object overload — return `nil` so callers fall back to today's chat-only path.
- `MyFavoritesViewModel.startChatCountersSubscription` and `WidgetRowModelBuilder.buildListRows` — skip parent-preview merge.
No other gating is needed — the subscription itself is harmless to start when the flag is off (it just feeds no consumers). Document the flag check inline at each injection point with a one-liner so the rollback path is legible.

### Task 3.0a: Add subscription for parent objects with unread discussion

**Files:**
- Create: `Anytype/Sources/ServiceLayer/ObjectsUnread/ObjectsWithUnreadDiscussionsSubscription.swift` (service-layer module so both `SpaceHubSpacesStorage` and `AppIconBadgeService` can depend on it without crossing into PresentationLayer)

- [ ] Match the shape of `ChatMessagesPreviewsStorage` — same class kind (not actor), same DI registration pattern (`@Injected`), same `previewsSequence` / `previews()` exposure. Do not fork into an actor; do not invent a new pattern.

- [ ] **Primary subscription**: wrap `SubscriptionService`. Filter: non-chat layouts AND `unreadMessageCount > 0`. Template: `ChatDetailsSubscriptionBuilder:22` (replace `.chatDerived` with excluded-layouts filter + unread-count filter). Fields requested from the backend (finalized list — every downstream consumer in Tasks 3.1–3.5 uses something from here):
  - `id` — used as `UnreadEntry.id` and as the widget/row lookup key.
  - `name` — space card preview line, widget row title, Unread section row.
  - `iconImage` — widget row icon; Unread section row icon.
  - `unreadMessageCount` — raw count, consumed by `UnreadDecision`.
  - `unreadMentionCount` — raw count, consumed by `UnreadDecision`.
  - `spaceId` — space grouping + space-level mute lookup.
  - `lastModifiedDate` — fallback sort key when the discussion's last-message date isn't available.
  - `discussionId` — used to look up the discussion chat object for `notificationSubscribers` + `lastMessage.createdAt`.
  - `layout` — defensive include for any downstream type-filter.

- [ ] **Secondary subscription (id-diff strategy, NOT churn)**: hold discussion ids in `CurrentValueSubject<Set<String>, Never>`. On primary-stream emit, compute `newSet = emittedParents.compactMap { $0.discussionId }`; if `newSet != currentSet`, call `objectIdsSubscriptionService.startSubscription(objectIds: Array(newSet), …)` **once** (not per emission). Request `notificationSubscribers` from each chat object. Subscription resubscribes O(1) internally on set change — no churn during unread-count fluctuation. Reference shape: how `ChatDetailsSubscriptionBuilder` replaces its filter on space change.

- [ ] **Current participant lookup**: hold a live value of the current user's participant id per space, sourced from `accountParticipantsStorage.participantSequence(spaceId:)`. Same source Chunk 1's `subscribeOnNotificationMode` uses (see Chunk 1 post-review).

- [ ] **Entry emission — RAW state only, no filtering, no zeroing**. For each parent's current snapshot, emit `UnreadEntry.parentObject(details, isSubscribed:, spaceMuted:, unreadMessageCount:, unreadMentionCount:, lastMessageDate:)` where:
  - `isSubscribed = notificationSubscribers.contains(currentParticipantId)` — chat object not yet loaded → treat as `false` (converges within one round-trip when the secondary subscription delivers).
  - `spaceMuted = spaceView.pushNotificationMode == .nothing`.
  - `unreadMessageCount`, `unreadMentionCount` — pass through raw from `details`.
  - `lastMessageDate` — resolved from `chatMessagesPreviewsStorage.previews()[discussionId]?.lastMessage.createdAt` if available; nil otherwise.
  - **Do NOT apply the truth-table rules at source.** Visibility / counter display / badge math lives in `UnreadDecision.decide(for:)` (Task 3.1) and is applied by each consumer — single source of truth, unit-tested once.

- [ ] **Per-space scoping**: match how `chatMessagesPreviewsStorage.previews()` slices per space.

- [ ] Register in DI (`ServicesDI.swift` or appropriate container).

- [ ] Tests: N/A for this task — see Task 3.0b for the 8-case unit test split.

- [ ] Commit as `IOS-6028 Add ObjectsWithUnreadDiscussionsSubscription`.

### Task 3.0b: Unit-test `UnreadDecision` against the 8-case truth table

**Files:**
- Create: `AnyTypeTests/ServiceLayer/ObjectsUnread/UnreadDecisionTests.swift`

- [ ] One test method per parent-object row (8 total), named `testParentRow1Visible_SubscribedUnmuted_NoMention()` … `testParentRow8Visible_NotSubscribedMutedWithMention()`. Each constructs an `UnreadEntry.parentObject(...)` with the matching `isSubscribed` / `spaceMuted` / mention combination and asserts all four `UnreadDecision` fields (`isVisible`, `unreadCounterVisible`, `mentionBadgeVisible`, `style`) + `badgeContribution` match the truth-table row.
- [ ] Additional tests for `.chat(...)` variant to guard against regressing existing chat behavior — three tests covering `.all` / `.mentions` / `.nothing` modes with `supportsMentions ∈ {true, false}`.
- [ ] `decide(for:supportsMentions:)` must be a pure function (no DI, no actor hops) so these tests are synchronous.
- [ ] Tests must pass before Task 3.1 starts.

- [ ] Commit as `IOS-6028 Cover UnreadDecision with truth-table tests`.

### Task 3.1: Introduce `UnreadEntry` + `UnreadDecision` and include parent objects in Unread section

**Files:**
- Create: `Anytype/Sources/ServiceLayer/ObjectsUnread/UnreadEntry.swift` (service-layer type — consumed by both service layer and multiple presentation modules)
- Create: `Anytype/Sources/ServiceLayer/ObjectsUnread/UnreadDecision.swift` (colocated with `UnreadEntry`)
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Helpers/SpaceHubSpacesStorage.swift` (`unreadPreviews` at lines 56–71)

- [ ] Define the sum type — raw state only; interpretation lives in `UnreadDecision`:
  ```swift
  enum UnreadEntry {
      case chat(ChatMessagePreview, isSubscribed: Bool, spaceMuted: Bool)
      case parentObject(
          ObjectDetails,
          isSubscribed: Bool,
          spaceMuted: Bool,
          unreadMessageCount: Int,
          unreadMentionCount: Int,
          lastMessageDate: Date?
      )
      var id: String { ... }
      var name: String { ... }
      var spaceId: String { ... }
      var unreadCount: Int { ... }      // chat → preview.unreadCounter; parent → unreadMessageCount
      var mentionCount: Int { ... }     // chat → preview.mentionCounter; parent → unreadMentionCount
      var lastUpdate: Date { ... }
      var isSubscribed: Bool { ... }
      var spaceMuted: Bool { ... }
  }
  ```
- [ ] Define `UnreadDecision` — pure, synchronous, encodes all case logic in one place:
  ```swift
  struct UnreadDecision {
      enum Style { case blue, grey }
      let isVisible: Bool
      let unreadCounterVisible: Bool
      let mentionBadgeVisible: Bool
      let style: Style
      let badgeContribution: Int

      static func decide(for entry: UnreadEntry, supportsMentions: Bool) -> UnreadDecision
  }
  ```
  Implementation:
  - **`.parentObject(...)` branch** (8 truth-table rows, covered in Task 3.0b tests):
    - `isVisible = (isSubscribed && unreadMessageCount > 0) || unreadMentionCount > 0`.
    - `unreadCounterVisible = isSubscribed && unreadMessageCount > 0`.
    - `mentionBadgeVisible = unreadMentionCount > 0`.
    - `style = spaceMuted ? .grey : .blue`.
    - `badgeContribution`:
      - Rows 1–2 (unmuted, subscribed) → `unreadMessageCount` (mentions subset).
      - Row 4 (unmuted, !subscribed, mention>0) → `unreadMentionCount`.
      - Rows 5–6 (muted, subscribed) → `0` (grey counter visible in widgets, but badge omits — chat parity).
      - Row 8 (muted, !subscribed, mention>0) → `supportsMentions ? unreadMentionCount : 0`.
      - Hidden rows (3, 7) → `0`.
  - **`.chat(...)` branch** — reproduce today's `SpacePreviewCountersBuilder.build:57–71` and `AppIconBadgeService:81–91` switches verbatim so chat behavior is preserved bit-for-bit. `isVisible` uses the same `muteAndHide` gate `SpaceHubSpacesStorage.unreadPreviews:56–71` applies today.
- [ ] `lastUpdate` resolution:
  - `.chat(preview, …)` → `preview.lastMessage.createdAt`.
  - `.parentObject(details, ..., lastMessageDate: date)` → `date ?? details.lastModifiedDate`.
- [ ] Replace `unreadPreviews` output type with `[UnreadEntry]`. Build the stream by combining `chatMessagesPreviewsStorage.previewsSequence` with `ObjectsWithUnreadDiscussionsSubscription`'s stream. `SpaceHubSpacesStorage` wraps each incoming item in the appropriate variant. For `.chat` entries it freezes `isSubscribed = true` (chat participants are always subscribed) and `spaceMuted = spaceView.effectiveNotificationMode(for: preview.chatId) == .nothing` at construction time — keeps the entry self-contained.
- [ ] **Visibility filter**: apply `UnreadDecision.decide(for: entry, supportsMentions: …).isVisible` to the merged stream before sorting. One filter for both variants; the decision helper knows the chat `muteAndHide` gate and the parent 8-case rules.
- [ ] Sort the surviving entries jointly by `lastUpdate`.
- [ ] Coalesce same-frame emissions with `debounce(for: .milliseconds(16), scheduler: DispatchQueue.main)`. Not `throttle` — we want the merged snapshot, not a dropped intermediate.
- [ ] Update any existing call sites that consume `unreadPreviews` to pattern-match on the new sum type (most sites collapse to uniform accessors — see Tasks 3.2, 3.3).

- [ ] Tests: N/A for this task — `UnreadDecision` is tested in Task 3.0b; `SpaceHubSpacesStorage` wiring is view-adjacent glue.

- [ ] Commit as `IOS-6028 Unify chat and parent-object entries in UnreadEntry`.

### Task 3.2: Include parent object names in space card preview line

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Subviews/SpaceCard/SpaceCardModelBuilder.swift` (`buildMultichatCompactPreview` at lines 101–120)

- [ ] The existing builder calls `chatDetailsStorage.chat(id:).name` for each entry. Replace that with `entry.name` (uniform accessor on `UnreadEntry`). For `.chat(preview, ...)` resolve the name via the existing `chatDetailsStorage` path; for `.parentObject(details, ...)` use `details.name.withPlaceholder`.
- [ ] Keep existing `maxVisible = 3` + " +N" tail behavior.
- [ ] Input ordering: `unreadPreviews` already sorted by `lastUpdate` (Task 3.1). Pass through order unchanged.

- [ ] Tests: N/A — view-only name projection; covered by existing layout/snapshot tests if any.

- [ ] Commit as `IOS-6028 Include parent-object names in space card preview`.

### Task 3.3: Include parent-object counts in space card aggregate total

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Helpers/SpacePreviewCountersBuilder.swift` (`build` at lines 43–102)

- [ ] In the per-space iteration, switch the loop to iterate `[UnreadEntry]`. For each entry call `let decision = UnreadDecision.decide(for: entry, supportsMentions: supportsMentions)` and accumulate:
  - `totalUnread += decision.unreadCounterVisible ? entry.unreadCount : 0`.
  - `totalMentions += decision.mentionBadgeVisible ? entry.mentionCount : 0`.
- [ ] The existing chat-only mode switch at lines 57–71 collapses into the decision helper — `UnreadDecision.decide(for: .chat(...), supportsMentions:)` reproduces today's behavior verbatim.
- [ ] Verify the returned `totalUnread` / `totalMentions` reflect the combined sum across variants.
- [ ] Counter color (blue vs grey) is the renderer's job, driven by `decision.style` (wired via widget builder in Task 3.5a) — this task produces totals only.

- [ ] Tests: N/A here — `UnreadDecision` is exhaustively tested in Task 3.0b; this task is pure accumulation wiring.

- [ ] Commit as `IOS-6028 Include parent-object counts in space card totals`.

### Task 3.4: Add parent-object unread to app icon badge

**Files:**
- Modify: `Anytype/Sources/ServiceLayer/Badge/AppIconBadgeService.swift` (`updateBadge` at lines 63–97)

- [ ] Inject the new `ObjectsWithUnreadDiscussionsSubscription`.
- [ ] **Probe the current badge-trigger**: locate what causes `updateBadge` to re-run today (likely a Combine/async-sequence merge over `chatMessagesPreviewsStorage.previewsSequence` + `spaceViewsStorage`). Record the trigger site.
- [ ] Wire the new subscription's change stream into the **same trigger** — merge it so `updateBadge` re-runs when parent-object counts change. If you skip this step the badge will stay stale until some other event kicks it.
- [ ] Add a second aggregation loop over parent-object entries; one line per entry: `total += UnreadDecision.decide(for: .parentObject(...), supportsMentions: supportsMentions).badgeContribution`. The helper encodes all 8 truth-table rows (tested in Task 3.0b) — the call site does NO per-case branching.
- [ ] Chat loop at lines 81–91: refactor the switch to call `UnreadDecision.decide(for: .chat(...), supportsMentions:).badgeContribution` too — same accumulator, same behavior, single source of truth. This is a safe refactor because `UnreadDecision` reproduces the existing chat switch verbatim (asserted in Task 3.0b chat tests).
- [ ] **Prevent double-counting**: confirm `ChatMessagesPreviewsStorage` does NOT emit `.discussion`-layout entries (it filters by `.chatDerived`). If it does, de-dup: skip any chat entry whose `chatId` equals some parent's `discussionId`. Add a one-line probe log during implementation; **remove the probe log before the task's commit** (reviewer asserts absence at Chunk 3 hand-off).
- [ ] Badge is set via the existing `UNUserNotificationCenter.current().setBadgeCount(total)` call (line 96) and persisted to `badgeCountStorage` (line 95) — no change to the write path.

- [ ] Tests: N/A at call site — `UnreadDecision` carries the logic and is fully covered in Task 3.0b. Manual verification in Task 3.6 exercises the wiring.

- [ ] Commit as `IOS-6028 Include parent-object unread in app icon badge`.

### Task 3.5a: Extend `WidgetChatPreviewBuilder` to accept parent-object entries

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Builders/WidgetChatPreviewBuilder.swift`

- [ ] Context: "pinned widgets" here means in-app home widgets on the home widgets view (`HomeWidgetsViewModel` path) — not iOS WidgetKit extensions. Data flow runs in the app process via `@Injected` storage; no timeline/budget considerations.
- [ ] Add an overload to `build(...)` accepting `UnreadEntry.parentObject(...)`. Compute `let decision = UnreadDecision.decide(for: entry, supportsMentions: true)` (widget rows always support mentions) and populate `MessagePreviewModel` so that:
  - `unreadCounter = decision.unreadCounterVisible ? entry.unreadCount : 0`.
  - `mentionCounter = decision.mentionBadgeVisible ? entry.mentionCount : 0`.
  - Counter style (blue vs grey) maps from `decision.style` to the existing `MessagePreviewModel` styling fields. **Concrete mapping**: read `MessagePreviewModel+Presentation.swift:46–82` during implementation; pick the existing tokens that produce the two visual outcomes already used by chat rows in `.all` vs `.nothing` mode (blue-highlighted vs grey-muted). No new tokens, no new flag on `MessagePreviewModel`.
- [ ] Set `hasUnreadReactions = false` unconditionally (middleware does not forward reaction state to parent; revisit if a future middleware PR changes this).
- [ ] **No presentation-layer tweak**. `MessagePreviewModel+Presentation` stays untouched. `shouldShowUnreadCounter` and friends continue to gate chat behavior; the parent-object overload sets counter/mention counters directly per the decision, so parent rows don't exercise the `muteAndHide` hide-in-`.nothing` gate at all.
- [ ] Do NOT add a sibling/forked builder — keep one entry point with an overload.

- [ ] Tests: N/A — `UnreadDecision` inputs are covered in Task 3.0b; this overload is a field-copy.

- [ ] Commit as `IOS-6028 Extend WidgetChatPreviewBuilder for parent objects`.

### Task 3.5b: Wire parent-object rows into `MyFavorites`

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesRowView.swift` (only if verification reveals a change is needed)

- [ ] In `startChatCountersSubscription` (around lines 109–145), also consume the new `ObjectsWithUnreadDiscussionsSubscription` and look up rows by object id.
- [ ] Build `MessagePreviewModel` via the Task 3.5a overload.
- [ ] `MyFavoritesRowView:30` already renders badges based on `hasVisibleCounters` — no view change if the model is populated. Verify visually; only add view-level code if something's missing.

- [ ] Tests: N/A — view-wiring.

- [ ] Commit as `IOS-6028 Show parent-object unread on MyFavorites widget`.

### Task 3.5c: Wire parent-object rows into list-widget row builder

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Builders/WidgetRowModelBuilder.swift`

- [ ] Extend `buildListRows` (lines 29–44). Merge parent-object previews (from the new subscription) into the existing chat-preview lookup so `previewsByChatId[config.id]` at line 39 falls back to a parent-object preview when the id isn't a chat.
- [ ] `ListWidgetRow:22–26` renders automatically when `model.chatPreview` is non-nil.
- [ ] Respect the existing `shouldHideChatBadges` environment flag (collapsed-vs-expanded Unread section logic flows through unchanged).
- [ ] Widget gallery rows (`buildGalleryRows:23`) stay unchanged — chats don't render counters there either.

- [ ] Tests: N/A — view-wiring.

- [ ] Commit as `IOS-6028 Show parent-object unread on list widgets`.

### Task 3.6: Hand off to user for build + manual verification

- [ ] Scenarios: receive comment on a parent object → Unread section shows the object row with count and `@` badge if mention; space card preview-line includes the object name alongside chat names; space card total count reflects the add; app icon badge increments; pinned object widget (Favorites via 3.5b + list widgets via 3.5c) shows counter and mention indicator; mark all read → every surface clears in lockstep; muting the space silences all.
- [ ] Viewer account: confirm blue dot + Unread section row + widget counter show for Viewers (read-only doesn't hide unread state).
- [ ] No double-count: create a chat + a parent object with discussion in the same space, leave both unread; confirm app icon badge equals chat unread + parent unread (no duplication).
- [ ] Truth-table spot-check (user-side): for a parent object discussion toggle through "All New Replies" vs "Mentions Only" and mute the space → verify all 8 truth-table rows render correctly (blue vs grey, counter vs no counter, `@` badge presence).
- [ ] Stage + commit only if user asks.
- [ ] Tests: N/A — hand-off task.
- [ ] No commit for this task.
- [ ] **STOP. Open PR. Start Chunk 4 in a new session — or defer Chunk 4 and go to Post-Completion + Linear wrap-up.**

---

### 🟪 Chunk 4 — PR #4: Last-comment preview on object surfaces

> **Single-session scope.** Not implemented alongside Chunks 2 and 3. Kept documented here for future execution.

Surfaces covered: last-comment preview text in Set / Collection gallery + list cells, and list-widget rows, for parent objects that have a discussion. Reuses the existing `ChatMessagesPreviewsStorage` bulk stream via `details.discussionId` lookup.

### Task 4.0: Verify `chatSubscribeToMessagePreviews` includes discussions

**Files:**
- Probe: `Modules/Services/Sources/Services/Chat/ChatService.swift:91–96` (RPC call site) and middleware changelog / code for `chatSubscribeToMessagePreviews`.

- [ ] Subscribe to the bulk stream with a test account holding at least one discussion with a comment. Inspect `ChatMessagesPreviewsStorage.previews()` for an entry whose `chatId == discussionId` of the parent.
- [ ] **Record the probe result** as a ➕ note under this task before proceeding: paste a log snippet showing either the present discussion preview entry or the absence. This artifact unblocks the next implementer — without it the probe reads as TODO.
- [ ] If present → Chunk 4 is purely a client-side lookup-key change; proceed to Tasks 4.1–4.2.
- [ ] If absent → file a middleware ask (include `ot-discussion` chat objects in the `chatSubscribeToMessagePreviews` response). **Abandon the Chunk 4 session entirely** and re-open when middleware ships — do not proceed with Tasks 4.1–4.2 in the same session.
- [ ] No code changes in this task — probe only.
- [ ] Tests: N/A — probe only.
- [ ] No commit for this task — the ➕ note is recorded in the plan; a subsequent task's commit will carry it.

### Task 4.1: Extend set/collection builder to key by `discussionId`

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/TextEditor/Set/Views/Models/SetContentViewDataBuilder.swift` (`buildChatPreview` at lines 288–319; `chatPreviewsDict` at line 129)

- [ ] Change the dictionary-key resolution so a parent object's row looks up by `details.discussionId` when set, falling back to `objectId` for native chats.
- [ ] Cell renderers (`SetGalleryViewCell:34`, `SetListViewCell:18`) require no change — they render conditionally on `configuration.chatPreview` presence.
- [ ] Tests: N/A — lookup-key change only.
- [ ] Commit as `IOS-6028 Key set/collection preview by discussionId`.

### Task 4.2: Extend widget row builder to key by `discussionId`

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Builders/WidgetRowModelBuilder.swift` (line 39 — `previewsByChatId[config.id]` currently assumes id == chatId)

- [ ] Replace the lookup to prefer `details.discussionId` when present.
- [ ] `ListWidgetRow:22–26` renders automatically once the model is populated.
- [ ] Widget gallery rows stay unchanged.
- [ ] Tests: N/A — lookup-key change only.
- [ ] Commit as `IOS-6028 Key list-widget preview by discussionId`.

### Task 4.3: Hand off to user for build + manual verification

- [ ] Scenarios: add a parent object with discussion to a set/collection in gallery and list layouts — row shows last-comment preview with author; add the same to a list-widget in Favorites — row shows last-comment preview; chats remain unaffected; muted chats respect existing preview behavior.
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
- **Chunk 3**: receive comment on a parent object → appears in Unread section with count + `@` badge if mention; space card preview-line includes the object name; space card total reflects; app icon badge increments; pinned object widget in Favorites / list widgets shows counter + mention indicator; mute space silences all surfaces.
- **Chunk 4**: sets/collections gallery + list cells show last-comment preview on parent objects with a discussion; list widgets ditto; chats remain unaffected.

**External system updates**: none — pure client-side against already-merged middleware.

**Follow-up Linear tasks**:
- After Chunk 3 merges: consider filing a middleware task for reaction-heart forwarding (optional, only if design still wants parity).
- After Chunk 4 merges: move this plan to `docs/plans/completed/`.
