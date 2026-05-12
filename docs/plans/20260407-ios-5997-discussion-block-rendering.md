# IOS-5997: Support Rendering Blocks in Discussions — Embeds & Dividers

## Overview
Improve discussion message block rendering by:
1. Replacing generic "Unsupported block" placeholder for **embeds** with the editor's `EmbedContentView` (shows processor icon, name, and "Open" button)
2. Detecting **divider** blocks (text `"---"` with no marks) and rendering a proper horizontal line instead of plain text

**Acceptance criteria:**
- Embed blocks render with processor icon, name, and "Open" button (same as editor)
- Divider blocks render as 1pt horizontal line in `Color.Shape.primary`
- Code blocks still show "Unsupported block" placeholder (no change)
- Checkbox checked state still works (no change)
- Existing block types (text, quote, callout, lists, attachments) unaffected

## Context (from discovery)
- Discussion block rendering lives in `Anytype/Sources/PresentationLayer/Modules/Discussion/`
- Block types are defined in `DiscussionBlockItem` enum, parsed in `ChatMessage+Discussion.swift`, rendered in `DiscussionBlockItemView`
- Editor already has `EmbedContentView` + `EmbedContentViewModel` + `EmbedContentDataBuilder` for embed placeholders
- Protobuf `MessageBlockEmbed` has `text` and `processor` fields matching `BlockLatex`
- Desktop encodes dividers as text blocks with text `"---"` and empty marks (see `~/Projects/anytype-ts/src/ts/lib/util/comment.ts`)
- Figma design (node 10901:43347): 1pt line, `Color.Shape.primary`

## Development Approach
- **testing approach**: Regular (code first)
- complete each task fully before moving to the next
- make small, focused changes

## Implementation Steps

### Task 1: Add embed block support

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/DiscussionBlockItem.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/Services/ChatMessage+Discussion.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/DiscussionBlockItemView.swift`
- Create: `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/DiscussionEmbedBlockView.swift`

- [ ] Add `case embed(id: Int, processor: Anytype_Model_Block.Content.Latex.Processor, text: String)` to `DiscussionBlockItem` enum
- [ ] Add `.embed` to the `id` computed property switch
- [ ] Add `.embed` to the `plainText` computed property (returns `nil`)
- [ ] In `ChatMessage+Discussion.swift`, replace `case .embed: result.append(.unsupported(...))` with `result.append(.embed(id: index, processor: embedBlock.processor, text: embedBlock.text))`
- [ ] Create `DiscussionEmbedBlockView` — a small wrapper view that owns `@State` for `EmbedContentViewModel` to preserve Safari sheet state across re-renders. Build `BlockLatex(text:processor:)`, use `EmbedContentDataBuilder().build(from:)` to get `EmbedContentData`, create `EmbedContentViewModel(data:)` in `@State`, render `EmbedContentView(model:)`
- [ ] In `DiscussionBlockItemView`, add embed case: delegate to `DiscussionEmbedBlockView(processor:text:)`

### Task 2: Add divider block support

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/DiscussionBlockItem.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/Services/ChatMessage+Discussion.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/Discussion/Subviews/DiscussionBlockItemView.swift`

- [ ] Add `case divider(id: Int)` to `DiscussionBlockItem` enum
- [ ] Add `.divider` to the `id` computed property switch
- [ ] Add `.divider` to the `plainText` computed property (returns `nil`)
- [ ] In `ChatMessage+Discussion.swift`, before the style switch in `.text` case, add: `if textBlock.text == "---", textBlock.marks.isEmpty { result.append(.divider(id: index)); continue }`
- [ ] In `DiscussionBlockItemView`, add divider case: `Color.Shape.primary.frame(height: 1).padding(.vertical, 10)`

### Task 3: Verify acceptance criteria
- [ ] Verify all acceptance criteria from Overview are met
- [ ] Verify edge cases: embed with empty text, embed with URL, divider-like text with marks (should NOT be treated as divider)

## Post-Completion

**Manual verification:**
- Create a discussion message on desktop with an embed (e.g. YouTube) and verify it renders correctly on iOS
- Create a discussion message on desktop with a divider between paragraphs and verify it renders as a line on iOS
- Verify "Open" button on embeds opens Safari with correct URL
