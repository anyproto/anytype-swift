# IOS-5995: Add Discussion Analytics Events

## Overview
Add three analytics events (StartDiscussion, PostDiscussion, ReplyDiscussion) to track user engagement with the object discussion/comments feature. These events fire only from `DiscussionViewModel` (object comments), not from `ChatViewModel` (space chats). Replaces the existing `logSentMessage` call in `DiscussionViewModel`.

## Context (from discovery)
- Files/components involved:
  - `Anytype/Sources/Analytics/AnalyticsConstants.swift` — property keys and enums
  - `Anytype/Sources/Analytics/AnytypeAnalytics/AnytypeAnalytics+Events.swift` — event log methods
  - `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionViewModel.swift` — message sending logic
- Related patterns: `AnytypeAnalytics.instance()` called inline (never stored as property) — established convention across 30+ call sites in `DiscussionViewModel` and `ChatViewModel`
- `hasMention` property key already exists in `AnalyticsEventsPropertiesKey`; `hasAttachments` does not
- `.chatMention` NSAttributedString attribute marks mentions in the message input
- `linkedObjects` array on ViewModel holds pending attachments
- `chatId == nil` before `createDiscussionIfNeeded()` indicates first comment on an object
- `replyToMessage != nil` indicates a reply to an existing post

## Development Approach
- **testing approach**: Regular (code first)
- complete each task fully before moving to the next
- make small, focused changes
- no new enums or route types needed — events only have boolean properties
- use `AnytypeAnalytics.instance()` inline per codebase convention

## Firing Rules
| Condition | Events Fired |
|-----------|-------------|
| Reply (`replyToMessage != nil`) | `ReplyDiscussion` only |
| Top-level + first comment (`chatId` was nil) | `StartDiscussion` + `PostDiscussion` |
| Top-level + subsequent comment | `PostDiscussion` only |

## Event Properties (shared by all 3 events)
| Property | Type | Detection |
|----------|------|-----------|
| `hasMention` | Bool | NSAttributedString contains `.chatMention` attribute |
| `hasAttachments` | Bool | `linkedObjects.isNotEmpty` |

## Implementation Steps

### Task 1: Add `hasAttachments` property key

**Files:**
- Modify: `Anytype/Sources/Analytics/AnalyticsConstants.swift`

- [x] Add `static let hasAttachments = "hasAttachments"` to `AnalyticsEventsPropertiesKey` (next to existing `hasMention`)
- [x] Run tests — must pass before next task

### Task 2: Add three analytics log methods

**Files:**
- Modify: `Anytype/Sources/Analytics/AnytypeAnalytics/AnytypeAnalytics+Events.swift`

- [x] Add `logStartDiscussion(hasMention: Bool, hasAttachments: Bool)` — logs event `"StartDiscussion"` with `hasMention` and `hasAttachments` properties
- [x] Add `logPostDiscussion(hasMention: Bool, hasAttachments: Bool)` — logs event `"PostDiscussion"` with same properties
- [x] Add `logReplyDiscussion(hasMention: Bool, hasAttachments: Bool)` — logs event `"ReplyDiscussion"` with same properties
- [x] Run tests — must pass before next task

### Task 3: Wire analytics into DiscussionViewModel

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionViewModel.swift`

- [x] In `sendMessageTask()`, capture `isFirstComment = (self.chatId == nil)` **before** `createDiscussionIfNeeded()` (which mutates `self.chatId`)
- [x] Compute `hasMention` by enumerating `message` NSAttributedString for `.chatMention` attribute
- [x] Compute `hasAttachments` as `linkedObjects.isNotEmpty`
- [x] Replace `logSentMessage(type:chatId:)` call with conditional logic:
  - If `replyToMessage != nil` → `logReplyDiscussion(hasMention:hasAttachments:)`
  - Else if `isFirstComment` → `logStartDiscussion(...)` + `logPostDiscussion(...)`
  - Else → `logPostDiscussion(hasMention:hasAttachments:)`
- [x] Run tests — must pass before next task

### Task 4: Verify acceptance criteria

- [x] Verify all 3 events use correct event names: `StartDiscussion`, `PostDiscussion`, `ReplyDiscussion`
- [x] Verify `hasMention` and `hasAttachments` properties are included in all 3 events
- [x] Verify `StartDiscussion` only fires for first comment (when `chatId` was nil)
- [x] Verify `StartDiscussion` always fires together with `PostDiscussion`
- [x] Verify `ReplyDiscussion` fires independently (no `PostDiscussion`)
- [x] Verify no duplicate events on a single user action
- [x] Verify `logSentMessage` is removed from `DiscussionViewModel`

### Task 5: Final cleanup

- [ ] Move plan to `docs/plans/completed/`

## Post-Completion

**Manual verification:**
- Test in simulator: post first comment on an object → verify StartDiscussion + PostDiscussion fire
- Test: post second comment → verify only PostDiscussion fires
- Test: reply to a comment → verify only ReplyDiscussion fires
- Test: comment with @mention → verify hasMention = true
- Test: comment with attachment → verify hasAttachments = true
- Verify events appear in Amplitude
