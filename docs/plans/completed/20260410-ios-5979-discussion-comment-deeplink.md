# IOS-5979: Support Deep Link to Specific Comment in Object Discussion

## Overview
- Enable deep links to specific comments in object discussions (`.discussion` layout)
- Currently `handleChatMessageDeepLink` only handles `.chat` layout, silently ignoring discussion objects
- The fix combines the existing object deep link and chat message deep link patterns: the URL carries the **parent object ID**, and the handler pushes both editor + discussion screens onto the navigation stack in one commit

## Context (from discovery)
- **Deep link handler**: `SpaceHubCoordinatorViewModel.handleChatMessageDeepLink` (line 570)
- **Discussion copy link**: `DiscussionViewModel.didSelectCopyLink` (line 645) — currently uses `chatId` as `chatObjectId`, should use `objectId` (parent)
- **Navigation path**: `HomePath` supports multiple `push()` calls before committing to `navigationPath`
- **Discussion already supports `initialMessageId`**: `DiscussionViewModel` (line 275-283) has scroll-to-message + highlight logic identical to `ChatViewModel`
- **`DiscussionCoordinatorData`** lacks `messageId` field — needs threading through coordinator → view → viewmodel
- **Parent object stores `discussionId`** as a bundled property on ObjectDetails

## Development Approach
- **Testing approach**: Regular (code first, then tests)
- Complete each task fully before moving to the next
- Make small, focused changes
- **CRITICAL: do NOT modify existing `.chat` handling** in `handleChatMessageDeepLink` or `showScreen`
- Run tests after each change

## Solution Overview

### URL format (unchanged)
```
/object?objectId=<parentObjectId>&spaceId=<spaceId>&messageId=<msgId>
```

### Navigation flow
```
Deep link arrives with messageId
→ handleChatMessageDeepLink opens document for objectId
→ IF editorViewType == .chat → existing flow (UNCHANGED)
→ ELSE IF details.discussionId is non-empty:
  → prepareSpacePath (or use current navigationPath)
  → push EditorScreenData for parent object
  → push DiscussionCoordinatorData with discussionId + messageId
  → commit navigationPath once
  → User sees discussion screen, scrolled to target comment
  → Back button → parent object editor
```

### Copy link flow (changed)
```
User long-presses comment in discussion → Copy Link
→ DiscussionViewModel.didSelectCopyLink
→ Uses objectId (parent) instead of chatId (discussion) as chatObjectId
→ URL: /object?objectId=<parentObjectId>&spaceId=<spaceId>&messageId=<msgId>
```

## Implementation Steps

### Task 1: Thread messageId through DiscussionCoordinatorData → View → ViewModel

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Flows/DiscussionCoordinator/DiscussionCoordinatorViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Flows/DiscussionCoordinator/DiscussionCoordinatorView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionView.swift`

> Note: `DiscussionViewModel.init` already accepts `messageId: String? = nil` — no ViewModel changes needed, only threading through the coordinator and view layers.

- [x] Add `messageId: String?` field to `DiscussionCoordinatorData` (default `nil` to keep existing call sites unchanged)
- [x] Store `messageId` in `DiscussionCoordinatorViewModel` from `data.messageId`
- [x] Pass `model.messageId` from `DiscussionCoordinatorView` to `DiscussionView` init
- [x] Add `messageId` parameter to `DiscussionView.init` and forward to `DiscussionViewModel(... messageId: messageId ...)`
- [x] Verify existing call sites compile without changes (all pass `nil` implicitly)

### Task 2: Fix deep link URL in DiscussionViewModel.didSelectCopyLink

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionViewModel.swift`

- [x] In `didSelectCopyLink`, change `chatObjectId: chatId` to `chatObjectId: objectId` so the URL carries the parent object ID
- [x] Verify `objectId` is always available (it's a non-optional `let` property set in init)

> Note: This change is safe even when `objectId == chatId` (direct discussion navigation) — the URL is unchanged in that case.

### Task 3: Handle discussion deep links in SpaceHubCoordinatorViewModel

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Flows/SpaceHub/SpaceHubCoordinatorViewModel.swift`

> **Important**: The current `guard let details = document.details, details.editorViewType == .chat else { return }` must be **restructured** into an `if/else if` chain. The existing chat logic inside the guard block stays identical — only the control flow wrapper changes from guard-early-return to if-branch.
>
> Note: `details` in the discussion branch refers to the **parent object's** details (opened by `chatObjectId`). `details.discussionId` is the ID of the linked discussion object.

- [x] Restructure the guard into: `if details.editorViewType == .chat { ... existing chat code unchanged ... } else if details.discussionId.isNotEmpty { ... new discussion code ... }`
- [x] In the new discussion branch: prepare space path via `prepareSpacePath(spaceId:)` or fall back to current `navigationPath`
- [x] Build `EditorScreenData` from parent details via `ScreenData(details:).editorScreenData`; guard against nil (e.g. if parent is itself a `.discussion` layout — unlikely but safe)
- [x] Push `EditorScreenData` for the parent object onto the path
- [x] Build `DiscussionCoordinatorData` with `discussionId: details.discussionId`, `objectId: details.id`, `objectName: details.name`, `spaceId: spaceId`, `messageId: messageId`
- [x] Push `DiscussionCoordinatorData` onto the path
- [x] Commit `navigationPath` once (so user sees only discussion, back goes to editor)
- [x] Verify existing `.chat` branch logic is completely unchanged

### Task 4: Verify acceptance criteria

- [x] Verify: copying a comment link in a discussion produces URL with parent objectId (not chatId) (confirmed: `didSelectCopyLink` uses `objectId`)
- [x] Verify: tapping a discussion comment deep link opens discussion screen scrolled to the comment (skipped - requires manual testing on device)
- [x] Verify: tapping back from discussion shows the parent object editor (skipped - requires manual testing on device; code pushes editor then discussion onto nav stack)
- [x] Verify: existing chat message deep links still work (no regression) (skipped - requires manual testing on device; code review confirms chat branch unchanged)
- [x] Verify: existing space chat deep links still work (no regression) (skipped - requires manual testing on device)
- [x] Run full test suite (112 tests, 1 pre-existing failure unrelated to this PR: DiscussionBlockPaddingTests padding mismatch from develop)

### Task 5: [Final] Update documentation

- [x] Move this plan to `docs/plans/completed/`

## Post-Completion

**Manual verification:**
- Test discussion comment deep link when app is cold-launched (not in memory)
- Test discussion comment deep link when app is already open in a different space
- Test discussion comment deep link when already viewing the parent object
- Test chat message deep link still works correctly (regression check)
- Test copying comment link from discussion and pasting in another chat
