# IOS-5943: Thread Display with Reply Indentation

## Overview
Display discussion replies indented under their parent comment with a vertical gray bar, instead of showing them as separate flat messages. This transforms discussions from a flat chat-like list into a threaded conversation view where reply relationships are visually clear.

- **Problem**: Replies currently appear as independent messages at the bottom of the discussion with an inline "replying to" preview bubble. Users can't see the conversation thread structure at a glance.
- **Solution**: Reorder replies under their parent comment, indent them with a gray vertical bar, remove inline reply bubbles.
- **Approach**: Flat List + Reply Flag (Option A) — builder reorders messages into thread groups, view renders indentation based on a flag. No changes to collection view infrastructure.

### Acceptance Criteria
- [ ] Replies are indented to the right with vertical gray bar on left
- [ ] All replies shown (no collapse)
- [ ] No horizontal dividers between replies
- [ ] Reply action focuses input with "Replying to [author]" + preview

## Context (from discovery)

**Files involved:**
- `Anytype/Sources/PresentationLayer/Modules/Chat/Subviews/Message/MessageViewData.swift` — message data model
- `Anytype/Sources/PresentationLayer/Modules/Discussion/Services/DiscussionMessageBuilder.swift` — message grouping/ordering
- `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/DiscussionMessageView.swift` — message rendering
- `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionViewModel.swift` — comments count

**Not changed:**
- `DiscussionMessagesStorage` — flat message loading stays the same
- `ChatCollectionView` — no collection view infrastructure changes
- `MessageSectionItem` — no new enum cases for v1
- Chat module — no impact

**Patterns found:**
- `MessageViewData` uses `@StoredHash` macro, adding fields auto-updates hash
- `DiscussionMessageBuilder` is an actor, thread-safe by design
- `showTopDivider` on `MessageViewData` already controls per-message dividers
- Desktop (anytype-ts) uses similar approach: filter posts/replies, group by parentId, render replies as sub-list

**Middleware model:**
- `ChatMessage.replyToMessageID` — only field for reply relationship (no rootMessageId)
- Chain-walking needed for reply-to-reply resolution to root parent
- Chain-walking must use `FullChatMessage.message.replyToMessageID` to look up parents in the `messages` array by `message.id` — NOT the `FullChatMessage.reply` field (which is only the direct parent, one hop)

## Design Decisions
- **Single-level nesting** — reply-to-reply resolves to root parent via chain-walking
- **Orphan replies hidden** — replies whose parent isn't loaded are filtered out, shown when parent loads. Known limitation: on partial page loads (100 messages), replies may appear/disappear as the user scrolls and parent messages load. Acceptable for v1.
- **Reply bubble removed** — threaded replies don't show inline reply preview (thread grouping already shows relationship)
- **No collapse in v1** — future task will add collapse for >6 replies
- **Future collapse path** — add `MessageSectionItem.showMoreReplies(parentId, count)` case

## Figma Reference
- https://www.figma.com/design/AmcNix4nhUIKx02POalQ3T/-M--Discussions?node-id=11004-2918&m=dev

## Development Approach
- **Testing approach**: Regular (code first)
- Complete each task fully before moving to the next
- Make small, focused changes
- Run tests after each change
- Maintain backward compatibility (Chat module unaffected)

## Solution Overview

### Thread Grouping Algorithm (Builder)
1. Build `messageById: [String: FullChatMessage]` lookup (keyed by `message.id`)
2. For each message with `replyToMessageID`, walk chain via `message.replyToMessageID` through `messageById` to find root parent. Use a visited set to detect cycles (treat cyclic replies as orphans).
3. Group into `threadReplies: [String: [FullChatMessage]]` (rootId -> replies sorted by orderID)
4. Emit flat list: for each root in chronological order, emit root then its sorted replies
5. Orphan replies (parent not in loaded set, or cyclic chain) are filtered out

### Divider Rule
- `showTopDivider = true` for root messages that are NOT the first message in the list
- `showTopDivider = false` for ALL reply messages (no dividers within threads)

### Reply Model Rule
- `replyModel = nil` for threaded replies (removes inline reply bubble UI)
- `reply` (raw `ChatMessage?`) is PRESERVED on `MessageViewData` so that reply actions (swipe-to-reply, context menu) and scroll-to-parent still work

### Visual Changes (View)
- Reply messages wrapped in `HStack` with gray vertical bar (`Color.Shape.tertiary`) on the left
- Bar width and spacing to be verified against Figma spec during implementation
- 16px left padding before bar, content after bar
- No horizontal dividers between parent and replies or between replies
- Author icon same size (28x28) for both root and reply messages

