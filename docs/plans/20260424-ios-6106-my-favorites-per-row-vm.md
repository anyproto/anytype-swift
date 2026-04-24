# IOS-6106 My Favorites Per-Row ViewModel Refactor

## Overview

Fix the IOS-6106 drag-cancel crash (`EXC_BAD_ACCESS` in `AG::Graph::value_ref` → `SwiftUI DragAndDropBridge.dragInteraction(_:previewForCancelling:withDefault:)`) by removing high-frequency external subscriptions from the parent `MyFavoritesViewModel` and relocating per-row state (chat badge, channel-pin flag, can-manage-channel-pins flag) into per-row ownership that mirrors how block widgets are wired (`LinkWidgetViewModel` inside `LinkWidgetInternalView`).

Crash context: EXC_BAD_ACCESS at 0x1a8 in AttributeGraph → SwiftUI drag-cancel preview lookup on iOS 26.3.1 (iPhone 17 Pro). Stack resolved; log reviewed privately — not committed.

Linear: IOS-6106. Parent: IOS-5864 Personal Favorites. Branch: `ios-6106-crash-after-dnd-of-the-object-down-the-screen-widget`.

**Acceptance criterion**: no `EXC_BAD_ACCESS` on drag cancel for MyFavorites rows on iOS 26.3+; chat badges continue to update live; IOS-6104/6105 behavior preserved; block-widgets reorder (same delegate) not regressed — including the "user drags outside the pinned section and releases" path.

Two prior fixes already landed in this area and must not regress:
- **PR #4871 (IOS-6104)**: `setZeroOpacity` guarded with `dragInProgress` so long-press→context-menu does not hide the row.
- **PR #4872 (IOS-6105)**: `DragItemProvider.deinit` defers `didEnd?()` via `DispatchQueue.main.async` to avoid `@Binding` re-entry.

## Shipping as two independent PRs

The work is split into two phases, each self-contained and independently verifiable. Pick either to ship alone if needed; together they cover the full story.

