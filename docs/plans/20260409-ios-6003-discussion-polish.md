# IOS-6003 Discussion Polish

## Overview
Final UI pass to align Discussion (object thread) views with Figma designs. Covers typography, spacing, colors, links, reactions, checkbox design, blockquote styling, block view organization, and decoupling the message divider from `MessageViewData`.

**Figma references:**
- [Comment Styles](https://www.figma.com/design/AmcNix4nhUIKx02POalQ3T/-M--Discussions?node-id=11004-3050&m=dev)
- [Comment Attachments](https://www.figma.com/design/AmcNix4nhUIKx02POalQ3T/-M--Discussions?node-id=11004-3247&m=dev)
- [Comments Structure](https://www.figma.com/design/AmcNix4nhUIKx02POalQ3T/-M--Discussions?node-id=11004-2880&m=dev)

## Context
- **Branch**: `ios-6003-discussion-polish`
- **Parent issue**: IOS-5869 (Object Discussions)
- All changes are scoped to Discussion views only — Chat is untouched (except adding no-op handlers for new enum cases)

### Key files
- `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/DiscussionBlockItemView.swift` — single switch for all block types
- `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/DiscussionBlockItem.swift` — block enum
- `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/DiscussionMessageView.swift` — message layout, header, divider
- `Anytype/Sources/PresentationLayer/Modules/Discussion/Services/DiscussionTextBuilder.swift` — font/color/mark handling
- `Anytype/Sources/PresentationLayer/Modules/Discussion/Services/ChatMessage+Discussion.swift` — middleware block → enum mapping
- `Anytype/Sources/PresentationLayer/Modules/Discussion/Services/DiscussionMessageBuilder.swift` — builds flat list
- `Anytype/Sources/PresentationLayer/Modules/Chat/Subviews/Message/Reaction/MessageReactionView.swift` — reaction styling
- `Anytype/Sources/PresentationLayer/Modules/Chat/Subviews/Section/MessageSectionItem.swift` — flat list enum
- `Anytype/Sources/PresentationLayer/Modules/Chat/Subviews/Message/MessageViewData.swift` — message data model
- `AnyTypeTests/Discussion/DiscussionMessageBuilderThreadingTests.swift` — existing tests

## Development Approach
- Complete each task fully before moving to the next
- Make small, focused changes
- Verify in Xcode after each task
- Tasks with logic changes (1, 2, 4, 6) include unit tests
- Visual-only changes (3, 5) verified manually against Figma

## Solution Overview

### Typography
- Discussion body text: `.calloutRegular` (Inter 15/22/-0.24) instead of `.chatText` (17px)
- Headings: `.title` (28/32), `.heading` (22/26), `.subheading` (17/24) — already correct in design system, no changes needed to heading font mapping

### Spacing (Option A: topSpacing + bottomSpacing)
Each `DiscussionBlockItem` exposes `topSpacing` and `bottomSpacing`:
- `title`: top 20, bottom 0
- `heading`: top 16, bottom 0
- `subheading`: top 12, bottom 0
- `quote`: top 12, bottom 12
- `divider`: top 8, bottom 0 (divider view has internal 9.5px padding above and below the 1px line)
- everything else: top 8, bottom 0

Container applies: `max(block.topSpacing, previousBlock.bottomSpacing)`. First block always gets topSpacing 8 regardless of its type (gap between header and first content block is always 8).

### Block view organization
Extract only views with meaningful layout logic (quote, checkbox, callout, bulleted, numbered, divider) into separate files. Keep trivial views (text, heading, toggle) inline in the router switch to avoid unnecessary file proliferation.

### Links
Accent100 color (#377AFF), NO underline. Applies to all text styles.

### Reactions (discussion-specific)
- Selected: accent blue background (keep current)
- Unselected: `Color.Shape.transparentSecondary` (change from `Color.Background.Chat.bubbleSomeones`)
- Approach: add an environment value `messageReactionUnselectedColor` set by Discussion parent to override the default chat color

### Checkbox
Use `Image(asset: .System.checkboxChecked/Unchecked)` from design system. Display-only.

### Blockquote
4px bar with `Color.Shape.transparentSecondary`, 12px spacing from bar to text. corner radius 4.

### Message divider
Move from `MessageViewData.showTopDivider` boolean to top-level `MessageSectionItem.discussionDivider` case. Full-width, `Color.Shape.secondary`. Remove `showTopDivider` from `MessageViewData` entirely (Chat always passes `false`). In Chat module the new case is ignored (EmptyView). In Discussions module it is inserted between top-level comments in `MessageSectionData` items. Message divider view: 12px top + 1px line + 12px bottom = 25px total height. Block divider view: 9.5px top + 1px line + 9.5px bottom = 20px total height. These are separate view implementations (different padding values).

## Implementation Steps

### Task 1: Add heading cases to DiscussionBlockItem enum and spacing properties

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/DiscussionBlockItem.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/Services/ChatMessage+Discussion.swift`

- [x] Add `.title(id: Int, content: AttributedString)`, `.heading(id: Int, content: AttributedString)`, `.subheading(id: Int, content: AttributedString)` cases to `DiscussionBlockItem`
- [x] Update `id` computed property to handle new cases
- [x] Update `plainText` computed property to handle new cases
- [x] In `ChatMessage+Discussion.swift`, map `.header1`/`.title` → `.title`, `.header2` → `.heading`, `.header3`/`.header4` → `.subheading` (instead of all going to `.text`)
- [x] Add `topSpacing` computed property: title=20, heading=16, subheading=12, quote=12, everything else=8
- [x] Add `bottomSpacing` computed property: quote=12, everything else=0
- [x] Write tests for `topSpacing` and `bottomSpacing` values for each block type
- [x] Write tests for block mapping: verify header1/title → `.title`, header2 → `.heading`, header3/header4 → `.subheading`

### Task 2: Update DiscussionTextBuilder for discussion fonts and link styling

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/Services/DiscussionTextBuilder.swift`

Note: heading styles (`.header1`/`.title`, `.header2`, `.header3`/`.header4`) already return correct fonts (`.title`, `.heading`, `.subheading`) — no changes needed for those.

- [x] Change `anytypeFont(for:)` to return `.calloutRegular` instead of `.chatText` for paragraph/description/toggle/numbered/marked/checkbox/quote/callout styles
- [x] Remove underline from `.link` marks — only set `message[range].link`, set `foregroundColor` to accent color
- [x] Remove underline from `.object` marks — only set `message[range].link`, set `foregroundColor` to accent color
- [x] Remove underline from `.mention` marks — only set `message[range].link`, set `foregroundColor` to accent color
- [x] Verify link color renders correctly — SwiftUI may override `foregroundColor` on `.link` ranges; if so, apply `.tint(Color.Control.accent)` on the parent Text view instead
- [x] Write tests verifying `anytypeFont(for:)` returns `.calloutRegular` for body styles and heading fonts for heading styles

### Task 3: Refactor block views, fix styling

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/DiscussionBlockItemView.swift` — remove vertical padding, extract complex views
- Create: `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/BlockViews/DiscussionQuoteBlockView.swift`
- Create: `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/BlockViews/DiscussionCheckboxBlockView.swift`
- Create: `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/BlockViews/DiscussionBulletedBlockView.swift`
- Create: `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/BlockViews/DiscussionNumberedBlockView.swift`
- Create: `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/BlockViews/DiscussionDividerBlockView.swift`

- [x] Create `DiscussionQuoteBlockView` — 4px bar width, `Color.Shape.transparentSecondary`, rounded corners 4px, 12px spacing from bar to text
- [x] Create `DiscussionCheckboxBlockView` — use `Image(asset: .System.checkboxChecked/Unchecked)`, 20x20 frame, 6px spacing, display-only
- [x] Create `DiscussionBulletedBlockView` — bullet "•" in 20x20 frame, 6px spacing, `Color.Text.secondary`
- [x] Create `DiscussionNumberedBlockView` — number in 20x20 frame, 6px spacing, `Color.Text.primary` for number
- [x] Create `DiscussionDividerBlockView` — 1px `Color.Shape.primary`, 9.5px vertical padding inside the view
- [x] Refactor `DiscussionBlockItemView` — keep text/heading/toggle/callout inline, delegate quote/checkbox/bulleted/numbered/divider to extracted views, remove all `.padding(.vertical, 2)`
- [x] Handle new `.title`, `.heading`, `.subheading` cases in the switch (render as `Text(content)` inline)

### Task 4: Apply spacing in message container

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/DiscussionMessageView.swift`

- [x] Replace `ForEach(data.discussionBlocks)` with indexed iteration that tracks previous block
- [x] Apply `padding(.top, ...)` using `max(block.topSpacing, previousBlock?.bottomSpacing ?? 0)` for each block
- [x] First block always gets `topSpacing` 8 value
- [x] Remove any existing vertical padding from the ForEach area
- [x] Write tests for spacing calculation logic: verify `max(topSpacing, prevBottomSpacing)` produces correct values for sequences like text→quote→text, text→title→bullet

### Task 5: Fix reaction unselected background for discussions

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Chat/Subviews/Message/MessageColor.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/Chat/Subviews/Message/Reaction/MessageReactionView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/DiscussionMessageView.swift` (or parent view that sets environment)

Approach: Add an environment value for unselected reaction background color. Discussion parent sets it to `Color.Shape.transparentSecondary`. Chat keeps existing default.

- [ ] Add `messageReactionUnselectedColor` environment key in `MessageColor.swift` (alongside existing `messageYourBackgroundColor`) with default `Color.Background.Chat.bubbleSomeones`
- [ ] Add convenience View extension method following same pattern as `messageYourBackgroundColor(_:)`
- [ ] In `MessageReactionView`, read the environment value and use it for unselected background
- [ ] In Discussion parent view, set `.messageReactionUnselectedColor(Color.Shape.transparentSecondary)`
- [ ] Verify chat reaction styling is unaffected (uses default)

### Task 6: Decouple message divider from MessageViewData

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Chat/Subviews/Section/MessageSectionItem.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/Services/DiscussionMessageBuilder.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/Chat/Subviews/Message/MessageViewData.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/DiscussionMessageView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/DiscussionView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/Chat/ChatView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/Chat/Services/ChatMessageBuilder.swift` (remove showTopDivider param)
- Modify: `AnyTypeTests/Discussion/DiscussionMessageBuilderThreadingTests.swift`

- [ ] Add `.discussionDivider(id: String)` case to `MessageSectionItem` enum
- [ ] Update `MessageSectionItem.id` for new case (return the id string)
- [ ] Update `messageId` and `messageOrderId` — return the id string for `.discussionDivider` (divider is not a message, but these properties are used for scroll positioning; returning its own id is safe)
- [ ] Add no-op handler in `ChatView.swift` cell builder: `case .discussionDivider: EmptyView()`
- [ ] In `DiscussionMessageBuilder`, insert `.discussionDivider` items between root messages instead of setting `showTopDivider: true`
- [ ] Remove `showTopDivider` from `MessageViewData` — Chat always passes `false`, safe to remove
- [ ] Remove `showTopDivider` parameter from `buildMessageViewData` in both `DiscussionMessageBuilder` and `ChatMessageBuilder`
- [ ] Remove divider rendering from `DiscussionMessageView.messageBody`
- [ ] Create `DiscussionMessageDividerView` — full-width, 1px `Color.Shape.secondary`, 12px vertical padding (12+1+12 = 25px total)
- [ ] Add divider cell rendering in `DiscussionView` for `.discussionDivider` case using `DiscussionMessageDividerView`
- [ ] Update `extractMessageViewDataItems` test helper to also handle `.discussionDivider` (or create a new helper that preserves both `.message` and `.discussionDivider` items for interleaving verification)
- [ ] Update `DiscussionMessageBuilderThreadingTests` to verify divider items are inserted between root messages
- [ ] Write test verifying no divider before first root message

### Task 7: Verify and clean up

- [ ] Verify all heading styles match Figma: title 28/32, heading 22/26, subheading 17/24
- [ ] Verify body text is 15px in discussions
- [ ] Verify links have accent color and no underline
- [ ] Verify blockquote has 4px bar with correct color and 12px spacing
- [ ] Verify checkbox uses design system assets
- [ ] Verify reactions use correct backgrounds
- [ ] Verify message dividers render correctly between root comments
- [ ] Verify spacing between blocks matches Figma specs
- [ ] Clean up any unused imports or dead code

## Post-Completion

**Manual verification:**
- Visual comparison of each block type against Figma designs
- Test with messages containing mixed block types (headings + lists + quotes + dividers)
- Verify chat module is completely unaffected by changes
- Test reply thread indentation still works correctly with new spacing