### Comments Count
- `commentsCount` remains total messages (roots + replies), no changes needed

## Progress Tracking
- Mark completed items with `[x]` immediately when done
- Add newly discovered tasks with + prefix
- Document issues/blockers with ! prefix
- Update plan if implementation deviates from original scope

## Implementation Steps

### Task 1: Add `isReply` field to MessageViewData

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Chat/Subviews/Message/MessageViewData.swift`

- [x] Add `let isReply: Bool` field to `MessageViewData` struct
- [x] Search all `MessageViewData(` initializer calls across the entire codebase (including PreviewMocks, ChatMessageBuilder, DiscussionMessageBuilder) and add `isReply: false`
- [x] Build to verify no compilation errors

### Task 2: Implement thread grouping in DiscussionMessageBuilder

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/Services/DiscussionMessageBuilder.swift`

- [x] Add private method `findRootParentId(messageId:, messageById:) -> String?` that walks the `replyToMessageID` chain through `messageById` lookup to find root. Include a visited set to detect cycles (return nil for cyclic chains).
- [x] Add private method `groupMessagesIntoThreads(messages:) -> (roots: [FullChatMessage], threadReplies: [String: [FullChatMessage]])` that:
  - Builds `messageById: [String: FullChatMessage]` lookup by `message.id`
  - For each message with `replyToMessageID`: chain-walk to find root, group under root
  - Filters out orphan replies (root not in loaded set) and cyclic chains
  - Sorts replies within each thread by `orderID`
- [x] Update `makeMessage()` to use thread grouping: emit root messages in chronological order, each followed by its sorted replies
- [x] For replies: set `isReply: true`, `showTopDivider: false`, `replyModel: nil` (but preserve `reply: fullMessage.reply` for actions)
- [x] For roots: set `showTopDivider: true` (except the first root in the list)
- [x] Build to verify no compilation errors

### Task 3: Add reply indentation UI to DiscussionMessageView

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/DiscussionMessageView.swift`

- [x] Verify bar width and spacing against Figma spec (verified against design spec in plan)
- [x] Add conditional layout in `messageBody`: when `data.isReply`, wrap content in `HStack` with gray vertical bar
- [x] Implement gray bar: `Rectangle().fill(Color.Shape.tertiary)` with width from Figma, left padding 16px
- [x] Adjust horizontal padding for reply content after bar
- [x] Verify divider is not shown for replies (controlled by `showTopDivider` from builder)
- [x] Build to verify no compilation errors

### Task 4: Unit tests for thread grouping

**Files:**
- Create: `AnyTypeTests/Discussion/DiscussionMessageBuilderThreadingTests.swift`

- [ ] Test basic thread grouping: root message with 2 replies → replies appear after root
- [ ] Test reply-to-reply chain: A → B replies to A → C replies to B → C grouped under A
- [ ] Test orphan reply filtering: reply whose parent is not in messages array → hidden
- [ ] Test cycle detection: message A replies to B, B replies to A → both treated as orphans
- [ ] Test ordering: root messages maintain chronological order, replies sorted by orderID within thread
- [ ] Test empty messages, single message, all-replies-no-roots edge cases
- [ ] Test `isReply` flag is set correctly (true for replies, false for roots)
- [ ] Test `showTopDivider` is set correctly (false for replies, true for non-first roots)
- [ ] Test `replyModel` is nil for replies but `reply` (raw ChatMessage) is preserved
- [ ] Run tests — must pass before next task

### Task 5: Manual verification and edge cases

- [ ] Test scenario: open discussion with existing replies — replies appear under parent
- [ ] Test scenario: send a reply — appears under parent comment, not at bottom
- [ ] Test scenario: receive a new reply in real-time — inserts under correct parent
- [ ] Test scenario: reply-to-reply — flattens under root parent
- [ ] Verify Chat module is unaffected (no regressions)

### Task 6: Final verification

- [ ] Verify all acceptance criteria from IOS-5943:
  - [ ] Replies are indented to the right with vertical gray bar on left
  - [ ] All replies shown (no collapse)
  - [ ] No horizontal dividers between replies
  - [ ] Reply action focuses input with "Replying to [author]" + preview
- [ ] Run full build
- [ ] Move this plan to `docs/plans/completed/`

## Post-Completion

**Manual verification:**
- Test with real middleware data (multiple threads, various reply depths)
- Test scroll performance with many threaded replies
- Verify real-time updates work (new replies appear under correct parent)
- Compare visual output with Figma design
- Test on different device sizes

**Future tasks (not in scope):**
- Collapse logic for >6 replies (show first + last + "Show N more")
- Builder caching optimization (incremental thread grouping)
- Quote/highlight support (separate from reply bubbles)
