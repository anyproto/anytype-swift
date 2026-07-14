# Handoff — Kanban Board Scroll FPS Investigation (IOS-6579)

## Context

Branch: `ios-6579-kanban-view-audit-and-fix-dormant-implementation-enable-by`
Base commit under investigation: `70480c386e` "IOS-6579 Fix dormant Kanban implementation and
enable it by default" (only this commit touches Kanban files vs `develop`).

The Kanban view (`Set` object, Board layout) was a dormant/rarely-used implementation that got
turned on by default. User reports **janky scroll FPS** on the board. A real-device Instruments
trace was captured: `/Users/roma/Documents/ios-kanban-scroll.trace` (CPU Profiler template,
23s recording, iPhone 17 Pro, iOS 26.5.1). This doc summarizes what the trace + code review found,
and — important — **an attempted fix (Lazy stacks) broke layout and was reverted.** Working tree
is currently clean (identical to `70480c386e` for the Kanban folder). Do not re-attempt the exact
same Lazy-stack swap without reading the "What was tried and why it failed" section below.

## How the trace was analyzed

`xctrace export` was used to pull specific tables out of the `.trace` bundle as XML (the GUI
wasn't used/available in this session). Useful invocations:

```bash
# Table of contents — lists every table schema available in the trace
xcrun xctrace export --input ios-kanban-scroll.trace --toc --output toc.xml

# Frame lifetime / hitch data (the "Hitches" instrument equivalent) — small, human-readable
xcrun xctrace export --input ios-kanban-scroll.trace \
  --xpath '/trace-toc/run[@number="1"]/data/table[@schema="coreanimation-lifetime-interval"]' \
  --output lifetime.xml

# Raw vsync swap timestamps (for manual frame-delta math)
xcrun xctrace export --input ios-kanban-scroll.trace \
  --xpath '/trace-toc/run[@number="1"]/data/table[@schema="display-surface-swap"]' \
  --output swaps.xml

# Full CPU profile w/ symbolicated callstacks — LARGE (~100MB), took ~10s to export
xcrun xctrace export --input ios-kanban-scroll.trace \
  --xpath '/trace-toc/run[@number="1"]/data/table[@schema="cpu-profile"]' \
  --output cpu.xml
```

`cpu.xml` is too big to parse with a plain DOM load — use `xml.etree.ElementTree.iterparse` in
streaming mode, and note the export format uses an id/ref interning scheme (repeated values like
thread names, thread-state, frame names/binaries are defined once with an `id=` attribute and
referenced elsewhere via `ref=`) — you must build lookup caches for `thread`, `thread-state`, and
`frame`/`binary` elements, or you'll silently get `None` for most rows (this bit us once — the
first parse pass mis-read `thread-state` because ref'd elements have no `fmt` attribute of their
own). Filter to `Main Thread` rows via the thread `fmt` string containing `"Main Thread"`.

All intermediate exports/scripts from this session live under a session-scoped scratchpad dir that
will not persist — regenerate with the commands above if you need to re-analyze.

## Findings

### 1. Frame timing (from `coreanimation-lifetime-interval`, i.e. Instruments' own Hitch computation)

- 916 total frames over the 23s recording.
- **182 frames (~20%) hitched**, for **5.7s of cumulative hitch time** — roughly a quarter of the
  recording was spent in dropped/late frames.
- Two hitch signatures dominate (from the `narrative`/`type-label` columns), and **both are
  GPU/compositor-bound, not CPU-bound**:
  - `"waiting on GPU and VSync"` — the CPU-side (main thread) work for that frame finished in
    ~9-14ms, comfortably inside budget, but the frame still landed 40-140ms late because the GPU/
    compositor hadn't caught up. Example: frame 487 at t=10.429s — 9.98ms of actual CPU work,
    141.69ms hitch.
  - `"in render server"` — the system compositor process itself is reported spending 85-155ms
    rendering a single frame. Example: frame 156 at t=4.111s — 155.93ms in render server, 133.36ms
    hitch.
- Worst hitches cluster in two windows: **t≈9.5–17s** and **t≈19–23s** (consistent with sustained
  horizontal drag/scroll through the board, as opposed to the isolated multi-hundred-ms spikes
  earlier in the trace at t=0.5s/3.3s/5.5s which look like initial view load, not scroll).

### 2. Main-thread CPU profile (from `cpu-profile`, filtered to Main Thread, `Running` samples,
   windows t=9.5–17s and t=19–23s)

Top cycle-weighted leaf/hot frames:

```
AttributeGraph::Graph::propagate_dirty(AttributeID)
AttributeGraph::Graph::UpdateStack::update()
SwiftUICore specialized find1<A>(_:key:filter:)
AttributeGraph::Subgraph::update(unsigned int)
AttributeGraph::Subgraph::foreach_ancestor<...propagate_dirty_flags()::$_0>(...)
```