- **Phase A — per-row ViewModel refactor** (PR 1, expected crash fix). Eliminates the churn on `MyFavoritesViewModel.rows` caused by chat/space/pin traffic. Verifiable on its own with the IOS-6106 reproducer: after Phase A alone, dragging to the bottom should no longer crash.
- **Phase B — DnD commit-on-drag-end** (PR 2, UX + hygiene). Moves the server RPC off `dropExited` to actual drag-end. Verifiable on its own as "drop outside MyFavorites zone still commits the last in-zone visual position" (matching block-widgets behavior today, and matching the user's explicit UX ask on IOS-6106). Also removes a residual mid-drag server-round-trip that could re-provoke the crash in future.

The branch is already `ios-6106-...`. Plan of record: open PR 1 for Phase A first (merge independently). Then either continue on the same branch or cut a new branch off develop for Phase B. Either is fine as long as Phase B does not piggy-back on unmerged Phase A changes.

## Context (from discovery)

**Files in scope**:
- `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesViewModel.swift`
- `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesListView.swift`
- `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesRowView.swift`
- `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesRowData.swift`
- `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/HomeWidgetsView.swift`
- `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/HomeWidgetsViewModel.swift`
- `Anytype/Sources/PresentationLayer/Common/SwiftUI/DragAndDrop/DragAndDropVerticalDelegate.swift`
- `Anytype/Sources/PresentationLayer/Common/SwiftUI/DragAndDrop/View+DragAndDrop.swift`
- `Anytype/Sources/PresentationLayer/Common/SwiftUI/DragAndDrop/DragAndDropModels.swift`

**Patterns to copy (block widgets)**:
- `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Link/LinkWidgetViewModel.swift` (per-row badge VM, lazy `spaceView` read)
- `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Link/LinkWidgetView.swift` (`.id(widgetBlockId)` + `@State` per-row VM + `.task { await model.startSubscriptions() }`)

**Mock / test-suite situation** (pre-resolved): no XCTest suites for `MyFavoritesViewModel`, `LinkWidgetViewModel`, or similar SwiftUI VMs in this module; no `ChatMessagesPreviewsStorageMock` for tests (existing `SpaceViewsStorageMock` lives under `Anytype/Sources/PreviewMocks/` and serves SwiftUI previews only). Project convention for thin SwiftUI view-model glue is **no new unit tests** — manual QA is the verification path. This plan follows that convention.

## Discovered design (current, crashing)

`MyFavoritesViewModel` owns a fat `rows: [MyFavoritesRowData]` array and a single `recomputeRows()` called from **four** async streams, with only one being high-frequency:

```
personalWidgetsObject.syncPublisher           → structural (add/remove/reorder)   [low freq]
chatMessagesPreviewsStorage.previewsSequence  → per-row chat badge                 [HIGH freq: every message / read / typing]
spaceViewsStorage.spaceViewPublisher          → per-row badge formatting           [low-to-medium freq]
channelWidgetsObject.syncPublisher            → pinnedToChannelObjectIds Set       [low freq]
```

Plus a computed property `canManageChannelPins` reading `participantSpacesStorage` on each evaluation.

`MyFavoritesRowData` carries `chatPreview: MessagePreviewModel?` inline, so **every chat tick rebuilds every row struct and re-assigns `rows`**. The `@Observable` property `pinnedToChannelObjectIds` also invalidates the list view on every channelWidgets sync.

During an active drag session, this causes the `ForEach(Array(model.rows.enumerated()), id: \.element.id)` body in `MyFavoritesListView` to re-evaluate under the live UIKit drag interaction. Under iOS 26, the row's attached `.contentShape(.dragPreview, RoundedRectangle(cornerRadius: 24, ...))` node gets evicted from SwiftUI's AttributeGraph. When the user releases outside every drop zone, UIKit plays the cancel animation and asks SwiftUI for the source preview via `previewForCancelling`, which re-enters the AttributeGraph to rebuild it. The node is gone → null deref at `0x1a8`.

Compounded by `DragAndDropVerticalDelegate.dropExited` firing `dropFinish` (the `objectActionsService.move(...)` RPC) mid-drag, whose response triggers yet another `recomputeRows()` while the drag is still live.

Block widgets (same DnD stack, same delegate) do **not** crash because:
- `HomeWidgetsViewModel.widgetBlocks` is a skinny `[BlockWidgetInfo]` updated only from `channelWidgetsObject.syncPublisher`. Chat previews and space-view traffic never touch it.
- Per-widget state (chat badge, name, icon, drag id) lives in child `@State` ViewModels (e.g., `LinkWidgetViewModel`) instantiated inside each row view with `.id(widgetBlockId)`, each subscribing independently. Parent array stays stable under chat traffic.

## Proposed design (target, mirrors block widgets)

1. **Skinny `MyFavoritesRowData`**: drop `chatPreview`. Keep `id`, `objectId`, `title`, `icon`, `onTap`. **`id` stays the widget block id** (not object id) because `MyFavoritesViewModel.dropFinish` passes `from.data.id` as the `blockId` argument to `objectActionsService.move(...)` — changing `id` semantics would silently break reorder persistence.
2. **Skinny parent `MyFavoritesViewModel`**: keep ONLY `personalWidgetsObject.syncPublisher`. Delete `startChatPreviewsSubscription`, `startSpaceViewSubscription`, `startChannelPinsSubscription`. Delete `pinnedToChannelObjectIds`, `canManageChannelPins`, `chatPreviews`, `spaceView`, `previewsByChatId`. Drop `chatMessagesPreviewsStorage`, `spaceViewsStorage`, `participantSpacesStorage`, `widgetChatPreviewBuilder` injections. Drop `channelWidgetsObject` from the VM entirely (not used after the refactor); call sites that still need it read it from `HomeWidgetsViewModel.channelWidgetsObject` directly. Expose `spaceId` publicly so the list view can forward it to per-row VMs.
3. **New `MyFavoritesRowViewModel`** — `@MainActor @Observable` final class. Signature: `init(objectId: String, spaceId: String)`. (Unlike `LinkWidgetViewModel` we pass raw ids because there is no widget-block document layer under a favorites row — identity is the target object id.) Injections: `chatMessagesPreviewsStorage`, `spaceViewsStorage`, `widgetChatPreviewBuilder`. Exposes `private(set) var badgeModel: MessagePreviewModel?`. `startSubscriptions()` runs `startChatPreviewsSubscription()` which iterates `chatMessagesPreviewsStorage.previewsSequence`, stores latest, calls `updateBadgeModel()`. `updateBadgeModel()` looks up preview by `chatId == objectId`, reads `spaceView` via `spaceViewsStorage.spaceView(spaceId:)` (lazy, synchronous), builds via `chatPreviewBuilder.build(chatPreview:spaceView:)` — same shape as `LinkWidgetViewModel.updateBadgeModel`.
4. **Per-row VM instantiation**: split `MyFavoritesRowView` into an outer `MyFavoritesRowView` + internal `MyFavoritesRowInternalView` (mirror `LinkWidgetView` / `LinkWidgetInternalView`). The outer wraps `MyFavoritesRowInternalView(...).id(row.id)`. The internal view holds `@State private var rowModel: MyFavoritesRowViewModel` initialized from `(row.objectId, spaceId)`, wires `.task { await rowModel.startSubscriptions() }`. **`.setZeroOpacity(...)` and `.anytypeVerticalDrag(itemId: row.id)` stay at the list-level (in `MyFavoritesListView`), not inside the internal view** — they depend on `@Environment(\.anytypeDragState)` injected by `AnytypeVerticalDropViewModifier` on the list wrapper.
5. **Pin flags on-demand, not observed**: `isPinnedToChannel` and `canManageChannelPins` move into `MyFavoritesRowContextMenuViewModel` as synchronous reads. The VM **stays an `ObservableObject` used with `@StateObject`** — we just add two synchronous methods. No new `@Published` state. SwiftUI evaluates `.contextMenu { ... }` content lazily on presentation, so synchronous reads at that moment are sufficient; staleness within a single menu session is acceptable.
6. **DnD hygiene — commit on drag end, not zone exit** (Phase B; detailed wire-up below).

Held in reserve, not in scope: `.onDrag(_:preview:)` switch in `AnytypeVerticalDragViewModifier`. Only reach for it if the crash still reproduces after both phases land.

### Phase B wire-up (resolved here, not at code time)

Today: `DragAndDropVerticalDelegate.dropExited` calls `dropFinish(from, to)` → server RPC while user is still dragging. We defer the RPC to **actual drag end** (drop-inside OR drag-cancel outside) so the round-trip and the resulting `recomputeRows` never run during a live drag.

Design (Phase B):
- New class in `DragAndDropModels.swift`, sibling to `DragAndDropFrames`:
  ```swift
  final class DragAndDropPendingCommit {
      var commit: (() -> Void)?
  }
  ```
- New env key mirroring `\.anytypeDragAndDropFrames`:
  ```swift
  extension EnvironmentValues {
      @Entry var anytypeDragAndDropPendingCommit = DragAndDropPendingCommit()
  }
  ```
- `AnytypeVerticalDropViewModifier` creates `@State private var pendingCommit = DragAndDropPendingCommit()` and injects it via `.environment(\.anytypeDragAndDropPendingCommit, pendingCommit)` alongside the existing frames env.
- `DragAndDropVerticalDelegate` takes `pendingCommit: DragAndDropPendingCommit` as a property (sibling of `framesStorage`). In `dropUpdated`, after computing `(fromElement, toElement)`, it assigns:
  ```swift
  pendingCommit.commit = { [dropFinish] in dropFinish(fromElement, toElement) }
  ```
  (struct values captured by copy — no `@Binding`s, no view types).
- `dropExited` no longer calls `dropFinish`. It only resets the visual drop state (`dropState.resetState()`). `pendingCommit.commit` stays intact so the drag-end path can fire it.
- `performDrop`, on in-zone success: invokes `dropFinish(from, to)` as today, then sets `pendingCommit.commit = nil` before returning (so drag-end does not double-commit). On the guard-else path, also clears `pendingCommit.commit = nil` defensively.
- `AnytypeVerticalDragViewModifier` reads `@Environment(\.anytypeDragAndDropPendingCommit)` and wires the drag-end hook inside `.onDrag`:
  ```swift
  let pendingCommit = self.pendingCommit
  provider.didEnd = {
      state.resetState()
      let commit = pendingCommit.commit
      pendingCommit.commit = nil
      commit?()   // fires RPC only if performDrop did not clear it
  }
  ```
  The existing `DispatchQueue.main.async` inside `DragItemProvider.deinit` (IOS-6105 fix) stays untouched.

Works for **both consumers** (MyFavorites AND `HomeWidgetsView.blockWidgets`) because the plumbing lives on the generic modifiers, not on either call site. Each consumer uses its own `@State` `DragAndDropPendingCommit` instance (since each `AnytypeVerticalDropViewModifier` has its own).

## Development Approach

- **testing approach**: Regular (code first). No new unit tests — matches project convention for SwiftUI view-model glue in this module.
- complete each task fully before moving to the next
- make small, focused changes — **every intermediate task inside a phase must leave the project compiling**
- **do NOT run the simulator build after each task** — simulator builds are slow; verify only at phase boundaries
- update this plan file when scope changes during implementation (`➕` for additions, `⚠️` for blockers)
- maintain backward compatibility
- do not regress IOS-6104 or IOS-6105
- tasks are numbered `A1…A5` and `B1` so work can be resumed mid-phase across multiple sessions — mark tasks `[x]` as you go; the plan file is the source of truth

## Testing Strategy

- **unit tests**: none (per project convention + mock availability).
- **e2e tests**: project has none — skip.
- **manual QA** — verifies the fix on real hardware. Run at phase-end, not per task:
  - **IOS-6106 reproducer** (Phase A acceptance): iPhone 17 Pro on iOS 26.3.1 (simulator is not authoritative for this crash — the AttributeGraph eviction is iOS-26-specific). 5–10 favorites, long-press a row, drag to the very bottom past Types toward the Bin, release → no crash.
  - **Mid-drag sync churn** (Phase A, defense-in-depth): while dragging, trigger a `personalWidgetsObject` sync event (add a favorite on a second device signed in to the same account), then cancel by releasing outside → no crash.
- **Regression walk-through** — run at each phase-end:
  - IOS-6104: long-press a MyFavorites row, context menu appears, dismiss without action → row stays visible.
  - IOS-6105: Favorite / Unfavorite / Pin / Unpin from widget long-press menu → navigate to Vault → no SIGABRT.
  - Chat badges on MyFavorites rows update in real time.
  - Pin / Unpin to channel menu item shows the correct label for Owner/Admin; hidden for Member/Viewer.
  - Drag-reorder within MyFavorites persists on drop inside the zone.
  - Drag-reorder within block widgets (`HomeWidgetsView.blockWidgets`, same delegate): drop inside the pinned section still commits. **For Phase B**: drop outside the pinned section also commits (was working today via `dropExited`; after Phase B it fires from the drag-end path) — explicitly verify.

## Progress Tracking

- mark completed items with `[x]` immediately when done (this file is the single source of truth across sessions)
- add newly discovered tasks with `➕` prefix
- document issues/blockers with `⚠️` prefix
- update plan if implementation deviates from original scope

## Solution Overview

Align `MyFavorites` architecture with `blockWidgets`: parent VM owns only the structural list; per-row VMs own per-row state. This eliminates chat-preview-driven churn on the parent array that is evicting drag-preview attributes from SwiftUI's graph mid-drag. The DnD hygiene change (Phase B) moves the server RPC off the mid-drag `dropExited` path via a shared `DragAndDropPendingCommit` environment box, giving the user the "drop outside = commit last visual state" UX while preserving the block-widgets consumer.

## Technical Details

- `MyFavoritesRowViewModel(objectId: String, spaceId: String)` — no block/document wrapper; identity is the target object id.
- Per-row VM is `@State private var model: MyFavoritesRowViewModel` inside `MyFavoritesRowInternalView`, initialized from `(row.objectId, spaceId)`, exactly like `LinkWidgetInternalView`.
- `MyFavoritesRowContextMenuViewModel` stays an `ObservableObject`/`@StateObject`; we add two synchronous methods, no `@Published` additions.
- `DragAndDropPendingCommit` is a reference-type box (mirror of `DragAndDropFrames`), held by the drop modifier as `@State`, exposed via `@Environment` to drag children.

## What Goes Where

- **Implementation Steps** (`[ ]` checkboxes): Swift source edits under `Anytype/Sources/...`.
- **Post-Completion** (no checkboxes): device-based reproducer validation and regression walk-through per phase.

## Implementation Steps

### Phase A — Per-row ViewModel refactor (PR 1)

**Goal**: stop `MyFavoritesViewModel.rows` from being rebuilt on chat / space / pin traffic. Expected to close IOS-6106 on its own.

**Branch**: `ios-6106-crash-after-dnd-of-the-object-down-the-screen-widget` (current).

**Working agreement**: every intermediate task inside Phase A must leave the project compiling. No simulator build required between tasks.

#### Task A1: Add `MyFavoritesRowViewModel` (new file, standalone)

**Files:**
- Create: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesRowViewModel.swift`

- [ ] create `@MainActor @Observable` final class `MyFavoritesRowViewModel`
- [ ] injections (`@ObservationIgnored @Injected`): `chatMessagesPreviewsStorage`, `spaceViewsStorage`, `widgetChatPreviewBuilder`
- [ ] initializer `init(objectId: String, spaceId: String)`
- [ ] stored (`@ObservationIgnored`): `objectId`, `spaceId`, `chatPreviews: [ChatMessagePreview] = []`
- [ ] exposed: `private(set) var badgeModel: MessagePreviewModel?`
- [ ] `func startSubscriptions() async` → runs `startChatPreviewsSubscription()`
- [ ] `startChatPreviewsSubscription()` iterates `chatMessagesPreviewsStorage.previewsSequence`, assigns `chatPreviews`, calls `updateBadgeModel()`
- [ ] `updateBadgeModel()`: find preview where `chatId == objectId`, read `spaceView = spaceViewsStorage.spaceView(spaceId: spaceId)`, build via `chatPreviewBuilder.build(chatPreview:spaceView:)` — copy shape from `LinkWidgetViewModel.updateBadgeModel`

#### Task A2: Add `MyFavoritesRowInternalView` + wire the per-row VM + plumb `spaceId`

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesViewModel.swift` (expose `spaceId` publicly)
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesListView.swift` (pass `spaceId` to each row)
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesRowView.swift` (outer + new internal view)

- [ ] remove `private` from `spaceId` on `MyFavoritesViewModel` (or expose via a public `let`/computed accessor) so the view can read it
- [ ] in `MyFavoritesListView.swift`, pass `spaceId: model.spaceId` into each `MyFavoritesRowView`
- [ ] split `MyFavoritesRowView` — the outer struct now wraps `MyFavoritesRowInternalView(...).id(row.id)`, threading through the existing parameters including `canManageChannelPins` and `isPinnedToChannel` (these are removed in Task A3; leave them wired for now so the project keeps compiling)
- [ ] inside `MyFavoritesRowInternalView`, hold `@State private var rowModel: MyFavoritesRowViewModel`; init from `(row.objectId, spaceId)` exactly like `LinkWidgetInternalView` inits `LinkWidgetViewModel`
- [ ] add `.task { await rowModel.startSubscriptions() }` on the internal view's body
- [ ] in the chat-badge branch of the body, replace `row.chatPreview` with `rowModel.badgeModel`. `MyFavoritesRowData.chatPreview` still exists and is still populated by the parent VM at this point — just stop reading it from the view.
- [ ] **keep `.setZeroOpacity(...)` and `.anytypeVerticalDrag(itemId: row.id)` at list-level in `MyFavoritesListView`** — do not move them into `MyFavoritesRowInternalView`

#### Task A3: Move pin flags + can-manage flag into the context-menu VM

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesRowView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesListView.swift`

- [ ] add `func isPinnedToChannel(objectId: String, channelWidgetsObject: any BaseDocumentProtocol) -> Bool` to `MyFavoritesRowContextMenuViewModel` — iterate `channelWidgetsObject.children` filtered by `isWidget`, match `.object(details)` with `details.id == objectId`
- [ ] add `@Injected(\.participantSpacesStorage) private var participantSpacesStorage` plus `func canManageChannelPins(spaceId: String) -> Bool` reading `participantSpacesStorage.participantSpaceView(spaceId:)?.canManageChannelPins ?? false`
- [ ] keep `MyFavoritesRowContextMenuViewModel` as `ObservableObject` used with `@StateObject` — no `@Published` added
- [ ] update the inner `MyFavoritesRowContextMenu`:
  - drop `canManageChannelPins: Bool` and `isPinnedToChannel: Bool` from its parameters
  - add `let spaceId: String`
  - in `body`, replace the static `canManageChannelPins` / `isPinnedToChannel` reads with `model.canManageChannelPins(spaceId: spaceId)` and `model.isPinnedToChannel(objectId: objectId, channelWidgetsObject: channelWidgetsObject)` — these are evaluated lazily when SwiftUI renders the menu on long-press
- [ ] drop `canManageChannelPins` and `isPinnedToChannel` from `MyFavoritesRowView` and `MyFavoritesRowInternalView` parameters; keep `channelWidgetsObject`, `personalWidgetsObject`, `spaceId`
- [ ] update the `.contextMenu { MyFavoritesRowContextMenu(...) }` invocation to the new parameter shape
- [ ] in `MyFavoritesListView.swift`, stop passing `canManageChannelPins` and `pinnedToChannelObjectIds.contains(...)`; pass `spaceId: model.spaceId` instead

#### Task A4: Trim the parent `MyFavoritesViewModel`

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesRowData.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/HomeWidgetsViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/HomeWidgetsView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesListView.swift` (if it currently reads `myFavoritesViewModel.channelWidgetsObject`)

- [ ] in `MyFavoritesRowData.swift`: drop `chatPreview: MessagePreviewModel?`
- [ ] in `MyFavoritesViewModel.swift`:
  - delete `startChatPreviewsSubscription`, `startSpaceViewSubscription`, `startChannelPinsSubscription`, and their stored state (`chatPreviews`, `spaceView`, `pinnedToChannelObjectIds`)
  - delete computed `canManageChannelPins`
  - delete injections: `chatMessagesPreviewsStorage`, `spaceViewsStorage`, `participantSpacesStorage`, `widgetChatPreviewBuilder`
  - simplify `startSubscriptions()` to run only `startPersonalWidgetsSubscription()`
  - shrink `recomputeRows()` to build `MyFavoritesRowData(id: block.blockId, objectId: details.id, title: details.pluralTitle, icon: details.objectIconImage, onTap: { onObjectSelected(details) })` only
  - drop `channelWidgetsObject` parameter from `init` — no longer read by the VM after Task A3
- [ ] in `HomeWidgetsViewModel.init`, update the `MyFavoritesViewModel(...)` invocation to match the new init
- [ ] in `HomeWidgetsView.swift` (and `MyFavoritesListView.swift` if applicable), the places that previously read `myFavoritesViewModel.channelWidgetsObject` switch to reading `model.channelWidgetsObject` from the parent `HomeWidgetsViewModel` (same reference — both used to point to the same document) and pass it down explicitly where needed

#### Phase A hand-off (end of PR 1)

- [ ] full Xcode build passes
- [ ] manual QA (on iOS 26.3+ device, real hardware):
  - IOS-6106 reproducer: 5×, no crash
  - IOS-6104 regression: long-press + context-menu dismiss, row visible
  - IOS-6105 regression: Favorite/Unfavorite/Pin/Unpin → Vault → no SIGABRT
  - chat badges update live on MyFavorites rows
  - Pin/Unpin menu item shows correct label, hidden for Member/Viewer
  - reorder-within-zone persists
  - block-widgets drag-reorder still works (same delegate)
- [ ] open PR 1 titled e.g. `IOS-6106 MyFavorites per-row ViewModel refactor`; commit trailer `IOS-6106`; "Release" label per workflow
- [ ] merge PR 1 before starting Phase B (or continue on a new branch cut off develop post-merge — either way, Phase B should not stack on unmerged Phase A)

---

### Phase B — DnD commit-on-drag-end hygiene (PR 2)

**Goal**: move the server RPC off `dropExited` to actual drag-end for both MyFavorites and block widgets. Matches user-requested UX ("drop outside = commit last visual state") and eliminates a residual mid-drag server round-trip.

**Branch**: after Phase A merges, cut a new branch (e.g. `ios-6106-dnd-commit-on-drag-end`) off develop. Do NOT stack on unmerged Phase A.

**Working agreement**: every intermediate task inside Phase B must leave the project compiling. No simulator build required between tasks.

#### Task B1: Introduce `DragAndDropPendingCommit` + commit-on-drag-end plumbing

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Common/SwiftUI/DragAndDrop/DragAndDropModels.swift`
- Modify: `Anytype/Sources/PresentationLayer/Common/SwiftUI/DragAndDrop/View+DragAndDrop.swift`
- Modify: `Anytype/Sources/PresentationLayer/Common/SwiftUI/DragAndDrop/DragAndDropVerticalDelegate.swift`

- [ ] in `DragAndDropModels.swift`:
  - add `final class DragAndDropPendingCommit { var commit: (() -> Void)? }`
  - add `@Entry var anytypeDragAndDropPendingCommit: DragAndDropPendingCommit = DragAndDropPendingCommit()` on `EnvironmentValues` (mirror `DragAndDropFrames` / `anytypeDragAndDropFrames`)
  - **do not touch** `DragItemProvider.deinit` — the `DispatchQueue.main.async` defer from IOS-6105 stays
- [ ] in `View+DragAndDrop.swift`:
  - in `AnytypeVerticalDropViewModifier`: `@State private var pendingCommit = DragAndDropPendingCommit()`; add `.environment(\.anytypeDragAndDropPendingCommit, pendingCommit)` alongside the existing frames env; pass `pendingCommit` into `DragAndDropVerticalDelegate`
  - in `AnytypeVerticalDragViewModifier`: `@Environment(\.anytypeDragAndDropPendingCommit) private var pendingCommit`; inside `.onDrag`, capture by value and wire `provider.didEnd`:
    ```swift
    let pendingCommit = self.pendingCommit
    provider.didEnd = {
        state.resetState()
        let commit = pendingCommit.commit
        pendingCommit.commit = nil
        commit?()
    }
    ```
- [ ] in `DragAndDropVerticalDelegate.swift`:
  - add `let pendingCommit: DragAndDropPendingCommit` property (sibling of `framesStorage`)
  - in `dropUpdated`, immediately after computing `(fromElement, toElement)`: `pendingCommit.commit = { [dropFinish] in dropFinish(fromElement, toElement) }` (struct values captured by copy; no bindings, no view types)
  - in `dropExited`: **remove** the `dropFinish(fromElement, toElement)` call; keep `dropState.resetState()`. Do NOT touch `pendingCommit.commit`.
  - in `performDrop` success path: call `dropFinish(from, to)` as today inside `withAnimation`, then `pendingCommit.commit = nil` before returning. On the guard-else (no elements) path: also set `pendingCommit.commit = nil` defensively.

#### Phase B hand-off (end of PR 2)

- [ ] full Xcode build passes
- [ ] manual DnD verification on real hardware:
  - MyFavorites: drop inside zone → persists (happy path)
  - MyFavorites: drop outside zone (drag near Bin and release) → persists last in-zone position if one was captured during the drag; nothing persists if the drag never entered the zone; no crash
  - MyFavorites: start drag but release immediately without entering the zone → no commit, no crash
  - Pinned block widgets: drop inside the section → persists
  - Pinned block widgets: drag outside the section and release → **still persists** (this is the key regression check — `dropExited` no longer commits, so the path must be carried by the drag-end hook)
  - IOS-6104/6105 regression checks (same as Phase A) still pass
- [ ] open PR 2 titled e.g. `IOS-6106 DnD commit on drag-end`; commit trailer `IOS-6106`; "Release" label per workflow

---

### Final housekeeping (after both PRs merge)

- [ ] move this plan file to `docs/plans/completed/` (create dir if needed: `mkdir -p docs/plans/completed`)

## Post-Completion

*Manual / external verification — informational, no checkboxes.*

**Device verification**:
- The IOS-6106 crash is iOS-26-specific (AttributeGraph eviction behavior); the reproducer MUST be run on an iOS 26.3+ device. Simulator verification is a nice-to-have but not authoritative.
- One pass on an iOS 18.x device to confirm no behavior change on the legacy SwiftUI graph.

**Coordination**:
- No middleware changes; no backend coordination required.

**Fallback (if crash still reproduces after both phases land)**:
- Switch `AnytypeVerticalDragViewModifier` to `.onDrag(_:preview:)` with an explicit preview view snapshot. Bypasses the `previewForCancelling` AttributeGraph path entirely. Open as a separate follow-up issue only if needed.
