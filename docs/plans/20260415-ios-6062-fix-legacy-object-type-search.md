# IOS-6062 — Fix legacy object-type search assert + add long-press to legacy create button

## Overview

When the experimental toggle `newObjectCreationMenu` is OFF, the bottom Create button uses the legacy flow:
- Tap → creates an empty default-typed object → editor opens → keyboard accessory shows "Done" / "Show types" → tap "Show types" → horizontal type list + "Search" button → search screen.

Two bugs:

1. **Search screen asserts** `ObjectTypeProvider: Object type not found by uniqueKey: ot-note` on open and on every keystroke. Caused by `TypesPinStorage.getPins(spaceId:)` seeding default pins via throwing `objectType(uniqueKey:)` calls for `.page`, `.note`, `.task`. On sparse/new spaces those uniqueKeys aren't yet in the provider's cache (subscription only delivers types installed in the space), so the assert fires.
2. **Long-press missing** on the legacy Create button. Expected: long-press opens the object-type search screen so user picks a type FIRST, then the new object is created with that type.

## Context (from discovery)

**Files involved**
- `Anytype/Sources/ServiceLayer/Object/TypesService/TypesPinStorage.swift` — pin seeding bug source.
- `Anytype/Sources/PresentationLayer/Modules/HomeNavigationContainer/Panel/HomeBottomNavigationPanelView.swift` — legacy Create button (lines 166-175 inside the `else` branch of `if model.newObjectPlusMenu`).
- `Anytype/Sources/PresentationLayer/Flows/TypeSearchForNewObjectFlow/TypeSearchForNewObjectCoordinatorView.swift` — already-existing-but-currently-unused coordinator that wraps `ObjectTypeSearchView` + creates the chosen object via `objectActionsService.createObject` and emits the resulting object via the `openObject:` closure.

**Relevant patterns**
- `TypeSearchForNewObjectCoordinatorViewModel.createAndShowNewObject` already handles object creation, routing through `pageNavigation?.open(...)` for chat/bookmark and via `openObject(details)` for regular types. Already logs `route: .longTap`.
- The bottom panel emits `output?.onCreateObjectSelected(screenData: ScreenData)`. We can reuse this for the new object pushed back from the search flow.
- Pin storage is **local UserDefaults only** (`pinnedTypes` key) — middleware is unaware of pins. `getPins` first returns the saved-and-still-valid intersection; only seeds when nothing saved.

**Dependencies**
- None new. No new feature flag, no analytics changes, no localization.

## Development Approach
- **Testing approach**: no tests (per user; bug fix verified manually in Xcode).
- Small, focused edits in two files only.
- Verify build via Xcode after changes; user runs the legacy flow end-to-end.

## Solution Overview

### Part 1 — Root cause: `TypesPinStorage.getPins`
Replace the throwing seeding with a non-throwing `compactMap` over the three default uniqueKeys, and **only persist** when the result is non-empty. If the cache hasn't delivered any of page/note/task yet, return `[]` and leave storage uninitialized so the next call (after the subscription updates) can seed properly.

### Part 2 — Long-press on legacy Create button
Reuse the existing `TypeSearchForNewObjectCoordinatorView`. Present it as a local `.sheet` directly on the legacy `Button` — naturally gated to the legacy branch since it lives inside the `else` of `if model.newObjectPlusMenu`. The coordinator's `openObject:` closure forwards the created object via the panel's existing `output?.onCreateObjectSelected(screenData: details.editorScreenData())`. No new output method, no `AlertScreenData` case, no SpaceHub plumbing.

## Technical Details

### Part 1 — `TypesPinStorage.swift`

Current (lines 27-33):
```swift
let page = try typeProvider.objectType(uniqueKey: .page, spaceId: spaceId)
let note = try typeProvider.objectType(uniqueKey: .note, spaceId: spaceId)
let task = try typeProvider.objectType(uniqueKey: .task, spaceId: spaceId)
let defaultPins = [ note, page, task ]

setPins(defaultPins, spaceId: spaceId)
return defaultPins
```

New:
```swift
let defaultPins = [ObjectTypeUniqueKey.note, .page, .task]
    .compactMap { try? typeProvider.objectType(uniqueKey: $0, spaceId: spaceId) }

if defaultPins.isNotEmpty {
    setPins(defaultPins, spaceId: spaceId)
}
return defaultPins
```

Behaviour: stops the assert. On a fresh/sparse space the first `getPins` call returns `[]` without persisting; once the type subscription delivers the missing types, the next call seeds normally.

### Part 2 — `HomeBottomNavigationPanelView.swift` + `HomeBottomNavigationPanelViewModel.swift`

`HomeBottomNavigationPanelViewModel` already owns `info` and `output`. Route through the model — don't duplicate state on the view. The view contributes only `@State showTypeSearch` (sheet presentation is local) and an `@Environment(\.pageNavigation)` read forwarded into the sheet content.

