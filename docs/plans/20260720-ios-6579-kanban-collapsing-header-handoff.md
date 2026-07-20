# Handoff — Kanban collapsing object header (IOS-6579, follow-up)

## Context

Branch: `ios-6579-kanban-view-audit-and-fix-dormant-implementation-enable-by`
Last commit: `a38b3bb66f` "IOS-6579 Virtualize Kanban board scrolling to fix scroll jank"

The prior work (see `20260714-ios-6579-kanban-scroll-fps-handoff.md`, read it first) fixed scroll
jank by restructuring the board into `ScrollView(.horizontal) { LazyHStack { columns } }` where
each column is its own `ScrollView(.vertical) { LazyVStack { cards } }`. That fixed FPS but
**removed the whole-page vertical scroll**, and with it the collapsing object header.

**The bug**: on Board layout the object header (cover/icon, title, Layout/Properties/Templates
chips) is permanently pinned in place and eats ~40% of the screen. Every other Set view type
(Grid/List/Gallery) scrolls that header away and leaves the view-settings row (`Board ⌄ … New`)
stuck to the top under the nav bar. Kanban must behave the same.

**Required behavior**: dragging vertically anywhere on the board first scrolls the *page* — the
object header slides up under the nav bar and the settings row + column headers come to rest at the
top — and only after that does continued dragging scroll *inside the column*. Dragging back down
reverses it.

## How the other views do it (this is the contract to match)

Nothing in kanban gets to invent its own header behavior — `EditorSetView` owns the header and the
shared `offset` binding, and each content view drives it. Mechanism, using Grid as the reference:

`EditorSetView.swift:53-79` builds a `ZStack(alignment: .top)`:
- `contentView` — a `VStack` whose first child is `Spacer.fixedHeight(headerMinimizedSize.height)`,
  so the content area starts below the nav bar (`EditorSetView.swift:86-91`).
- `SetFullHeader` — the big object header, drawn *over* the content, positioned by
  `.offset(x: 0, y: offset.y)` and `.ignoresSafeArea(edges: .top)` (`EditorSetView.swift:58-64`).
  It is opaque (`SetFullHeader.swift:17` — `.background(Color.Background.primary)`).
- `SetMinimizedHeader` — the always-visible nav bar; reports its height into
  `headerMinimizedSize` (`SetMinimizedHeader.swift:31`).

`SetTableView.swift:18-43` then does the actual trick inside its vertical `OffsetAwareScrollView`:
```swift
Spacer.fixedHeight(tableHeaderSize.height)          // reserves room for SetFullHeader
LazyVStack(pinnedViews: [.sectionHeaders]) {
    content                                         // Section(header: compoundHeader) { rows }
    pagination
}
.padding(.top, -headerMinimizedSize.height)         // pulls the list up under the nav bar
```
and publishes `offsetChanged: { offset.y = $0.y }`.

So the header is *not* scrolled by being inside the scroll view — it is an overlay slaved to the
scroll offset, and a spacer inside the scroll content reserves its space. `tableHeaderSize` is the
full header height minus the top safe area (`EditorSetView.swift:143-145`).

**The single most important derived quantity** — the total collapse distance:

```
H = tableHeaderSize.height - headerMinimizedSize.height
```

At `offset.y == -H` the full header's bottom edge is exactly flush with the nav bar's bottom, and
the pinned section header (settings row) has reached the top of the scroll viewport. That is the
resting collapsed state in screenshot 2. Verify this equation before building on it.

## Why kanban lost it, and why the obvious fix does not work

`SetKanbanView.swift:15-29` currently has no scroll view at all — a plain `VStack` with a fixed
`Spacer.fixedHeight(max(tableHeaderSize.height - headerMinimizedSize.height, 0))` (i.e. a
permanently-expanded `H`), plus an `onAppear { offset = .zero }` hack to stop the shared header
from being left mispositioned by a previously-scrolled view type. **Both must go.**

**Do not "just wrap the board in an outer vertical ScrollView".** It compiles, it looks right, and
it does not work: iOS has no nested-scroll chaining (no equivalent of Android's
`NestedScrollingParent`). With a vertical `ScrollView` containing a column that is itself a
vertical `ScrollView`, the innermost scroll view wins the pan for any touch that starts on it, and
when it hits its top edge it bounces rather than handing the drag to the parent. Result: dragging
on cards would scroll only the column and never collapse the header — which is the bug we are
trying to fix. The page would collapse only when dragging the few dead pixels between columns.

The standard UIKit remedy (both scroll views recognize simultaneously, then redistribute
`contentOffset` in the scroll callbacks) requires owning the scroll views' pan delegates.
SwiftUI owns them, and `UIScrollView` requires its `panGestureRecognizer.delegate` to be the scroll
view itself, so that route is closed without replacing the ScrollViews with UIKit.

