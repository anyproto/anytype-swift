# IOS-6208 Re-introduce Home Widgets Animations

## Overview

Re-introduce animations to the HomeWidgets module after the IOS-5812 baseline strip. Goal: a tasteful, Apple-feeling reveal/interaction layer that does NOT mask data-arrival problems (those are fixed by the pre-seed + gate work).

Branch: `ios-6208-add-animations-to-home-widgets-view`
Depends on: IOS-5812 (widget loading gate/pre-seed), IOS-6158 (god-object split into section View+VM).

## Guiding principle

Animation is communication, not decoration.

- **Spring curves** (`.spring`, `.bouncy`) → only on direct user input (taps, drags, edit toggle). Bounciness means "I'm responding to you."
- **Smooth/snappy curves** (`.smooth`, `.snappy`, critically damped) → on system-caused changes (data arrival, gate open, sync). No bounce.
- **No opacity-only transitions** when a richer transition fits — pure opacity makes content feel like it was always there but invisible.
- **No `withAnimation` to mask loading flashes** — fix the data layer instead.

## Current observed gaps (from user testing on this branch)

1. Section header chevron rotates, but the **body content snaps** — disclosure feels broken.
2. Tree row body snaps on expand.
3. After loading completes there is a one-frame empty widgets screen, then content **cuts in** with no continuity.
4. Pinned DnD already reflows smoothly (native SwiftUI handles it — leave alone).

## What stays removed (do not restore)

| Surface | Reason |
|---|---|
| `HomeWidgetsView` `@State` counts + `.animation(.default, value:)` plumbing through Pinned/MyFavorites/RecentlyEdited | Workaround for sections springing on data arrival. Gate + pre-seed obviates it. |
| `WidgetContainerViewModel.updateExpanded(animated:)` auto-expand on loading→hasData | System-driven twitch on first load. Seed initial expanded state correctly via pre-warm instead. |
| Per-row `withAnimation` in `ListWidgetViewModel.updateViewState/updateHeader`, `SetObjectWidgetInternalViewModel`, `TreeWidgetViewModel.updateTree`, `MyFavoritesListViewModel.update`, `RecentlyEditedListViewModel.update` | These fire on both first paint and sync. With gate + pre-seed working, leave these as hard cuts. Revisit only if a concrete sync-driven flicker is reported. |
| `PinnedSectionViewModel.widgetsDropUpdate` `withAnimation` around `widgetBlocks.move(...)` | SwiftUI's native drag-reorder already animates the reflow. The manual wrap was redundant. |
| `HomeUpdateView` 4s gradient pulse | Pure decoration. Apple doesn't pulse buttons. |
| `InviteMembersStubWidgetView` `.animation(.default, value: showInviteMembers)` 12pt padding flip | Animating a layout change in response to a non-user state change is micro-jitter. |

## Animation specs to implement

### Curve reference

| Surface | Transition | Curve |
|---|---|---|
| Section expand body | move(.top) + opacity, asymmetric | `.snappy(duration: 0.28, extraBounce: 0.05)` |
| Tree row expand body | move(.top) + opacity | `.snappy(duration: 0.22)` |
| Edit-mode badges | scale(0.6) + opacity, asymmetric insertion/removal | `.spring(response: 0.35, dampingFraction: 0.7)` insertion, `.easeOut(0.12)` removal |
| Pinned tile add/remove | scale(0.94) + opacity | `.spring(response: 0.4, dampingFraction: 0.85)` |
| Recently-edited row add/remove | move(.leading) + opacity | `.smooth(duration: 0.3)` |
| Gate-open widget reveal | move(.bottom) + opacity, staggered 40ms/index | `.smooth(duration: 0.35)` + `delay(index * 0.04)` |

### Tier 1 — Disclosure / hierarchy reveal (user-driven)

These are the must-haves. Tapping a chevron must move the content, not just the chevron.