This is SwiftUI's dependency-graph invalidation/propagation machinery and its preference-key
lookup (`find1`) running hot. This pattern shows up when the **live view tree is much larger than
what's actually on screen** — every state change has to walk/re-diff a bloated AttributeGraph, and
every preference-key read (see finding #4 below) has to search/merge across that same oversized
tree. It is corroborating evidence for, not contradicting, the GPU-bound hitch finding above: the
main thread isn't "slow" in the sense of blowing the 16.7/8.3ms budget outright, but it's doing
much more graph/preference work than a properly virtualized list would need, and it's feeding an
oversized real layer tree to the compositor, which is what actually blows the frame deadline.

### 3. Root cause in code: eager (non-lazy) stacks for both scroll axes

`Anytype/Sources/PresentationLayer/TextEditor/Set/Views/Kanban/Board/SetKanbanView.swift:78-84`
(`boardContent`):

```swift
ScrollView(.horizontal, showsIndicators: false) {
    HStack(alignment: .top, spacing: 8) {
        ForEach(model.configurationsDict.keys, id: \.self) { groupId in
            ...
            SetKanbanColumn(...)
        }
    }
}
```

`Anytype/Sources/PresentationLayer/TextEditor/Set/Views/Kanban/Column/SetKanbanColumn.swift:45-47`
(`column`):

```swift
VStack(spacing: 8) {
    ForEach(configurations) { configuration in
        SetDragAndDropView(..., content: { SetGalleryViewCell(configuration: configuration) })
    }
    ...
}
```

Neither the columns (`HStack`) nor the cards within a column (`VStack`) are lazy. Every column and
every card in every column is built, laid out, and composited as a real live view/CALayer
regardless of horizontal scroll position — nothing is virtualized. `git show 70480c386e` confirms
this shape predates the "enable by default" commit (that commit only added loading/error states, a
card counter, and a create-card button) — i.e. this is pre-existing dormant code that was never
exercised at realistic board sizes before now.

### 4. Compounding per-cell cost

`Anytype/Sources/PresentationLayer/TextEditor/Set/Views/Collection/Cell/SetGalleryViewCell.swift:16-30`
— every card's `content` attaches:
- `.readSize { width = $0.width }` →
  `Modules/DesignKit/Sources/DesignKit/SystemExtensions/View+ReadSize.swift` — this is
  `background(GeometryReader { ... }.onPreferenceChange(SizeCatcherKey.self) { ... })`, i.e. a
  `GeometryReader` + `PreferenceKey` round-trip on **every card**.
- `.clipShape(.rect(cornerRadius: 12))`
- `.overlay(RoundedRectangle(cornerRadius: 12).stroke(...))`

Each of these is legitimate per-cell layout/compositing cost, but because of finding #3 it runs for
**every card that has ever existed in the board**, not just the visible ones — this is what's
flooding both the AttributeGraph/preference-key churn on the main thread (finding #2) and the
render-server/GPU load (finding #1).

## What was tried and why it failed

**Attempted fix:** swap `HStack` → `LazyHStack` in `SetKanbanView.boardContent`, and `VStack` →
`LazyVStack` in `SetKanbanColumn.column`.

**Result: broke layout.** On-device screenshot after applying both changes showed the board
"trimmed" — each column rendered only ~1 card even though the column header showed the correct
count (e.g. "Action 2", "Evaluating 5"), followed by a large blank/black area below where the rest
of the board should have been.

Reverting just the card-level change (`SetKanbanColumn` back to plain `VStack`, keeping
`SetKanbanView`'s `LazyHStack` for columns) **did not fix it** — user reported "still trimmed the
same way." Both changes were then fully reverted; `git diff` against `70480c386e` for the Kanban
folder is now clean.

**Working hypothesis for why (not yet verified/isolated):** the view hierarchy above the board is
unusual:

```
OffsetAwareScrollView (native vertical ScrollView; wraps content in a plain VStack +
                        a 0×0 GeometryReader/PreferenceKey pair used only for offset tracking)
  → SetKanbanView.content:
      LazyVStack(pinnedViews: [.sectionHeaders])     ← wraps a SINGLE Section. Only present to
        → Section(header: compoundHeader) {            get sticky/pinned-header behavior for
            boardContent                                the column headers; provides zero
          }                                             virtualization value since it has one child.
            → boardContent: ScrollView(.horizontal) { HStack/LazyHStack { columns } }
                → SetKanbanColumn: VStack { header; column }
                    → column: VStack/LazyVStack { cards }
```

Both attempts (lazy columns, lazy cards) produced the *same* symptom — first item(s) render, then
a fixed-size blank region — regardless of which axis/level was made lazy. That's a signal this is
structural rather than incidental to one specific `Lazy*Stack` call. The suspect is the
**pre-existing single-item outer `LazyVStack(pinnedViews: [.sectionHeaders])`**: `ScrollView`'s
cross-axis size is intrinsic/content-driven (a `ScrollView(.horizontal)` has to ask its content
"how tall are you" since it doesn't constrain height itself), and a `Lazy*Stack` can only answer
that honestly by measuring content it hasn't necessarily built yet. Nesting another lazy container
(even a single-child one) above that ambiguous measurement appears to freeze/collapse the proposed
size early, before the rest of the board's real content height is known — consistent with "only
what fit the first (wrong) size guess got drawn, everything else is clipped blank."

This has **not been confirmed** — it's the leading hypothesis based on the symptom matching on both
attempts, not a verified root cause. Treat it as a starting point, not a conclusion.

## Suggested next steps (untried)

1. **Isolate the outer-LazyVStack hypothesis first**, cheaply: temporarily replace
   `SetKanbanView.content`'s `LazyVStack(pinnedViews: [.sectionHeaders])` with a plain `VStack`
   (accepting loss of the sticky header for this experiment only) and retry `LazyHStack` for
   columns. If the board renders fully, the hypothesis is confirmed and the real fix is about
   restructuring how the pinned header is achieved, not about avoiding Lazy stacks altogether.
2. **If sticky header must be preserved**, look at achieving it without wrapping the entire board
   in a single-item pinned `LazyVStack` — e.g. pin the header via `.safeAreaInset(edge: .top)` or a
   custom offset-driven header that reads the same `offset` binding `SetKanbanView` already tracks,
   instead of relying on SwiftUI's `pinnedViews` mechanism.
3. **Consider giving each column its own vertical `ScrollView` + `LazyVStack`** for cards (instead
   of the current fixed/paginated "Show more" `VStack`) — this would give the card list a direct,
   unambiguous vertical `ScrollView` ancestor (matching axis, no intermediate lazy/section
   ambiguity), sidestepping the cross-axis sizing problem entirely. This is a bigger UX change
   (independent per-column vertical scrolling vs. the current pagination-button model) — needs a
   product call.
4. **Independent of the Lazy-stack question**, finding #4 (per-cell `readSize`/GeometryReader/
   PreferenceKey + `clipShape` + `overlay`) is a real, measured contributor and safe to address
   without touching the container laziness at all:
   - `shouldIncreaseCoverHeight` is the only consumer of the measured `width` in
     `SetGalleryViewCell.swift:56` — check whether it can use the already-known, constant column
     width (`SetKanbanColumn` cards are always laid out at `.frame(width: 254)`,
     `SetKanbanColumn.swift:65`) instead of re-measuring per cell at runtime via `GeometryReader`.
     That would remove one `GeometryReader`+`PreferenceKey` round-trip per card unconditionally.
   - Consider whether `.clipShape` + `.overlay(...stroke)` can be collapsed into a single shape
     pass (e.g. a custom `ButtonStyle`/background shape) to avoid the extra offscreen-render layer
     per card.
5. Whatever is tried, **verify on a real device** (GPU/compositor timing on Simulator is not
   representative) and re-run the trace export commands above (or capture a fresh trace) to confirm
   the `"waiting on GPU and VSync"` / `"in render server"` hitch counts actually drop before
   declaring victory — don't rely on subjective smoothness alone given how easy it was to
   accidentally break layout while "fixing" this.

## Update (2026-07-14, later session) — root cause sharpened, fix implemented

**The "outer pinned LazyVStack" hypothesis was close but not the real blocker.** Both lazy
attempts failed for a structural reason that no rearrangement of `Lazy*Stack` calls can fix while
the whole board scrolls vertically as one sheet:

1. **Columns can't be lazy**: board height must equal the tallest column's height. A `LazyHStack`
   can only measure columns it has already built, so it reports an underestimate at first layout —
   and everything below that wrong height was silently clipped by `SetKanbanColumn`'s
   `.clipShape(.rect(cornerRadius: 4))`, which is exactly the observed "header with correct count,
   ~1 card, then blank" symptom. This holds with or without the outer pinned `LazyVStack`, so
   suggested step #1 above was skipped — it tests the wrong variable.
2. **Cards can't be lazy**: a lazy container only virtualizes against the viewport of its nearest
   *same-axis* ancestor ScrollView. The cards' nearest ScrollView ancestor is the horizontal one,
   so a `LazyVStack` of cards can never track the outer vertical viewport.

**Implemented fix** (both parts, this branch, uncommitted):

- `SetGalleryViewCell.swift`: deleted `@State width` + `.readSize` (GeometryReader/PreferenceKey
  per card — the measured `find1`/AttributeGraph hot path, and a double-layout on insertion).
  `shouldIncreaseCoverHeight` means "cover-only card is square", so the cover now uses
  `.aspectRatio(1, contentMode: .fit)` instead of a measured `frame(height: width)`. Safe because
  `ObjectHeaderCoverView` is a `GeometryReader` at its root and always fills its proposal. Also
  benefits the gallery view, which shares the cell.
- `SetKanbanView.swift`: replaced `OffsetAwareScrollView` + single-section
  `LazyVStack(pinnedViews:)` + negative-padding scaffolding with a plain `VStack`: top spacer
  (`tableHeaderSize.height - headerMinimizedSize.height`, replicating the old resting geometry),
  always-visible settings header, then `ScrollView(.horizontal) { LazyHStack { columns } }`.
  `offset` is reset to `.zero` in `onAppear` so the overlaid `SetFullHeader` recovers after
  switching from a scrolled table/gallery.
- `SetKanbanColumn.swift`: column = fixed header + own `ScrollView(.vertical) { LazyVStack }` of
  cards (Trello/Linear model). Every lazy container now sits directly inside a matching-axis
  ScrollView with concrete size proposals — virtualization works by construction. The old
  `background + clipShape` pair became two `background(_, in:)` shape fills (top-rounded header,
  bottom-rounded content) so the tint still hugs content; `.scrollBounceBehavior(.basedOnSize)`
  keeps short columns from rubber-banding.

**Accepted UX changes** (user approved "both parts now"): columns scroll vertically independently;
column headers and the settings row are always visible; the object title header is static (never
collapses on scroll, since there is no whole-board vertical offset anymore).

**Still to do**: build in Xcode, verify on a real device, and capture a fresh trace comparing
"waiting on GPU and VSync" / "in render server" hitch counts per step #5 above. Known cosmetic
nit: an empty column with no create button has square bottom corners on the header tint (4pt
radius, barely visible).

### Follow-up: nested-scroll gesture arbitration (the "deceleration catch")

Device testing of the restructure surfaced the expected side effect of nesting scroll views:
**horizontal board swipes were swallowed while a column was still decelerating.** A `UIScrollView`
that is decelerating grabs the next touch at a *zero* movement threshold (that's how you catch and
re-flick moving content), and once its pan owns the touch, direction no longer matters — the
column consumes a horizontal drag it cannot act on and the board never sees it. At rest, UIKit's
own arbitration already routes cross-axis drags to the parent correctly, which is why this only
misbehaves mid-settle. There is no SwiftUI API for this.

**Fix**: `Anytype/Sources/PresentationLayer/Common/SwiftUI/BasicComponents/ScrollAxisLock.swift` —
a `.scrollAxisLock(_ axis:)` modifier, applied to the scroll view's *content* (not the ScrollView
itself, or the superview walk finds the wrong scroll view). It walks up to the enclosing
`UIScrollView`, attaches a `CrossAxisDragGate` (a bare `UIGestureRecognizer` that recognizes on
cross-axis-dominant movement and fails on along-axis-dominant movement, 6pt threshold), and calls
`scrollView.panGestureRecognizer.require(toFail: gate)`. Net effect: the pan can't begin until the
drag reveals a direction, and only begins for drags along its own axis — the zero-threshold catch
is gone in the cross-axis direction while the normal one survives.

Applied symmetrically: `.scrollAxisLock(.vertical)` on the column content, `.scrollAxisLock(.horizontal)`
on the board's `LazyHStack`, giving strict axis arbitration in both directions (a vertical drag
while the *board* is decelerating reaches the column too — the mirror bug).

Details that matter if you touch this:
- The gate overrides `canPrevent`/`canBePrevented` to `false`, so it only ever gates the pan it is
  wired to and never blocks the other scroll view's pan (default UIKit behavior would).
- `canScrollAlongAxis` makes it self-disabling: a scroll view with no overflow along its axis (or
  one we attached to by mistake) gets no gating at all.
- `cancelsTouchesInView = false`, so card taps and `.onDrag` drag-and-drop are unaffected.
- No extra dead zone for normal scrolling: the gate resolves at 6pt, below `UIPanGestureRecognizer`'s
  own ~10pt begin threshold. The 6pt threshold is the knob to tune if the feel is off.

## Key files

- `Anytype/Sources/PresentationLayer/TextEditor/Set/Views/Kanban/Board/SetKanbanView.swift`
- `Anytype/Sources/PresentationLayer/TextEditor/Set/Views/Kanban/Column/SetKanbanColumn.swift`
- `Anytype/Sources/PresentationLayer/TextEditor/Set/Views/Collection/Cell/SetGalleryViewCell.swift`
- `Modules/DesignKit/Sources/DesignKit/SystemExtensions/View+ReadSize.swift`
- `Anytype/Sources/PresentationLayer/Common/SwiftUI/BasicComponents/OffsetAwareScrollView.swift`
- Trace file: `/Users/roma/Documents/ios-kanban-scroll.trace`