## Recommended design: let the column's own scroll be the page scroll

The insight that makes this simple: **put a `H`-tall transparent spacer at the top of every
column's scroll content.** The first `H` points of any column's scroll then move nothing that the
user can see inside the column, and we slave the header overlays to that same offset. Visually the
whole page moves as one — identical to Grid — and after `H` the column just keeps scrolling its
cards. No nested same-axis scroll views, no gesture arbitration, no delegate ownership.

### Geometry

Symbols (all in the coordinate space of `contentTypeView`, i.e. y=0 is just under the nav bar):

- `H` = `tableHeaderSize.height - headerMinimizedSize.height` — total collapse distance.
- `S` = measured height of `compoundHeader` (settings row + its 16pt spacer).
- `V` = height of the content area (take it from a `GeometryReader` in `SetKanbanView`).
- `collapse` = `clamp(driving column's contentOffset.y, 0, H)` — shared state, 0 = expanded.

Layout:

```
board container:  fixed at y = S, height = V - S          (never moves)
settings row:     overlay at y = H - collapse, height S    (opaque, slides up, stops at 0)
SetFullHeader:    driven by publishing offset.y = -collapse to the shared binding
column content:   Spacer(H) + Section(header: columnHeader) { cards … }  in a pinned LazyVStack
```

Check the invariant — the first card's top must always meet the settings row's bottom:

```
first card top   = boardTop + contentPos - scroll = S + H - collapse
settings bottom  = (H - collapse) + S                       ✓ equal for every value of collapse
```

At `collapse == 0` the board's top strip is hidden behind the opaque `SetFullHeader`; at
`collapse == H` the settings row sits at y=0 and the pinned column header sits at y=S. Both
resting states then match the Grid screenshots exactly.

### Why the column header goes *inside* the column scroll (pinned)

Keep `SetKanbanColumn`'s header (`Waiting Response 13 …`) inside the column's `ScrollView`, as a
`Section(header:)` of a `LazyVStack(pinnedViews: [.sectionHeaders])`, rather than as a sibling
above it (where `SetKanbanColumn.swift:22` has it today). Two reasons: it then pins to the column
viewport top for free with no offset math, and — more importantly — the 44pt header strip stays
part of the scroll view, so drags starting on it still drive the collapse. A header outside the
scroll view would be a dead zone across the top of every column.

Note the earlier failed experiment used a pinned `LazyVStack` too, but *cross-axis* (inside a
horizontal scroll). Here it is inside a matching-axis vertical `ScrollView`, which is the supported
configuration Grid already relies on. Preserve the tint/rounded-corner treatment
(`SetKanbanColumn.swift:24-27, 33-36`): the pinned header must stay opaque so cards pass under it.

### Cross-column synchronization

Columns scroll independently, but there is one shared header. Rules:

- The column currently being dragged/decelerating is the driver; it sets `collapse`.
- Any *other* column whose `contentOffset.y < collapse` must be set to `collapse` (non-animated) so
  its spacer is consumed by the same amount — otherwise switching to it would show an `H`-tall hole
  where the header used to be.
- Columns already scrolled past `collapse` are left alone; their deeper scroll position persists
  (Trello behaves this way). When the header re-expands, their cards slide under the opaque header,
  which is fine.
- Guard against feedback loops: programmatic `setContentOffset` re-enters the observer. Gate on
  `isDragging`/`isTracking`/`isDecelerating` or an explicit re-entrancy flag.

Reading the offsets: use the introspection pattern already in the repo —
`ScrollAxisLock.swift` (`ScrollAxisLockUIView.enclosingScrollView`, lines 52-59) walks up from a
zero-size background view to the enclosing `UIScrollView`. Observe `contentOffset` with KVO
(deployment target is iOS 17, so `onScrollGeometryChange` is unavailable). A small shared
coordinator object (`@State` in `SetKanbanView`, passed down) that registers each column's scroll
view and owns `collapse` is the natural shape.

### Short columns

A column whose content is shorter than its viewport cannot scroll, so it can neither drive nor
follow the collapse. Give every column's scroll content a minimum height of `viewport + H` (a
trailing flexible spacer, or `.frame(minHeight:)` on the content) so `H` points of scroll always
exist. Do not remove `.scrollBounceBehavior(.basedOnSize)` without re-checking this interaction.

## Invariants that must not regress

From the previous round — re-verify each before declaring done:

1. **Virtualization.** Columns lazy in `LazyHStack`, cards lazy in `LazyVStack`, each lazy
   container directly inside a matching-axis `ScrollView`. This is the actual FPS fix.