**1.1 Section header expand/collapse** — restore `withAnimation { isExpanded.toggle() }` in:
- `MyFavoritesSectionViewModel.onTapHeader`
- `RecentlyEditedSectionViewModel.onTapHeader`
- `ObjectTypesSectionViewModel.onTapObjectTypeHeader`
- `UnreadSectionViewModel.onTapUnreadHeader`
- `LinkWidgetViewContainer` arrow button `withAnimation { isExpanded.toggle() }`

Animation:
```swift
withAnimation(.snappy(duration: 0.28, extraBounce: 0.05)) {
    isExpanded.toggle()
}
```

On the section content view (the conditional body), add:
```swift
.transition(.asymmetric(
    insertion: .move(edge: .top).combined(with: .opacity),
    removal: .opacity
))
```

Rationale: asymmetric — insertion deserves the slide so it reads as "tucked above"; removal can fade out faster so the header doesn't feel stuck waiting.

**1.2 Tree row expand/collapse** — `TreeWidgetRowView.tapExpand` / `tapCollapse`:

```swift
withAnimation(.snappy(duration: 0.22)) { ... }
```

Children container transition:
```swift
.transition(.move(edge: .top).combined(with: .opacity))
```

Slightly faster than section expand because nested rows are smaller; slower would read as laggy.

### Tier 2 — User-initiated, indirect

**2.1 Edit-mode affordances** — restore `.animation(.default, value: homeState)` on `HomeEditButtonStyle` and `LinkWidgetViewContainer`, but with proper transitions on the affordance icons themselves:

```swift
.transition(.asymmetric(
    insertion: .scale(scale: 0.6, anchor: .center)
                .combined(with: .opacity)
                .animation(.spring(response: 0.35, dampingFraction: 0.7)),
    removal: .opacity.animation(.easeOut(duration: 0.12))
))
```

Damping 0.7 gives a tiny overshoot — same feel as iOS context-menu badges. Removal is hard fade so leaving edit mode feels decisive.

**2.2 Pinned add/remove** — restore `withAnimation` around row update in `PinnedSectionViewModel.update`, **guarded so it does not fire on first load** (use `rows.isNil` style guard or check against pre-seed state):

```swift
withAnimation(rows.isEmpty || !isReady ? nil : .spring(response: 0.4, dampingFraction: 0.85)) {
    rows = newRows
}
```

Row transition:
```swift
.transition(.scale(scale: 0.94, anchor: .center).combined(with: .opacity))
```

**2.3 Recently-edited row add/remove** — same idea, but slide from leading edge to match the list-row metaphor:

```swift
.transition(.move(edge: .leading).combined(with: .opacity))
.animation(.smooth(duration: 0.3), value: rows)
```

Same first-load guard as 2.2.

### Tier 3 — Gate-open reveal (system-driven, most impactful)

User reports: after loading, widgets cut in with no continuity. Fix: a staggered reveal driven by a single gate-open signal.

**Prerequisite**: section/widget VMs must expose a published `isReady: Bool` that flips `false → true` exactly once when pre-warm completes / gate opens, and stays true. Do NOT key transitions on `hasData` or row presence — that re-introduces the original flicker bug (every empty-then-populated sync cycle would fade the whole widget).

**3.1 Per-widget reveal inside a section** — in the `ForEach` rendering widgets within a section:

```swift
ForEach(Array(widgets.enumerated()), id: \.element.id) { index, widget in
    WidgetView(...)
        .transition(.move(edge: .bottom).combined(with: .opacity))
        .animation(
            .smooth(duration: 0.35).delay(Double(index) * 0.04),
            value: isReady
        )
}
```

- 40ms stagger is the Apple-feeling sweet spot (≥60ms reads as "loading", <30ms reads as "all at once").
- `.smooth` is critically damped — no bounce, correct for system-caused change.
- 8pt of upward travel (SwiftUI default for `.move(edge: .bottom)`) is enough to register against the navigation slide without competing with it.