Changes:

**View model** — add:
```swift
var spaceId: String { info.accountSpaceId }

func onLongPressNewObject(details: ObjectDetails) {
    output?.onCreateObjectSelected(screenData: details.editorScreenData())
}
```

**View** — `HomeBottomNavigationPanelViewInternal`:
1. Add `@State private var showTypeSearch: Bool = false`.
2. Add `@Environment(\.pageNavigation) private var pageNavigation` (so we can forward it across the sheet boundary — env values do not reliably cross sheets).
3. On the legacy `Button` (line 166), use `.simultaneousGesture(...)` instead of `.onLongPressGesture` to avoid the `Button` swallowing tap or vice versa:
   ```swift
   .simultaneousGesture(
       LongPressGesture(minimumDuration: 0.5).onEnded { _ in
           showTypeSearch = true
       }
   )
   ```
4. Attach the sheet on the legacy `Button` (so it's structurally gated to `newObjectPlusMenu == false`):
   ```swift
   .sheet(isPresented: $showTypeSearch) {
       TypeSearchForNewObjectCoordinatorView(spaceId: model.spaceId) { details in
           model.onLongPressNewObject(details: details)
       }
       .pageNavigation(pageNavigation)
   }
   ```

Notes:
- `TypeSearchForNewObjectCoordinatorView` reads `@Environment(\.pageNavigation)` in `onAppear` to support the chat / bookmark redirect screens. SwiftUI environment values do **not** reliably cross sheet boundaries, so we explicitly forward via `.pageNavigation(pageNavigation)`.
- All routing for the created object stays inside the view model — consistent with every other panel action.

## What Goes Where

- **Implementation Steps**: code changes in two files.
- **Post-Completion**: manual verification in Xcode of both bugs.

## Implementation Steps

### Task 1: Fix `TypesPinStorage.getPins` to tolerate missing types

**Files:**
- Modify: `Anytype/Sources/ServiceLayer/Object/TypesService/TypesPinStorage.swift`

- [ ] replace lines 27-33 with the `compactMap` + `try?` version above
- [ ] only call `setPins(_:spaceId:)` when `defaultPins.isNotEmpty`
- [ ] verify file still compiles
- [ ] no tests added (per user)

Edge case noted: `appendPin` / `removePin` both call `getPins` internally. If the user pins a type while the cache has none of page/note/task, the default seed never lands for that space (the user-pinned set persists instead). Acceptable — user explicitly took an action.

### Task 2: Add long-press on legacy Create button → search sheet

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeNavigationContainer/Panel/HomeBottomNavigationPanelView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeNavigationContainer/Panel/HomeBottomNavigationPanelViewModel.swift`

View model:
- [ ] add `var spaceId: String { info.accountSpaceId }`
- [ ] add `func onLongPressNewObject(details: ObjectDetails)` that calls `output?.onCreateObjectSelected(screenData: details.editorScreenData())`

View (`HomeBottomNavigationPanelViewInternal`):
- [ ] add `@State private var showTypeSearch: Bool = false`
- [ ] add `@Environment(\.pageNavigation) private var pageNavigation`
- [ ] on the legacy `Button` (line 166), add `.simultaneousGesture(LongPressGesture(minimumDuration: 0.5).onEnded { _ in showTypeSearch = true })` (NOT `.onLongPressGesture` — it interferes with `Button` tap)
- [ ] attach `.sheet(isPresented: $showTypeSearch) { TypeSearchForNewObjectCoordinatorView(spaceId: model.spaceId) { details in model.onLongPressNewObject(details: details) }.pageNavigation(pageNavigation) }` on the same Button
- [ ] verify sheet only attaches in the `else` branch (legacy button only) — structurally enforced

### Task 3: Verify acceptance criteria

- [ ] build succeeds in Xcode
- [ ] toggle `Settings → Experimental → New Object Creation Menu` OFF
- [ ] **short-tap** on legacy Create New still opens default-typed editor (regression check — long-press gesture must not swallow tap)
- [ ] tap Create New → editor opens → Show types → Search → typing produces results, **no `ObjectTypeProvider` assert in console**
- [ ] long-press Create New → search sheet opens → pick a regular type → object created and editor pushed onto stack
- [ ] long-press Create New → pick **Bookmark** type → bookmark create alert opens (verifies `pageNavigation` propagates across sheet)
- [ ] long-press Create New → pick **Chat** type → chat create alert opens (same propagation check)
- [ ] toggle ON again → tap Create New shows the menu (unchanged); long-press does nothing in the new flow

### Task 4: Final
- [ ] move this plan to `docs/plans/completed/`

## Post-Completion

**Manual verification (user, in Xcode)**
- Both bugs above on a freshly created space (worst case for `getPins` seeding).
- Confirm long-press still works on iOS 26 with Liquid Glass on the Create button.