2. **Axis lock.** `.scrollAxisLock(.vertical)` on column content and `.scrollAxisLock(.horizontal)`
   on the board (`ScrollAxisLock.swift`) — stops a decelerating scroll view from swallowing
   cross-axis drags. Still required; verify horizontal swipes work mid-collapse.
3. **No per-card `GeometryReader`.** `SetGalleryViewCell` must not regain `readSize`.
4. **`AnytypeNavigationSpacer()`** at the end of each column's content — the floating home panel's
   blur intercepts touches full-width, so "+ New" is untappable without it.
5. **Top fade** (`SetKanbanColumn.topFade`) still aligned to the column viewport top.
6. Card tap, `.onDrag` reordering across columns, "Show more" pagination, empty-column drop area.

## Edge cases

- **`isEmptyViews` / `.loading` / `.error` states** (`SetKanbanView.swift:31-40`) have no columns,
  so nothing can drive the collapse. Decide deliberately: simplest is to keep those states
  non-collapsing (header expanded), since there is nothing to scroll to.
- **View-type switching.** `offset` is shared `@State` in `EditorSetView` across Grid/List/Board.
  Publishing `offset.y = -collapse` replaces the `onAppear { offset = .zero }` hack, but check the
  Board→Grid→Board round trip leaves the header in a sane position.
- **"Show more"** changes a column's content height mid-scroll; make sure `collapse` is not
  disturbed.
- **Drag-and-drop auto-scroll** may drive `contentOffset` programmatically — make sure that path
  does not fight the sync rules.
- **Rotation / dynamic type** change `H`, `S` and `V`; `collapse` must be re-clamped.

## Verification

- Both resting states must match the Grid screenshots: expanded (header visible, settings row
  under it) and collapsed (settings row flush under the nav bar, then column headers, then cards).
- Drag once, slowly, from a card: header and cards must move together at 1:1 with the finger (a 2:1
  rate means the board container is moving *and* the content is scrolling — the classic failure of
  this design; re-check the geometry table above).
- Collapse via column A, then swipe to column B: no hole at the top of B.
- Real device only for FPS claims, and re-run the trace comparison from the previous handoff
  (`"waiting on GPU and VSync"` / `"in render server"` hitch counts) — the added spacer and
  coordinator must not reintroduce hitching.

## Update (2026-07-20, later session) — implemented

The recommended design was implemented as specified (working tree, uncommitted, on `develop` —
the prior kanban branch is already merged):

- **`KanbanCollapseCoordinator.swift`** (new) — `@MainActor` class owning `collapse`. Columns
  register their enclosing `UIScrollView` via a `.kanbanCollapseSync(_:)` background view (same
  superview-walk introspection as `ScrollAxisLock`). KVO on `contentOffset`; offsets are read
  relative to `adjustedContentInset.top`. Driver rules: a tracking/dragging/decelerating scroll
  view drives; a merely decelerating one cannot steal from a finger-driven one. Followers (and
  any non-finger programmatic/layout-induced movement, incl. lazily materialized columns at
  registration) are raised to `collapse` when behind, never lowered — deeper positions persist.
  Re-entrancy gated with an `isSyncing` flag.
- **`SetKanbanView.swift`** — ready state is now `GeometryReader { ZStack(top) }`: board fixed
  below the settings row (`.padding(.top, S)`), `compoundHeader` overlaid at
  `y = H - collapse` (measured via `readSize`), and the coordinator callback publishes
  `collapse` + `offset.y = -collapse` (replaces the `onAppear { offset = .zero }` hack).
  Loading/error/empty keep the old static expanded layout and reset collapse/offset to zero.
  Coordinator callback is cleared in `onDisappear` (retain cycle: closure → view → @State
  storage → coordinator). `H` changes flow in via `.onChange(of: collapseDistance, initial:
  true)` and re-clamp `collapse`.
- **`SetKanbanColumn.swift`** — column is now a single vertical `ScrollView`:
  `Spacer(H)` + `LazyVStack(spacing: 8, pinnedViews: [.sectionHeaders])` with the column header
  as the pinned `Section` header. Header background is made opaque (Background.primary underlay
  + tint in a top-rounded shape) since cards pass under it; `topFade` moved from the scroll
  viewport top to an overlay hanging below the header. Cards tint comes from a single
  all-corners-rounded background on the LazyVStack (top corners hidden behind the header's own
  rounding); rows are inset with `.padding(.horizontal, 8)` (cell fills width — equivalent to
  the old `.frame(width: 254)`). Content gets `.frame(minHeight: viewport + H, alignment: .top)`
  so short columns can always drive/follow the full collapse.

Not yet done (needs device): both resting states vs Grid screenshots, 1:1 finger tracking,
collapse-then-swipe hole check, invariants 1–6, and the Instruments hitch-count comparison.

