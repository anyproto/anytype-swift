# Chat and discussion activity: live typing and agent tool calls (iOS)

Status: **approved 2026-10-13, in implementation.** Linear: [IOS-6626](https://linear.app/anytype/issue/IOS-6626) (desktop GO-7368, GO-7585).
Date: 2026-10-13.

iOS ports desktop's live activity, which runs over heart pubsub. Space chats and object discussions will show who
is typing and what an agent is doing. The app will publish typing from the composer. The app does not publish
agent status.

Sources:
- the mobile handoff doc (private Claude Doc, `claude.ai/code/artifact/311d21aa-…`);
- heart [`docs/pubsub/CLIENTS.md`](https://github.com/anyproto/anytype-heart/blob/develop/docs/pubsub/CLIENTS.md) and [anytype-heart#3326](https://github.com/anyproto/anytype-heart/pull/3326);
- desktop [chat status spec](https://github.com/anyproto/anytype-ts/blob/develop/docs/plans/2026-09-25-chat-status-spec.md) and [discussion activity spec](https://github.com/anyproto/anytype-ts/blob/develop/docs/plans/2026-10-12-discussion-activity-spec.md). anytype-ts#2407 merged today, so the `develop` link works.

The desktop specs were used for behaviour only. This plan uses no desktop code or desktop UI structure.

---

## 1. Findings that shape the plan

| Area | Finding | Consequence |
|---|---|---|
| Middleware | `Libraryfile` pins **v0.51.3**. Its protos have no `Rpc.Pubsub.*`, no `Event.Pubsub.Message` and no `PubsubPublish/Subscribe/Unsubscribe` in `service.proto`. Pubsub first ships in **v0.51.4**. The latest release is **v0.51.5** (2026-10-03). | The middleware must be bumped first. From v0.51.3 to v0.51.5 the proto diff is additive: Pubsub, `Account.JsonApiStatus`, and `MembershipV2.FetchState` / `forceRefreshSec`. Heart #3317 (the DiscoveryProxy for GO-7576) is **not** in v0.51.5. |
| `reply_to` (#3326) | #3326 changes only heart's API v2 handler, which is the **publisher's** heart. It merged 2026-10-12 and is in `v0.51.6-nightly.20261013.1`, but in no release yet. | The app's own heart does not need #3326: it receives `reply_to` as opaque payload bytes. Testing discussion placement needs a publisher heart that has #3326, such as desktop develop or today's nightly. |
| Event routing | Events reach `EventBunchSubscribtion.default`. Every `switch event.value` has `default: break`, so a new oneof case compiles untouched. The smallest listener pattern to copy is `P2PStatusStorage` or `DiscussionMessageCountObserver`. | Add one pubsub listener. No existing switch needs to change. |
| Typing UI | **iOS has no typing indicator, no "is typing" label and no dots component.** The only animated pieces are spinners (`CircleLoadingView`). | "Reuse the existing typing indicator" has nothing to reuse on iOS. See Q5. |
| Settings | iOS has no Messaging settings. Settings → Application holds Appearance, Notifications (system permission status only), Login key and Membership. Per-device toggles live in `UserDefaultsStorage` + `AnytypeToggle`, as in `FileStorageView`'s cellular toggle. | The toggle needs a home. See Q4. |
| Chat list | UIKit `UICollectionView` (`ChatCollectionView`), oldest first, not inverted. It uses day sections and the item enum `MessageSectionItem { message, unread, discussionDivider }`. `ChatContainerCell` rebuilds only when its item value changes. | Runs become a new item case. Live updates must come from an observable model inside the cell, not from snapshot churn. |
| Chat composer | `ChatInput` → `ChatTextView` → `ChatTextViewCoordinator` (`textViewDidChange` fires only on user edits). Chat and Discussion both use it. **There is no draft restore** in chat or discussions. | Typing hooks into the user-edit callback, so programmatic text such as edit prefill or `clearInput` never publishes. |
| Chat lifecycle | `ChatView` has no `onDisappear` and no scene-phase handling. Teardown happens when SwiftUI cancels `.task` or the VM deinits. Background state flows through `SceneStateNotifier` / `SceneStateListener`. | Leave = `.task` cancellation, which fires on pop and when another screen is pushed on top, but not for a sheet. Background = a `SceneStateListener`. |
| Discussions | A discussion is a chat object with its own `DiscussionMessagesStorage`. The list is flat (`root, replies…, divider, root…`), one level deep. Replies always target the **root post id** (`resolveRootParentId`). Loading is **paginated** (100 per page), and orphan replies are hidden. Deleted comments are **removed**, not tombstoned. `chatId` is nil until the first comment creates the discussion. | Thread lookup reuses `DiscussionThreadGrouper.findRootParent`. The "not loaded" case is far more common than on desktop, which loads everything (Q7). Typing waits for `chatId`. |
| Identity | Own identity is `accountManager.account.id`, which equals `Participant.identity` and `ChatMessage.creator`. | The typing filter hides the own account. Status is never filtered by account. |
| Accessibility | Chat has almost no a11y annotations and no `AccessibilityNotification` use. The only reduce-motion precedent is `VaultSearchBarButton`. | Labels and announcements are new but small. |
| Tests | `AnytypeTests` uses Swift Testing (`@Suite`, `@Test`, `#expect`). Pure-logic tests to mirror: `ChatInputLinkParserTests`, `ChatMessageLimitsTests`. Event-driven: `DiscussionMessageCountObserverTests`. | All rules live in pure value types with an injected `now`. |

---

## 2. Design research: native agent UIs

I looked for open-source, native Apple clients (SwiftUI or UIKit) that render tool calls or typing. I read the source of four. None was built or run.

| Reference | Running / finished / failed, compact | Details open | Raw args and results |
|---|---|---|---|
| [GetStream/stream-chat-swift-ai](https://github.com/GetStream/stream-chat-swift-ai) (iOS, SwiftUI): [`AIToolCallView.swift`](https://github.com/GetStream/stream-chat-swift-ai/blob/main/Sources/StreamChatAI/UI/MessageParts/AIToolCallView.swift), [`AITypingIndicatorView.swift`](https://github.com/GetStream/stream-chat-swift-ai/blob/main/Sources/StreamChatAI/UI/Message/AITypingIndicatorView.swift) | Each call is one row: a 16pt icon, a title, a 2-line detail and a trailing duration. Running shows a mini `ProgressView`; completed and failed show a bold success- or failure-tinted icon; cancelled is grey. Unknown status falls back to running. There is no group row and no counts. The typing indicator is a text label plus 3 pulsing dots, with a single agent only and no reduce-motion check. | Nowhere: the row is the whole UI. | Never. The README warns that arguments are visible to every channel member, so publishers should send short human summaries. |
| [github/CopilotForXcode](https://github.com/github/CopilotForXcode) (macOS, SwiftUI): [`ToolStatusItemView.swift`](https://github.com/github/CopilotForXcode/blob/main/Core/Sources/ConversationTab/Views/ConversationAgentProgressView/ToolStatusItemView.swift), [`ConversationAgentProgressView.swift`](https://github.com/github/CopilotForXcode/blob/main/Core/Sources/ConversationTab/Views/ConversationAgentProgressView/ConversationAgentProgressView.swift), [demo GIF](https://github.com/github/CopilotForXcode/blob/main/Docs/Images/chat_agent.gif) | Each call is one line: a 16pt status icon (small spinner, `checkmark`, or red `xmark`) and a 1-line secondary-colour message. There is no run-level summary. | **Inline** chevron disclosure, only for MCP tools, file edits and errors. Inline works because macOS has the width. | MCP "Input/Output" is shown as markdown to everyone, with no copy button and no JSON formatting. |
| [aaif-goose/goose-mobile](https://github.com/aaif-goose/goose-mobile) (iOS, SwiftUI): [`StackedToolCallsView.swift`](https://github.com/aaif-goose/goose-mobile/blob/main/goose-ios/Goose/StackedToolCallsView.swift), [`ToolViews.swift`](https://github.com/aaif-goose/goose-mobile/blob/main/goose-ios/Goose/ToolViews.swift) | Calls are cards stacked like a deck (3 visible, "+N more"). Running shows a spinner and done shows a green check. There is **no failed state**. | Tap opens a carousel; long-press pushes a **new screen** through a hidden `NavigationLink`. | Arguments appear as truncated `key: value` lines (40 characters) in monospace. Results are not shown. |
| [element-hq/element-x-ios](https://github.com/element-hq/element-x-ios) (iOS, typing only): [`TypingIndicatorView.swift`](https://github.com/element-hq/element-x-ios/blob/develop/ElementX/Sources/Screens/Timeline/View/TypingIndicatorView.swift) | Text only: "Alice is typing…", "Alice and Bob are typing…", "Alice, Bob and N others are typing…". It is a real timeline row, kept at a **stable height** with a hidden placeholder. | — | — |

The desktop spec already covers web references: assistant-ui, LibreChat, OpenHands, ACP, Vercel AI Elements and Open WebUI.

**Recommendation: a compact run line that opens a bottom sheet.** This is what the handoff asks for, and it needs the fewest new parts.
- **Line:** follow Copilot and Stream: one secondary-colour line with `lineLimit(1)` and a trailing state glyph (dots, check, or error). The run-level summary ("3 tool calls · 1 running") is ours; none of the references has one.
- **Sheet instead of inline:** inline expansion inside a self-sizing collection cell makes heights jump in a lazy list. Element avoids the same instability with a fixed-height typing row. A medium sheet keeps the timeline still and reuses `.mediumPresentationDetents()` + `DragIndicator` + title, as `MessageParticipantsReactionView` does.
- **Avoid goose's design:** the stack, carousel and pushed screen are heavy and fragile.
- **Raw JSON:** no reference shows it by default, and Stream warns against it in shared chats. This agrees with the handoff: show no JSON on screen, and offer "Copy as JSON" for the whole run in the sheet's "…" menu (Decision 1).
- **Reduced motion:** none of the references honours it. We will show static dots when reduced motion is on.

---

## 3. Architecture

```
 heart ── Event.Pubsub.Message ──▶ PubsubEventListener ──▶ ChatActivityStore (@MainActor, app-process lifetime)
   ▲                                                         │  per scope (account, space, chatId):
   │ Rpc.Pubsub.Subscribe/Unsubscribe ◀── ActivitySubscriptions   ├─ TypingRoster          (pure)
   │ Rpc.Pubsub.Publish ◀── TypingPublisher ◀── composer          ├─ ChatActivityJournal   (pure, chat | discussion mode)
   │                          (TypingPublishPolicy, pure)         └─ per-run / per-chat @Observable projections
   │                                                         ▼
 chat .chatAdd / .chatDelete (EventBunch) ──▶ boundaries ──▶ ChatMessageBuilder / DiscussionMessageBuilder
                                                              (+ DiscussionActivityPlacement, pure)
                                                         ▼
                                    ChatActivityRowView · ActivityRunLineView · ActivityRunSheetView
```

All rules are pure value types with an injected `now: Date`, so they are deterministic and unit-testable. Thin
`@MainActor` drivers own the timers, the RPCs and the observation.

### 3.1 Pubsub layer

- **`PubsubService`** (`Modules/Services/Sources/Services/Pubsub/`). It wraps `ClientCommands.pubsubSubscribe(spaceId, topics, subId)`, `pubsubUnsubscribe(subId)` and `pubsubPublish(spaceId, topic, payload)`. It is registered in `Modules/Services/.../ServicesDI.swift`.
- **`PubsubMessage`** model: `spaceId` (from `Event.Message.spaceID`), `topic`, `payload: Data`, `identity` (verified) and `subIds`.
- **`PubsubEventListener`** (`ServiceLayer/ChatActivity/`). It makes one `EventBunchSubscribtion` handler, keeps `.pubsubMessage` events and yields `PubsubMessage`s. Pattern: `P2PStatusStorage`.
- **`PubsubSession.id`**: 8 random bytes as hex, generated once per process. It is used as the typing `sessionId` and in `subId`s.
- **`ActivitySubscriptions`** (refcounted by `(spaceId, objectId)`):
  - The first `retain` subscribes `subId = "activity-<sessionId>-<objectId>"` to `typing/<objectId>` and `status/<objectId>`. That is 2 of the 100 patterns per space, as the doc budgets.
  - The last `release` unsubscribes.
  - On `willEnterForeground` it re-issues Subscribe for live subIds. This is idempotent, because reusing a subId replaces its topic set, and it is cheap insurance against lost interest after reconnect (R2).
  - Errors are logged and never surfaced.
- **Publish** is fire-and-forget in a detached `Task`, with no queue and no retry. Payloads over 65,508 bytes are refused locally; typing payloads are tiny.

### 3.2 Typing sender: `TypingPublishPolicy` (pure) + `TypingPublisher` (driver)

Payload: `{"sessionId":"…","active":true}`. A discussion reply adds `"replyTo":"<root post id>"`. Never `blockId` or `range`.

| Input | Policy output |
|---|---|
| `userEdited(nonEmpty, replyTo, now)` with not active, or replyTo changed | publish `active:true` now |
| `userEdited` again while active | republish `active:true` if ≥ 2 s since the last publish, else nothing |
| `userEdited(empty)` (composer emptied) | publish `active:false` if owed |
| `replyTargetChanged(replyTo)` while active | publish `active:true` now, bypassing the throttle |
| `tick(now)` with ≥ 3 s since the last edit | publish `active:false` if owed |
| `stop` (send, blur, leave screen, background, setting turned off, edit mode entered, write rights lost) | publish `active:false` **only if owed**, meaning the last state sent was `active:true` |
| `canPublish == false` (setting off, flag off, no write rights, editing an existing message, discussion not created) | nothing new; an owed stop still goes out |

Driver hooks:
- **Text:** add `onUserTextChange` to `ChatTextViewCoordinator.textViewDidChange`, then pass it through `ChatTextView` → `ChatInput` → VM. Cursor moves, focus alone, `clearInput` and edit prefill never reach the policy.
- **Blur:** `.onChange(of: inputFocused)` becoming false.
- **Send:** the start of `sendMessageTask`.
- **Leave:** cancellation of `.task(id: chatId)`.
- **Background:** the store's `SceneStateListener` stops every live publisher.
- **Reply target:** in discussions, `didSelectReplyTo` / `onTapDeleteReply`.
- **Idle timer:** one cancellable `Task.sleep` per publisher.

### 3.3 Typing receiver: `TypingRoster` (pure)

1. Drop the message if `sessionId == PubsubSession.id`, if `identity == own account id`, if it has no `sessionId`, if it has a non-empty `blockId`, or if the JSON is malformed.
2. Key entries by `(identity, sessionId)` and stamp them with local receipt time. `active:false` removes the entry. Keep `replyTo` as received.
3. A 1 s sweep drops entries older than 5 s. A `chatAdd` from that identity clears its entries.
4. Output is one entry per identity, whatever its session count. Identities with **fresh agent activity** are hidden: a text-only status or an item updated in the last 10 s.
5. The view layer resolves names and avatars from `ParticipantsSubscription`. Unknown participants are skipped. Labels are "Anna is typing", "Anna and Ben are typing" and "Anna and 3 others are typing".

### 3.4 Activity journal: `ChatActivityJournal` (pure)

One journal per scope `(accountId, spaceId, chatId)`, kept in memory for the life of the app process. It collects only while the screen is open and survives navigation away and back.

- **Decode** (`StatusPayload` + `ActivityJSON`):
  - `text`: blank or non-string means nil, shown as localized "Typing". It applies per event.
  - `reply_to`: a non-empty string, otherwise absent.
  - `data`: an order-preserving JSON value. Number lexemes are kept, nesting is capped at 128, and anything over 65,508 bytes is rejected. A small hand-written parser is needed, because `JSONSerialization` and `JSONDecoder` lose key order and big-number precision.
- **Three kinds:**
  - **Text only** (no data, `{}`, `null`, `[]` or `""`): a transient status per sender. It expires 10 s after receipt, a message from that sender clears it, and it is never retained.
  - **Tool call** (`data.tool_call_id` is a non-empty string): a retained item.
  - **Other data:** a retained generic item. Consecutive equal snapshots from one sender, compared by text plus canonical data, count once.
- **Same-id reducer:**
  1. Look up `(identity, tool_call_id)` first.
  2. A new id becomes a new item in the open run, even if first seen as `complete` or `error`.
  3. A known id updates its item wherever it sits. It never moves and never changes counts.
  4. Shallow-merge the top-level data fields that are present. Existing keys keep their position and new keys are appended. A present `result` replaces the old one whole (presence, not truthiness).
  5. Lifecycle only moves `in_progress → complete | error`. Once an item is terminal, an event with a *different explicit* status is dropped whole. A missing or unknown status on a new item shows no badge.
  6. Freshness is separate from lifecycle: an item is live while updated within 10 s.
- **Runs, chat mode:**
  - There is one open run per chat, anchored after the **known tail** message when it opens.
  - A new tail message from anyone closes it. "New" means `chatAdd` with an `orderId` above the known tail, deduplicated by id. History pages, late inserts, edits, reactions and deletions are not boundaries. Text-only events, idle time and expiry never split a run.
  - On re-attach, if the tail moved while the screen was closed, the open run is closed.
- **Runs, discussion mode:**
  - There is one open run per sender, and it takes `replyTo` from its first event.
  - Only that sender's own comment closes it, with `closedBy = comment`.
  - A new item from that sender with a different `reply_to` closes the run without a comment and opens a new one.
  - Text-only status and updates to known calls never close a run.
- **Run summary:**
  - Counts are of distinct calls: "3 tool calls · 1 running · 1 failed". A run mixed with generic items reads "4 activities".
  - The summary also carries the latest text.
  - The trailing state is `failed` > `running+fresh` (dots) > `running+stale` (no dots; the sheet shows "No recent updates") > `completed`.
- **Accessibility transitions:** the journal emits "run finished" or "run failed" once per run, never on a heartbeat.

### 3.5 Discussion placement: `DiscussionActivityPlacement` (pure)

Input:
- runs;
- transient statuses;
- typers;
- `threadRoot(of messageId) -> String?`: `DiscussionThreadGrouper.findRootParent` over loaded messages, nil if the message is not loaded or is an orphan;
- the set of loaded ids;
- the set of deleted ids, recorded from `.chatDelete`.

Output: `attached[commentId]`, `threads[rootId]` and `root`.

- **Finished run** with a loaded `closedBy` goes to `attached`. If `closedBy` was deleted, the run is hidden.
- **Everything else** goes to `threads[threadRoot(replyTo)]`, or to `root` when unresolved. "Everything else" means open runs, runs closed by a `reply_to` change, text-only status and typing.
- **Late load:** placement is recomputed on every list build, so activity moves into its thread when the message loads.
- **Paging (proposed iOS deviation, Q7):** a finished run whose closing comment arrived, but is paged out of the window, stays hidden until the comment loads. It does not pile up at the root level.

### 3.6 UI (existing components; only the typing row is new, see Q5)

- **`ChatActivityRowView`** is the shared row:
  - stacked participant `IconView`s, at the same 20pt as the comment header;
  - one truncated `AnytypeText` line in a caption style, `Color.Text.secondary`;
  - a trailing glyph.
  - It serves typing ("Anna is typing"), text-only status ("Agent · Searching docs") and, wrapped in a `Button`, the compact run line ("Agent · 3 tool calls · 1 running · Reading the timetable"). For mixed senders it shows stacked avatars and the typing-label name join.
- **Chat:**
  - Runs: a new `MessageSectionItem.activityRun(id:)`. It is emitted by `ChatMessageBuilder` right after its anchor message, or at the top of an empty or fully loaded chat. Its `tracked*` is nil.
  - Typing and text-only status: a row at the top of `ChatView.bottomPanel`. It is also shown to readers without write rights.
- **Discussion:**
  - Attached runs go in `MessageViewData.activityRunIds`, rendered between header and body in `DiscussionMessageView`.
  - Thread activity is a new item, `.activityThread(rootId)`, emitted after the thread's last reply only while non-empty.
  - Root-level activity goes at the top of `DiscussionView.bottomPanel`. The row must be moved out of the `canEdit` branch.
- **Live updates without list churn:**
  - The store keeps one `@Observable` model per run and per chat roster, and assigns to it only when the projected value changes.
  - Cells observe their model, so heartbeats and the 1 s sweep never re-apply the diffable snapshot.
  - A list rebuild happens only when placement membership changes: a run appears, closes or moves, or a typer enters or leaves a thread.
- **`ActivityRunSheetView`** (`.sheet(item:)` + `.mediumPresentationDetents()`, `DragIndicator` + title):
  - It lists the run's calls in first-seen order.
  - Each call shows its tool name ("Tool call" if missing), a status icon plus label (Running, Completed, Failed, or No recent updates), the latest `text`, and metadata as `key: value` rows. Objects show as "Object(3)" and arrays as "Array(8)". `result`, `tool_call_id`, `tool_name` and `status` are excluded from the rows.
  - The sheet header has a "…" `Menu` → "Copy as JSON", which copies every call of the run (Decision 1).
  - The sheet updates live, keeps its scroll position (stable ids) and never opens on its own. It has no actions.
- **Scroll:**
  - New run items rely on the coordinator's existing rule: follow only if the reader was within 30pt of the bottom.
  - In-place updates never touch the snapshot.
  - The bottom-panel row changes the inset. The container re-pins only when near the bottom. A stable reserved height is an option (Q5).
- **Accessibility:**
  - The run line is a `Button` with `.accessibilityElement(children: .combine)` and a label like "Agent, 3 tool calls, 1 running".
  - `AccessibilityNotification.Announcement` is posted once per transition from the journal.
  - The dots are static under `accessibilityReduceMotion`.
  - Icons differ in shape, so status does not rely on colour.
  - The agent's `text` and JSON keys are never translated.

### 3.7 Setting

- Storage: `UserDefaultsStorage.sendTypingIndicator`, `@UserDefault("UserData.SendTypingIndicator", defaultValue: true)`, per device, kept across logout (Decision 3).
- UI: `AnytypeToggle` "Show others when I'm typing" on the Notifications settings screen (Decision 4).
- Effect:
  - Off: `canPublish = false`, and a stop that is owed still goes out.
  - Off never hides other people's typing.
- Gated by the feature flag.

### 3.8 Lifecycle and cleanup

- **Chat:** `ChatView` `.task(id: chatId)` calls `store.attach(scope)`, which retains the subscription and sets the tail. Cancellation calls `detach`, which sends an owed stop and releases the subscription. Journal history is kept.
- **Discussion:**
  - Attach only once `chatId != nil`.
  - On `createDiscussionIfNeeded` success, attach. Typing starts with the next edit.
- **Background:** owed stops are sent and subscriptions are kept. **Foreground:** subscriptions are re-issued.
- **Logout / account switch:** `LoginStateService.stopSubscriptions` → `store.clearAll()` (unsubscribe all, drop journals).
- **Space access loss:** drop that space's scopes when the space leaves `participantSpacesStorage` or stops being active. I could not find an explicit hook, so this needs verifying in the implementation.

### 3.9 Feature flag and strings

- **Flag:** `FeatureFlags.chatActivity` (`.productFeature`, default `false`, debug `true`). It gates subscribing, publishing, all rows and the setting.
- **Strings** go in `Workspace.xcstrings`. Plurals use the `Chat.AttachmentsError.LimitExceeded` structure with `%d`. Keys:
  - `Chat.Typing.One` / `Two` / `Many` (plural)
  - `Chat.Activity.DefaultText` ("Typing")
  - `ToolCall`
  - `ToolCalls` (plural)
  - `Activities` (plural)
  - `Running` / `Failed` counts
  - status labels: Running, Completed, Failed, No recent updates
  - `CopyAsJson`
  - accessibility announcement strings
  - the setting title (and section title, if Q4 needs one)

---

## 4. Files (as implemented)

**New**
- `Modules/Services/Sources/Services/Pubsub/PubsubService.swift`: the three RPC wrappers.
- `Anytype/Sources/ServiceLayer/ChatActivity/`:
  - `Payloads/ActivityJSON.swift`: order- and lexeme-preserving JSON.
  - `Payloads/ChatActivityPayloads.swift`: typing and status payloads, topic parsing.
  - `Typing/TypingPublishPolicy.swift` (pure) and `Typing/TypingRoster.swift` (pure).
  - `Journal/ChatActivityJournal.swift` (pure, chat and discussion modes).
  - `Journal/DiscussionActivityPlacement.swift` (pure).
  - `ChatActivityState.swift`: per-chat `@Observable` projection and per-run `ActivityRunModel`.
  - `ChatActivityStore.swift`: subscriptions, the serial pubsub command queue, event intake, the 1 s sweep and logout cleanup.
  - `ChatTypingPublisher.swift`: per-composer driver.
- `Anytype/Sources/PresentationLayer/Modules/Chat/Activity/`:
  - `ChatActivityController.swift`: per screen; also `ChatActivityTimelineRuns.make` (pure).
  - `ChatActivityText.swift`: localized labels.
  - `Views/`: `TypingDotsView` (a `CAReplicatorLayer` pulse), `ChatActivityRowView` with its run and composer variants, `ChatActivityRunSheetView`, `DiscussionActivityViews`.
- `AnytypeTests/ChatActivity/`:
  - `ActivityJSONTests` (+ payloads)
  - `TypingTests` (policy + roster)
  - `ChatActivityJournalTests` (chat, discussion, placement, timeline)
  - `ChatActivityTextTests`

**Changed**
- Middleware and generated code: `Libraryfile` (v0.51.6) and the regenerated `Modules/ProtobufMessages/Sources/{Protocol,Generated}`.
- Chat:
  - `ChatViewModel` and `ChatView`: attach on `.task`, typing hooks, the run sheet, rows above the composer.
  - `ChatInputPanel`.
  - `ChatMessageBuilder`: a closed run sits before the message that closed it; the open run follows the tail.
  - `MessageSectionItem`: `.activityRun`, `.activityThread`.
  - `ChatMessagesStorage.lastMessage`.
  - `ChatInput`, `ChatTextView` and `ChatTextViewCoordinator`: `onUserEdit`, fired from `textViewDidChange` only.
- Discussion:
  - `DiscussionViewModel` and `DiscussionView`.
  - `DiscussionMessageBuilder`: `.activityThread` after a thread with activity.
  - `DiscussionMessageView`: attached runs under the header, observed from the controller, so `MessageViewData` is unchanged.
- Settings:
  - `PushNotificationsSettingsView` and its view model: the toggle.
  - `UserDefaultsStorage.sendTypingIndicator` (+ test mock).
- Shared:
  - `LoginStateService`: `clearAll()` on logout.
  - `FeatureDescription+Flags.swift`: `chatActivity`.
  - `Workspace.xcstrings`: `Chat.Activity.*`.

## 5. Phasing

1. **PR 0: middleware bump** to the v0.51.6 nightly and regenerated protos. No behaviour change. It could ship on its own.
2. **PR 1: pure logic plus transport**, with all unit tests. It covers the pubsub service and listener, subscriptions, JSON, policy, roster, journal, placement and store. Everything is dark behind the flag.
3. **PR 2: chat.** Typing send and receive, run lines, the sheet, the setting and accessibility.
4. **PR 3: discussions.** `replyTo`, placement, attached runs and thread and root rows.

## 6. Acceptance checks → verification

Agent cases are driven with the MCP tool `publish-chat-status` or with `POST /v2/spaces/{id}/chats/{id}/status` against a heart that has #3326. Typing cases use a second device.

| # | Check (handoff) | Unit test | Manual |
|---|---|---|---|
| 1 | Typing shows within 1 s. It clears 3 s after the last keystroke, or at once on send. | `TypingPublishPolicyTests`: first edit publishes now; idle stop at 3 s; stop on send. `TypingRosterTests`: `active:false` removes. | two devices |
| 2 | Force-quit clears the row on the other device within 5 s. | `TypingRosterTests`: an entry is gone at 5 s with the 1 s sweep. | kill app |
| 3 | Cursor moves or a reopened draft publish nothing. | Policy runs only on `userEdited`. Test: programmatic text (edit prefill, `clearInput`) yields no publish. iOS has no draft restore today. | move cursor |
| 4 | Setting off: the peer sees no typing in chats or comments, and this device still sees others. | Policy: `canPublish=false` publishes nothing; an owed stop is sent when switched off mid-typing. Roster is unaffected by the setting. | two devices |
| 5 | Reply composer typing shows at the thread end; main composer typing shows at discussion level. | Policy carries `replyTo` and republishes at once on change. `DiscussionActivityPlacementTests`: `replyTo` goes to the thread and nil goes to the root. | two devices |
| 6 | Start, progress and complete for one `tool_call_id` give one item, count 1. | `ChatActivityJournalTests` | MCP tool |
| 7 | A message between A's start and finish keeps A in run 1, and B opens run 2. | `ChatActivityJournalTests` (boundary by tail `orderId`) | MCP + send |
| 8 | A late `in_progress` after `complete` does not regress. | `ChatActivityJournalTests` | MCP tool |
| 9 | A silent running call shows "No recent updates" after 10 s, never "Failed". | Journal summary at 9.9 s and 10 s: `running+stale` and the label. | wait 10 s |
| 10 | A failed call shows on the compact line. | Summary trailing state is `failed`, with the failed count. | visual |
| 11 | With no `reply_to`: running line at root, then the agent's comment with the finished run under its header. | `DiscussionActivityJournalTests` (closedBy) + placement `attached`. | MCP + comment |
| 12 | `reply_to` naming a deep reply goes to that thread's end; an unloaded id starts at root and moves in when loaded. | Placement: deep reply → root id; unknown id → root; same input with the message loaded → thread. | deep link + paging |
| 13 | Another person commenting does not split the agent's run. | `DiscussionActivityJournalTests` | two accounts |
| 14 | An agent under the user's own account still shows. | Store and listener tests: status from own identity is accepted, and typing from own identity is dropped. | MCP with own key |
| 15 | Updates never scroll the reader, and VoiceOver announces a status change once. | Journal emits each transition once and not on heartbeats. | VoiceOver, scrolled-up reader |

Extra unit coverage:
- result replacement with `null`, `false`, `0` and `""`;
- unknown status shows no badge;
- equal snapshots dedup;
- text-only expiry and clearing by a message;
- `blockId` entries ignored;
- malformed or oversized payloads ignored;
- key order and big numbers preserved by `ActivityJSON`;
- refcounted subscribe and unsubscribe, with a deterministic subId;
- `clearAll` on logout.

---

## 7. Decisions (2026-10-13)

| # | Question | Decision |
|---|---|---|
| 1 | Tool results on mobile | No JSON on screen. The sheet's "…" menu has **Copy as JSON**, which copies **all tool calls of the run** (merged `data` including `result`, first-seen order). It is available to every user, not only in debug builds. |
| 2 | Process death | Accepted. Activity is not persisted. |
| 3 | Setting scope | **Per device.** It survives logout and account switch; it is not cleared in `cleanStateAfterLogout`. |
| 4 | Setting placement | The **Notifications** settings screen. |
| 5 | Typing indicator | Build it from existing atoms. The dots are a compact, GPU-driven animation: a `CAReplicatorLayer` with one `CABasicAnimation` runs in the render server, with no per-frame main-thread work. They are static under Reduce Motion. |
| 6 | Middleware | Bump to the **v0.51.6 nightly**, which includes Pubsub, #3326 and #3317. |
| 7 | Discussion paging deviation | Accepted. A finished run whose comment is paged out stays hidden until that comment loads. |
| 8 | Mixed senders | No multi-agent use is planned. Keep the cheap version (stacked avatars and joined names) and don't build anything more. |
| 9 | Ticket | Created: IOS-6626. |

## 8. Risks

- **R1 Tombstones.** v0.51.6 includes heart GO-7167: a deleted discussion comment stays as a tombstone (`ChatMessage.deleted = true`) instead of `chatDelete`. Activity placement treats tombstones as deleted. The rest of the iOS discussion screen does not handle tombstones yet: they would render as empty comments with actions. That needs its own ticket (desktop: GO-7584).
- **R2 Background.** It is unverified whether heart keeps pubsub interest across iOS suspension and reconnect. Re-subscribing on foreground mitigates this. To be checked on device.
- **R3 Performance.** Heartbeats every ~2 s per agent and a 1 s sweep must not re-render the chat. Per-run observable models, projection only on change, and no snapshot re-apply on heartbeats are required for this. Relevant: the chat CPU and rendering findings from earlier work.
- **R4 Own-account agents in discussions.** The user's own comment closes their agent's run. This is a known limitation from the handoff; the payload cannot tell the two apart.

## 9. Review outcome (Codex, two passes, 2026-10-13)

Codex (gpt-6-astra, max effort) reviewed the change in four lenses: compile correctness, spec and logic, concurrency and lifecycle, and UI and tests. It then re-ran the logic and concurrency lenses on the fixes. Fixed:
- read tracking that skips activity rows;
- chat runs closed only by live `chatAdd`, with the tail snapshot used just as a baseline that a chat waits for before attaching;
- gap reconciliation using only snapshots taken after a return;
- open runs that follow the loaded tail, so a deleted newest message doesn't hide them;
- typing cleared only by new messages, and freshness counting only accepted events;
- observer tokens and run counting for overlapping `.task`s;
- event-handler registration before the first Subscribe;
- discussion placement split so comments don't re-render on typing;
- VoiceOver announcing once per run and saying the run's state;
- Reduce Motion, invalid UTF-8, and lost-space and logout cleanup.

Rejected, per the desktop spec or handoff:
- generic dedup ignoring freshness;
- generic dedup across tool events;
- localizing `Object(n)` / `Array(n)`.

Known limits:
- A run opened in an empty chat whose closing message is later deleted has no place to render.
- The logout goodbye is queued after the middleware stops, so peers rely on the 5 s expiry.
- `ChatActivityStore` itself has no unit tests yet.