**3.2 Section-level reveal** — header + body should reveal as one unit, otherwise the header is briefly visible while the body is empty:

Wrap the whole section (header + content) in a single conditional driven by `isReady`. The section's outer container takes `.transition(.opacity)` and is animated by the same `.smooth(0.35)` curve, with its own stagger if multiple sections need to reveal sequentially (e.g. Pinned at delay 0, MyFavorites at delay 0.08, RecentlyEdited at delay 0.16).

**3.3 Optional: blur burn-off on iOS 17+**

If we want a more distinctive reveal for the gate open (matches iOS 18 Photos memories materialization, and aligns with iOS 26 Liquid Glass direction):

```swift
.blur(radius: isReady ? 0 : 6)
.opacity(isReady ? 1 : 0)
.offset(y: isReady ? 0 : 8)
.animation(.smooth(duration: 0.4).delay(Double(index) * 0.04), value: isReady)
```

**Performance caveat**: blur is the most expensive option here. Verify on the slowest supported device (older A-chip iPads) before committing. If perf is a concern, ship 3.1 + 3.2 first; treat 3.3 as a follow-up gated on profiling.

## Shipping order

Split into independent PRs so each can be verified visually and reverted in isolation.

**PR 1 — Tier 1 disclosure animations.** Section header expand/collapse + tree row expand. Lowest risk, highest perceived improvement. Touches only the four section VMs, LinkWidgetViewContainer, and TreeWidgetRowView/its content view.

**PR 2 — Tier 3.1 + 3.2 gate-open reveal.** Requires the `isReady` published flag on section/widget VMs first. This is the visible-flash fix and the most user-facing PR. Verify on slow device and on cold-cache space switches.

**PR 3 — Tier 2 polish.** Edit-mode affordances + Pinned/Recently-edited row inserts. Smaller blast radius; ship after the structural pieces land.

**(Optional) PR 4 — Tier 3.3 blur burn-off.** Only if profiling supports it.

## Prerequisites / open questions

- **`isReady` signal**: confirm where the gate-open state currently lives (pre-warm actors per IOS-5812 PR 3). It must be reachable by the View as an animatable Bool. If it's only an internal actor flag, expose a `@Published var isReady: Bool` on the section ViewModels.
- **First-load guard for Tier 2.2 / 2.3**: confirm pre-seed populates `rows` before first render. If yes, `rows.isEmpty` is a safe proxy for "this is the first load, do not animate." If pre-seed gives us a non-empty initial array, we need a different guard (e.g. `isReady` flipped + `firstUpdatePassed: Bool`).
- **Stagger across sections vs within sections**: decide whether the three top-level sections reveal sequentially (Pinned → MyFavorites → RecentlyEdited) or simultaneously. Sequential is more theatrical; simultaneous is faster. Default to simultaneous within each section, with a tiny inter-section delay (~80ms) if it reads better in practice.

## Out of scope

- WidgetSwipeActionView animations (already preserved).
- SpaceHubCoordinatorView cross-space swipe (outside HomeWidgets).
- HomeWidgetsCoordinatorView homepage-picker overlay fade (already added by loader-bridge commit).
- `menuDismissAnimationDelay` constant (not a SwiftUI animation; alignment with iOS context-menu timing).

## Acceptance criteria

- Tapping any section header animates the body, not just the chevron.
- Tapping any tree row chevron animates the children expand/collapse.
- Entering a space cold no longer shows a one-frame empty widgets screen followed by a cut — content reveals with continuity (move + fade, staggered).
- Entering/leaving edit mode animates the affordance badges with a soft scale.
- Adding/removing a pinned widget lands the tile rather than popping it in.
- No animation fires on widget content during background sync updates (data updates remain hard cuts).
- No regression in DnD: pinned reorder still animates smoothly via SwiftUI's native machinery.