### Fix after first device test: header must keep sliding past `H`

First on-device test showed the header's bottom content (title/properties/type buttons) staying
visible at the top after collapse. Cause: this doc's `collapse = clamp(offset, 0, H)` stops the
header at `offset == -H`, where its bottom edge is merely *flush* with the nav bar bottom — and
the nav bar (`NavigationHeader`) has only a `HomeBlurEffectView` background, so the header's
bottom `navHeight + safeArea` points sit permanently behind the blur. Grid doesn't have this
problem because it publishes the **raw** scroll offset unbounded: scrolling into the rows keeps
sliding the header up until it is fully off-screen.

Fix: the coordinator now tracks the driver 1:1 as `headerTravel = clamp(rel, -∞,
fullHeaderHeight)` where `fullHeaderHeight = tableHeaderFullSize.height` (passed down from
`EditorSetView`) is the travel at which the header is completely off-screen (also where updates
stop, so deep card scrolling publishes nothing). `collapse = clamp(headerTravel, 0, H)` remains
the settle line for the settings row and follower sync. Side benefit: negative travel is
published raw, so the header + settings row follow the driver's rubber-band bounce 1:1 like
Grid (the geometry stays glued: header bottom == settings top == `H + bounce`).

Known accepted quirk: switching drivers between columns scrolled to different depths ≥ `H` can
pop the header's position, but both endpoints lie behind the nav blur, so it isn't visible
mid-screen. Short columns (content < viewport + fullHeaderHeight of scroll range) can't push the
header fully away — same limitation Grid has with short content.

### Second device round: delta-driven header, two-way page lock, single active fling

Two more field bugs, both rooted in this doc's original cross-column rules:

1. **Header flicker + garbage states with two decelerating columns.** The driver arbitration
   let a decelerating column steal the header back, so two settling columns alternated as
   driver every frame. Fix: only finger contact claims drivership, and claiming stops the
   previous driver's fling dead (`setContentOffset(_, animated: false)` — the canonical
   deceleration kill). One active scroller at a time, like UIKit's own touch-stops-fling rule.
2. **Deep columns made the header jump, and columns could never be restored to their group
   headers.** The spec's `collapse = clamp(driver's offset, 0, H)` maps the driver's *absolute*
   offset — so touching a column scrolled deeper than the page teleported the header to its
   depth. And follower sync was one-way (raise only), so once a column was pushed deeper it
   could never be walked back. Fix, the current model in `KanbanCollapseCoordinator`:
   - `headerTravel` moves by the driver's scroll **deltas** (KVO old/new), clamped to
     `[0, fullHeaderHeight]`; it is continuous across driver changes — no jumps by construction.
     A floor of `min(rel, 0)` lets a top-bouncing column drag the header down 1:1 and back;
     upward deltas coming out of the rubber band are dropped so the snap-back can't re-collapse
     what the stretch expanded (this also lets a range-exhausted column finish expanding the
     header with repeated pulls).
   - `pageCollapse = clamp(headerTravel, 0, H)` is the page line. Columns sitting **on** the
     line follow it in *both* directions — that's the page illusion, and it's what returns
     every synced column to its own top when the page expands. Columns behind the new line are
     caught up (no-hole invariant); deeper columns keep their position until the line reaches
     them.
   - Net effect: dragging any column down with the header expanded scrolls only that column's
     cards (header pinned at 0), and the "all group headers visible" state is always reachable.
   - The over-drag stretch (`pageCollapse < 0`) moves ALL columns with the sheet: locked ones
     follow the line, deeper ones are shifted by the stretch deltas (telescopes back to zero on
     settle, so their position is preserved). Without this the opaque header slid down over
     static neighbor columns during the bounce.

## Key files

- `Anytype/Sources/PresentationLayer/TextEditor/Set/Views/Kanban/Board/SetKanbanView.swift`
- `Anytype/Sources/PresentationLayer/TextEditor/Set/Views/Kanban/Column/SetKanbanColumn.swift`
- `Anytype/Sources/PresentationLayer/Common/SwiftUI/BasicComponents/ScrollAxisLock.swift`
- `Anytype/Sources/PresentationLayer/TextEditor/Set/EditorSetView.swift` (header ZStack, `offset`)
- `Anytype/Sources/PresentationLayer/TextEditor/Set/Views/Table/SetTableView.swift` (reference impl)
- `Anytype/Sources/PresentationLayer/TextEditor/Set/Views/Header/SetFullHeader.swift`
- `Anytype/Sources/PresentationLayer/Common/SwiftUI/BasicComponents/OffsetAwareScrollView.swift`
- Prior handoff: `docs/plans/20260714-ios-6579-kanban-scroll-fps-handoff.md`
