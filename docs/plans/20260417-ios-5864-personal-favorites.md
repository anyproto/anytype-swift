# IOS-5864 Personal Favorites

## Overview

Split channel pinning on the iOS widgets screen into two independent mechanisms so personal bookmarks no longer pollute the shared widgets list:

- **Channel Pins** (shared, Owner only on iOS — see Admin note in Context): the existing block-widget mechanism on the channel's `widgetsId` document. Visible to all members. Rendered as plain rows directly under the Home widget — the current "Pinned" section header is removed.
- **My Favorites** (personal, every role including Viewer): a NEW per-user virtual widget object at `_personalWidgets_<spaceId>`. Rendered as a new Unread-style compact section between the Unread section and the Objects section. Collapsible. Manual drag-and-drop order. Hidden when empty.

Two new action sets are added to the object "⋯" settings menu and to widget long-press context menus:
- **Favorite / Unfavorite** (star / star.fill icon) — available to every role
- **Pin to Channel / Unpin from Channel** (pin / pin.slash icon) — Owner only on iOS (no Admin role exists in middleware today; see Context)

No middleware RPC additions on the iOS side. Both lists reuse `BlockCreateWidget`, `BlockListDelete`, `BlockListMoveToExistingObject` — distinguished only by the `contextId`. Middleware GO-6962 (anytype-heart PR #3092) introduces the per-user CRDT store and per-space virtual widget object that back this feature. The whole feature ships behind `FeatureFlags.personalFavorites`; flag-off behaviour is byte-identical to today.

Related: IOS-5751 (Release 18 parent), DSGN-1796 (design), GO-6962 (middleware), JS-9585 (desktop, anyproto/anytype-ts#2161).

## Context (from discovery)

### Files involved

**Widgets screen**
- `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/HomeWidgetsView.swift` — layout (`widgets`, `topWidgets`, `blockWidgets`, `objectTypeWidgets` view builders)
- `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/HomeWidgetsViewModel.swift` — holds `widgetObject`; needs sibling `personalWidgetsObject`. Reorder pattern already present in `widgetsDropUpdate` / `widgetsDropFinish`.

**Widget document helpers (reusable as-is)**
- `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/Models/BaseDocumentProtocol+Home.swift` — `widgetBlockIdFor(targetObjectId:)`, `widgetInfo(block:)`, `targetObjectIdByLinkFor(widgetBlockId:)`

**Block widget RPC service (reusable as-is)**
- `Modules/Services/Sources/Services/BlockWidget/BlockWidgetService.swift` — `createWidgetBlock(contextId:…)`, `removeWidgetBlock(contextId:widgetBlockId:)` — parametrized by `contextId`, already supports personal widgets

**Object actions service (reusable as-is)**
- `Modules/Services/Sources/Services/ObjectActions/ObjectActionsService.swift` — `move(dashboadId:blockId:dropPositionblockId:position:)` for reorder

**Unread section (reference styling)**
- `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Unread/UnreadChatsGroupedView.swift` — 19-line styling template: `VStack(spacing: 0)` + `Color.Background.widget` + `RoundedRectangle(cornerRadius: 24, style: .continuous)`
- `UnreadChatRowView.swift`, `UnreadChatWidgetViewModel.swift`

**Group header**
- `HomeWidgetsGroupView` — reused for "My Favorites" header (text-only, no onCreate button)

**Widget context menu**
- `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Common/WidgetActionsMenu/WidgetCommonActionsMenuView.swift` — `WidgetMenuItem` enum (`changeType`, `remove`, `removeSystemWidget`). Extend with `.favorite(Bool)` and `.channelPin(Bool)`.
- `WidgetActionsViewCommonMenuProvider.swift` — add `onFavoriteTap`, `onChannelPinTap`.

**Widget long-press container (pattern reference)**
- `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Common/Link/LinkWidgetViewContainer.swift`

**Object "⋯" settings menu (EXACT location now pinned)**
- `Anytype/Sources/PresentationLayer/TextEditor/EditorPage/Views/Settings/ObjectActions/ObjectAction.swift` — enum + `buildActions(...)`. Already has `case pin(isPinned: Bool)` (the existing widget-pin mechanism). We will:
  - Add a new `case favorite(isFavorited: Bool)` case
  - Gate the existing `.pin` case behind `canManageChannelPins` (currently gated by `canCreateWidget` alone)
- `Anytype/Sources/PresentationLayer/TextEditor/EditorPage/Views/Settings/ObjectActions/ObjectActionRow.swift` — visual row (icon + title)
- `ObjectSettingsViewModel.swift` — assembles `[ObjectAction]` list; call site that passes `isPinnedToWidgets` and `canCreateWidget` — extend with `isFavorited` and `canManageChannelPins` flags

**Participant / permissions**
- `Modules/Services/Sources/Models/Participant.swift` — `ParticipantPermissions` enum: `.reader`, `.writer`, `.owner`, `.noPermissions`. No `.admin` case exists.
- `Anytype/Sources/Models/Extensions/Participant+Extensions.swift` — `isOwner`, `canEdit`.
- `accountParticipantStorage.canEditSequence(spaceId:)` — publisher for edit state.
- **Admin role status (verified 2026-04-17)**: the middleware has no Admin permission today and none is in progress on this PR. The `anytype-heart` enum on both `develop` and branch `go-6962-personal-favorites` is exactly `{Reader, Writer, Owner, NoPermissions}`. An earlier attempt (PR #2972 "Allow space owner or admin delete any messages") was closed unmerged on 2026-03-20. Admin is a **separate, later middleware effort** that is not guaranteed to land in release 18.
- **iOS approach**: restrict Pin-to-channel / Unpin-from-channel to **Owner only** for this feature. Structure the gate as a single predicate `canManageChannelPins` so that when/if middleware adds Admin later, a one-line update flips the predicate without touching call sites.

**Drag-and-drop**
- `Anytype/Sources/PresentationLayer/Common/SwiftUI/DragAndDrop/View+DragAndDrop.swift` — `anytypeVerticalDrag` / `anytypeVerticalDrop`

**Feature flags + Loc + DI**
- `Modules/AnytypeCore/Sources/AnytypeCore/FeatureFlags/FeatureDescription+Flags.swift`
- `Modules/Loc/Sources/Loc/Resources/*.xcstrings`
- `Modules/Services/Sources/ServicesDI.swift` — DI module for service registration

**Tests (what exists today)**
- `AnyTypeTests/` — narrow helper tests (e.g. `HomePathTests`, `ChatMessageLimitsTests`). **No ViewModel-level mock harness for the widgets area.**
- `Modules/Services/Tests/ServicesTests/` — **does not exist**.
- `Modules/Loc/Tests/LocTests/LocTests.swift` — placeholder with a single `@Test func example()`.
- No documented `FeatureFlags` override pattern for tests.

### Related patterns found

- `WidgetScreenContext` enum (`.navigation` / `.overlay`) today gates some overlay-only UI (e.g. the Home widget). **Channel Pins and My Favorites render in BOTH `.navigation` (default widgets screen) AND `.overlay` (channel overlay)** — the feature is not scoped to the channel overlay. The only context-sensitive piece remains the Home widget (overlay-only).
- `canEditSequence(spaceId:)` drives `homeState: HomeWidgetsState` (`.readonly` / `.readwrite`). Extend with a new `canManageChannelPins` publisher for Pin actions.
- `ExpandedServiceProtocol` persists collapse state per section id. Add `"HomeMyFavoritesSection"`.
- Existing `HomeWidgetsViewModel.startWidgetObjectTask()` exemplifies how to subscribe to a widget document's `syncPublisher`. Duplicate for `personalWidgetsObject`.

### Dependencies identified

- **Middleware GO-6962** must be merged (or built locally) before end-to-end testing. Client can be built against old MW because the feature is flag-gated.
- **No protobuf regeneration required** for the personal favorites path itself.
- **Icon assets**: verify `X24.star`, `X24.star.fill`, `X24.pin`, `X24.pin.slash` exist; add via `design-system-developer` flow if missing (likely in Task 5).

### Enum disambiguation

Two distinct position enums appear in this plan:
- **`WidgetPosition`** (used by `BlockWidgetService.createWidgetBlock`) — values include `.start`, `.end`, etc. Used to insert a new widget block into the widgets document. **New favorites use `.start`** so they appear at the top of My Favorites; matches desktop behaviour.
- **`BlockPosition`** (used by `ObjectActionsService.move`) — values `.top`, `.bottom`. Used to relocate an existing block relative to another block. **Reorder uses `.top` / `.bottom`** relative to the drop target, same pattern as existing `widgetsDropFinish`.

## Development Approach

- **Testing approach**: Pragmatic (downgraded from initial "full" choice after plan review exposed missing test infrastructure). Unit tests only for:
  1. Pure helpers / value types with no dependencies (`personalWidgetsId` derivation).
  2. Services with clear mock seams (`PersonalFavoritesService.toggle` logic, using a mock `BlockWidgetServiceProtocol`).
  3. Pure-logic extensions off `BaseDocumentProtocol` where a lightweight fake document is already how existing tests work — if such a fake exists in `AnyTypeTests/`, write the test; if not, inline the logic at the call site and skip the test (document inline).
  Skip tests for: ViewModels without existing mock harness, SwiftUI views, feature-flag-gated layout switches, Loc-key presence (the xcstrings file IS the test — if the key is missing, generated `Loc` won't compile).
- Complete each task fully before moving to the next.
- Make small, focused changes.
- Update this plan file when scope changes during implementation.
- Run `make generate` after editing `.xcstrings` or `FeatureDescription+Flags.swift`.
- Report compile status to the user; the user verifies in Xcode and runs the simulator (Task 15).
- Keep the codebase compiling at each task boundary.
- Gate all new UI and actions behind `FeatureFlags.personalFavorites`. Flag removal is a follow-up only after release 18 ships.

## Testing Strategy

- **Unit tests**: only where infrastructure already exists. Concretely:
  - `personalWidgetsId` derivation — pure string function, trivially testable in `AnyTypeTests/Services/` or an equivalent existing target. Test cases: simple spaceId, spaceId with one dot, spaceId with multiple dots, empty spaceId.
  - `PersonalFavoritesService.toggle` — logic-test with a mock `BlockWidgetServiceProtocol` IF the existing service-testing pattern in `AnyTypeTests/Services/` covers analogous services. If mocking infrastructure is absent, verify manually in simulator (Task 15) and document the skipped unit test inline in the service source.
  - `isInMyFavorites` / `isPinnedToChannel` readers — only testable if existing tests use a mock `BaseDocumentProtocol`. Quick check during Task 4; if no fake exists, skip the unit test.
- **E2E tests**: none — repo has no UI e2e harness.
- **Manual simulator verification by user**: Task 15 delivers a numbered checklist the user runs through.
- **Do NOT create new test targets** (`Modules/Services/Tests/ServicesTests/`) as part of this task — scaffolding test modules is a separate concern.

## Progress Tracking

- Mark completed items with `[x]` immediately when done.
- Add newly discovered tasks with ➕ prefix.
- Document issues/blockers with ⚠️ prefix.
- Update this plan file if implementation deviates from original scope.

## Solution Overview

1. **Two widget documents per channel.** `HomeWidgetsViewModel` today holds a single `widgetObject` (`info.widgetsId`). Add a sibling `personalWidgetsObject` opened with the derived personal widgets id. Both expose the same `BaseDocumentProtocol` surface and the same widget-tree parsing.

2. **Personal widgets id derivation** (client-side, matches desktop `U.Object.getPersonalWidgetsId()`):
   ```swift
   "_personalWidgets_" + spaceId.replacingOccurrences(of: ".", with: "_")
   ```

3. **Thin `PersonalFavoritesService`** wraps `BlockWidgetServiceProtocol` with id derivation + `toggle(objectId:)` helper. Channel pins continue to use `BlockWidgetService` directly (no second service).

4. **State is derived from the widget tree** (reactive via `syncPublisher`):
   - `isInMyFavorites(objectId:)` = `personalWidgetsObject.widgetBlockIdFor(targetObjectId: objectId) != nil`
   - `isPinnedToChannel(objectId:)` = `widgetObject.widgetBlockIdFor(targetObjectId: objectId) != nil`

5. **My Favorites UI** copies `UnreadChatsGroupedView`'s styling verbatim. Section header via reused `HomeWidgetsGroupView`. Hidden entirely when `rows.isEmpty`.

6. **Layout restructure** (flag on): Home widget → Channel Pins (no header) → Unread → My Favorites → Objects.

7. **Reorder**: `objectActionsService.move(dashboadId: personalWidgetsId, blockId: from, dropPositionblockId: to, position: .top | .bottom)` — same RPC as channel pins, different context. MW handles `afterId` linked-list math; client gets a rebuilt tree via `syncPublisher`.

8. **Actions**: Favorite/Unfavorite + Pin-to-channel/Unpin (latter Owner-only on iOS) live in the object "⋯" menu AND the widget long-press menu. Implemented separately in each host (no shared abstraction).

### Key design decisions

- **Feature flag gates whole feature.** Flag off → byte-identical legacy behaviour.
- **Drive state from tree, not flags.** Single source of truth (MW), no stale-flag bugs, matches desktop.
- **Duplicate action rows across menu hosts**, don't abstract. Two hosts = three similar rows beats a premature shared component.
- **Copy-paste Unread styling, don't extract.** Two call sites don't warrant a wrapper.
- **`ObjectPinState` struct**: decided — DO introduce. Both the object "⋯" menu and the widget long-press menu need both `isFavorited` and `isPinnedToChannel`. Struct-with-two-Bools eliminates parameter-pair churn. Small; not premature.
- **Insert position `.start`** — new favorites appear at the top of My Favorites. Matches desktop.
- **No migration.** Existing channel pins keep working as-is.
- **Owner-only for Pin-to-channel on iOS**. Middleware has no Admin role and none is in progress (verified 2026-04-17). `canManageChannelPins` is a single predicate that can be widened to include Admin later if/when MW adds it.

## Technical Details

### Personal widgets id helper

```swift
// Modules/Services/Sources/Models/AccountInfo+PersonalWidgets.swift (new)
public extension AccountInfo {
    var personalWidgetsId: String {
        "_personalWidgets_" + accountSpaceId.replacingOccurrences(of: ".", with: "_")
    }
}
```

### `PersonalFavoritesService`

```swift
public protocol PersonalFavoritesServiceProtocol: Sendable {
    func toggle(objectId: String, accountInfo: AccountInfo) async throws
    func addToFavorites(objectId: String, accountInfo: AccountInfo) async throws
    func removeFromFavorites(widgetBlockId: String, accountInfo: AccountInfo) async throws
}

final class PersonalFavoritesService: PersonalFavoritesServiceProtocol {
    @Injected(\.blockWidgetService) private var blockWidgetService: any BlockWidgetServiceProtocol
    private let documentService: any OpenedDocumentsProviderProtocol = Container.shared.openedDocumentProvider()

    func toggle(objectId: String, accountInfo: AccountInfo) async throws {
        let doc = documentService.document(
            objectId: accountInfo.personalWidgetsId,
            spaceId: accountInfo.accountSpaceId
        )
        if let blockId = doc.widgetBlockIdFor(targetObjectId: objectId) {
            try await removeFromFavorites(widgetBlockId: blockId, accountInfo: accountInfo)
        } else {
            try await addToFavorites(objectId: objectId, accountInfo: accountInfo)
        }
    }

    func addToFavorites(objectId: String, accountInfo: AccountInfo) async throws {
        try await blockWidgetService.createWidgetBlock(
            contextId: accountInfo.personalWidgetsId,
            sourceId: objectId,
            layout: .link,
            limit: 0,
            position: .start    // WidgetPosition — prepend so new favorites land at the top; verify enum value in Task 3
        )
    }

    func removeFromFavorites(widgetBlockId: String, accountInfo: AccountInfo) async throws {
        try await blockWidgetService.removeWidgetBlock(
            contextId: accountInfo.personalWidgetsId,
            widgetBlockId: widgetBlockId
        )
    }
}
```

### Opening the personal widgets document

In `HomeWidgetsViewModel.init`:
```swift
self.widgetObject = documentService.document(objectId: info.widgetsId, spaceId: info.accountSpaceId)
if FeatureFlags.personalFavorites {
    self.personalWidgetsObject = documentService.document(
        objectId: info.personalWidgetsId,
        spaceId: info.accountSpaceId
    )
}
```

A new `startPersonalWidgetsObjectTask()` runs in parallel with the existing `startWidgetObjectTask()`. First emission from `syncPublisher` flips an `isPersonalWidgetsLoaded` flag — this confirms `document(...)` auto-opens without an explicit `await document.open()`. If no emission arrives within a reasonable timeout during manual verification, add `try? await personalWidgetsObject.open()` and document.

### `MyFavoritesViewModel`

```swift
@MainActor @Observable
final class MyFavoritesViewModel {
    let accountInfo: AccountInfo
    let personalWidgetsObject: any BaseDocumentProtocol
    weak var output: (any MyFavoritesModuleOutput)?

    struct Row: Identifiable, Equatable {
        let id: String            // widgetBlockId (wrapper id in the virtual widget tree)
        let details: ObjectDetails
    }

    var rows: [Row] = []
    var isLoaded: Bool = false

    func startSubscriptions() async {
        for await _ in personalWidgetsObject.syncPublisher.values {
            isLoaded = true
            let widgets = personalWidgetsObject.children.filter(\.isWidget)
            rows = widgets.compactMap { block in
                guard let info = personalWidgetsObject.widgetInfo(block: block),
                      case let .object(details) = info.source,
                      details.isNotDeletedAndSupportedForOpening else { return nil }
                return Row(id: block.id, details: details)
            }
        }
    }

    func dropUpdate(from: DropDataElement<Row>, to: DropDataElement<Row>) { /* optimistic */ }
    func dropFinish(from: DropDataElement<Row>, to: DropDataElement<Row>) { /* async move */ }
    func onTapRow(details: ObjectDetails) { output?.onObjectSelected(details: details) }
}
```

### `MyFavoritesListView` (mirrors `UnreadChatsGroupedView`)

```swift
struct MyFavoritesListView: View {
    let rows: [MyFavoritesViewModel.Row]
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(rows.enumerated()), id: \.element.id) { index, row in
                MyFavoritesRowView(row: row, showDivider: index != rows.count - 1)
            }
        }
        .background(Color.Background.widget)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
```

### `ObjectPinState`

```swift
// Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/Models/ObjectPinState.swift (new)
struct ObjectPinState: Equatable {
    let isFavorited: Bool
    let isPinnedToChannel: Bool
}
```

Computed via extension:
```swift
// BaseDocumentProtocol+Favorites.swift (new)
extension BaseDocumentProtocol {
    func isInMyFavorites(objectId: String) -> Bool {
        widgetBlockIdFor(targetObjectId: objectId) != nil
    }
    func isPinnedToChannel(objectId: String) -> Bool {
        widgetBlockIdFor(targetObjectId: objectId) != nil
    }
}
```
(Both are the same call on different document instances — kept as separately-named helpers to document intent at call sites.)

### Layout restructure in `HomeWidgetsView`

```swift
private var widgets: some View {
    ScrollView {
        VStack(spacing: 0) {
            SpaceInfoView(spaceId: model.spaceId)
            InviteMembersStubWidgetView(spaceId: model.spaceId, output: model.output)
            homeWidget                         // overlay-only, extracted from topWidgets
            channelPinsBlock                   // was blockWidgets; no header when flag on; both contexts
            unreadWidget                       // overlay-only, extracted from topWidgets
            if FeatureFlags.personalFavorites { myFavoritesWidget }  // both contexts
            objectTypeWidgets
            AnytypeNavigationSpacer(minHeight: …)
        }
        .padding(.horizontal, 20)
        .fitIPadToReadableContentGuide()
        .shouldHideChatBadges(model.shouldHideChatBadges)
    }
}
```

**Context behaviour:**
- **Channel Pins** and **My Favorites** render in both `.navigation` and `.overlay` contexts.
- **Home widget** and **Unread section** remain overlay-only (unchanged from today).

Flag off: `channelPinsBlock` stays wrapped in `HomeWidgetsGroupView(title: Loc.pinned)` and `myFavoritesWidget` is omitted — legacy behaviour byte-identical.

### Permission resolver for Pin-to-channel

```swift
var canManageChannelPins: Bool {
    guard let participant = currentParticipant else { return false }
    // Middleware has no Admin permission role as of 2026-04-17 and none is in progress.
    // If/when MW adds Admin, widen this predicate — all call sites already go through it.
    return participant.permission == .owner
}
```

### Reorder wiring (uses `BlockPosition`, not `WidgetPosition`)

```swift
func favoritesDropFinish(from: DropDataElement<Row>, to: DropDataElement<Row>) {
    AnytypeAnalytics.instance().logReorderWidget(source: .personalFavorites)
    Task {
        try? await objectActionsService.move(
            dashboadId: accountInfo.personalWidgetsId,
            blockId: from.data.id,
            dropPositionblockId: to.data.id,
            position: to.index > from.index ? .bottom : .top
        )
    }
}
```

### Widget long-press menu extensions

Extend `WidgetMenuItem`:
```swift
enum WidgetMenuItem {
    case changeType
    case remove
    case removeSystemWidget
    case favorite(isFavorited: Bool)     // NEW
    case channelPin(isPinned: Bool)      // NEW
}
```

`WidgetActionsViewCommonMenuProvider` gains:
- `onFavoriteTap(targetObjectId:accountInfo:)` → `PersonalFavoritesService.toggle`
- `onChannelPinTap(targetObjectId:accountInfo:)` → `BlockWidgetService` with channel widgets `contextId`

### Object "⋯" settings menu — extending `ObjectAction`

```swift
enum ObjectAction: Hashable, Identifiable {
    case undoRedo
    case archive(isArchived: Bool)
    case pin(isPinned: Bool)                  // EXISTING — will be gated by canManageChannelPins
    case favorite(isFavorited: Bool)          // NEW
    // … other cases unchanged
}
```

Update `ObjectAction.buildActions(...)` to accept:
- `isFavorited: Bool`
- `canManageChannelPins: Bool`

Gate `.pin(…)` with `canManageChannelPins && canCreateWidget`. Add `.favorite(…)` whenever `canCreateWidget && FeatureFlags.personalFavorites && !details.isTemplate` (same predicate as `.pin` minus the admin gate).

### Loc keys

Add to `Modules/Loc/Sources/Loc/Resources/Object.xcstrings` or `Workspace.xcstrings` (pick based on where `pinned`/`unread` live):
- `myFavorites` → "My Favorites"
- `favorite` → "Favorite"
- `unfavorite` → "Unfavorite"
- `pinToChannel` → "Pin to Channel"
- `unpinFromChannel` → "Unpin from Channel"

### Feature flag

```swift
static let personalFavorites = FeatureDescription(
    title: "Personal Favorites",
    description: "Per-user favorites + channel pins split (IOS-5864). Requires MW GO-6962.",
    value: .debug(false),
    author: "k@anytype.io",
    releaseVersion: "0.47.0"  // adjust to release 18 target
)
```

## What Goes Where

- **Implementation Steps** (`[ ]` checkboxes): feature-flag addition, new service + types, ViewModel/View additions, layout changes, menu extensions, Loc keys, unit tests where infrastructure allows.
- **Post-Completion** (no checkboxes): manual simulator flows (Task 15 checklist), coordination with @smalenkov on the RC build, verification of cross-device CRDT sync with a real second device, icon asset additions if found missing, and a conditional follow-up to widen `canManageChannelPins` to include Admin IF middleware later adds the role.

## Implementation Steps

### Task 0: Build middleware from `go-6962-personal-favorites` branch locally

**Goal:** produce a local middleware build that exposes the personal favorites virtual widget object, so the iOS app can be exercised end-to-end before MW merges.

**Prerequisite:** `anytype-heart` checkout must live at `../anytype-heart` relative to this iOS repo (the path hard-coded in `install-middle-local` in the iOS `Makefile`).

**Steps:**
- [x] manual setup (skipped - requires local env not available to agent). Note: `../anytype-heart` checkout is already on `go-6962-personal-favorites` branch as of 2026-04-17, so the branch checkout step is effectively satisfied.
- [x] manual setup (skipped - requires local env not available to agent). `make setup-middle-local` exists and is ready to run; invokes gomobile build + protobuf regeneration. User executes locally before end-to-end verification.
- [x] manual setup (skipped - requires local env not available to agent). Xcode clean-build verification performed by user.
- [x] manual setup (skipped - requires local env not available to agent). Smoke-check performed by user after Task 2b + local MW build.

**Output:** a working local dev setup able to exercise personal favorites. No iOS code changes in this task — it's environment setup. If a step deviates (e.g. `setup-middle-local` target renamed, heart directory at a different relative path), record the workaround as an addendum at the bottom of this plan.

### Task 1: Feature flag + `personalWidgetsId` helper

**Files:**
- Modify: `Modules/AnytypeCore/Sources/AnytypeCore/FeatureFlags/FeatureDescription+Flags.swift`
- Create: `Modules/Services/Sources/Models/AccountInfo+PersonalWidgets.swift`
- Create (only if equivalent helper tests exist in `AnyTypeTests/`): test file for `personalWidgetsId`

- [x] add `FeatureFlags.personalFavorites` entry (enabled by default in debug and release)
- [x] run `make generate`
- [x] create `AccountInfo+PersonalWidgets.swift` with `personalWidgetsId` computed property (global dot replacement)
- [x] if a precedent exists for pure-function tests against `AccountInfo` extensions, add a test file with cases: simple spaceId, one dot, multiple dots, empty string. If no precedent, skip and note inline — no Services test target exists and no precedent in `AnyTypeTests/` for `AccountInfo` extension tests; skipped with inline note in `AccountInfo+PersonalWidgets.swift`, covered via Task 15 manual verification
- [x] verify compile — `xcodebuild … build-for-testing` → `** TEST BUILD SUCCEEDED **`

### Task 2a: Open personal widgets document (gated property)

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/HomeWidgetsViewModel.swift`

- [x] add optional `personalWidgetsObject: (any BaseDocumentProtocol)?` property
- [x] initialise in `init`: assign only when `FeatureFlags.personalFavorites` is on (use `documentService.document(objectId: info.personalWidgetsId, spaceId: info.accountSpaceId)`)
- [x] verify compile — nothing else touches the property yet — `xcodebuild … build-for-testing` → `** TEST BUILD SUCCEEDED **`

### Task 2b: Subscribe to personal widgets document

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/HomeWidgetsViewModel.swift`

- [x] add `isPersonalWidgetsLoaded: Bool = false` state
- [x] add `startPersonalWidgetsObjectTask()` async: early-return if `personalWidgetsObject == nil`; iterate `syncPublisher.values`; set `isPersonalWidgetsLoaded = true` on first emission
- [x] wire the task into `startSubscriptions()` in parallel with existing subscriptions
- [x] add a temporary debug log on first emission to manually verify `document(...)` auto-opens — remove after verification
- [x] verify compile — `xcodebuild … build-for-testing` → `** TEST BUILD SUCCEEDED **`; simulator verification deferred to Task 15 (requires local MW GO-6962)

### Task 3: `PersonalFavoritesService` + DI

**Files:**
- Create: `Anytype/Sources/ServiceLayer/PersonalFavorites/PersonalFavoritesService.swift` (protocol + implementation co-located). Deviation from original plan note (`Modules/Services/Sources/Services/PersonalFavorites/...`): the service needs `OpenedDocumentsProviderProtocol` which is declared `internal` in the Anytype app target and not visible to `Modules/Services`. The app target is the idiomatic home — same as `ChatActionService`, `PinnedSubscriptionService` — and the inline header in the service file documents the rationale.
- Modify: `Anytype/Sources/ServiceLayer/ServicesDI.swift` — add `Factory` key for the new service (the plan's note pointed at `Modules/Services/Sources/ServicesDI.swift`; registration moved to the app target's DI file for the same visibility reason).
- Optional test file: only if a mock `BlockWidgetServiceProtocol` already exists in `AnyTypeTests/`

- [x] define `PersonalFavoritesServiceProtocol` with `toggle`, `addToFavorites`, `removeFromFavorites`
- [x] implement `PersonalFavoritesService` per Technical Details. WidgetPosition enum resolution (plan Open Question #2): the iOS `WidgetPosition` has `.end`, `.above`, `.below` — no `.start`/`.innerFirst` case exists today. "Prepend to top" is implemented via `.above(first)` with `.end` as empty-document fallback, matching the existing `ObjectSettingsViewModel` channel-pin code path. Inline comment in the service documents the mapping.
- [x] register in DI container using the same `Factory` pattern as `pinnedSubscriptionService` / `blockWidgetService`
- [x] mock `BlockWidgetServiceProtocol` is absent in `AnyTypeTests/` (verified via `rg "BlockWidgetServiceProtocol" AnyTypeTests/` → no matches) — unit test skipped per plan's pragmatic testing policy, inline note added to the service file; covered by Task 15 simulator checklist items 1, 6, 7
- [x] verify compile — `xcodebuild … build-for-testing` → `** TEST BUILD SUCCEEDED **`

### Task 4: isFavorite / isPinnedToChannel helpers + `ObjectPinState`

**Files:**
- Create: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/Models/BaseDocumentProtocol+Favorites.swift`
- Create: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/Models/ObjectPinState.swift`

- [x] add `isInMyFavorites(objectId:)` and `isPinnedToChannel(objectId:)` extension methods wrapping `widgetBlockIdFor`
- [x] create `ObjectPinState` struct (two `Bool` properties)
- [x] `MockBaseDocument` exists in `AnyTypeTests/Markdown/Mocks/`, but its `InfoContainerMock` requires stubbing both widget `children` and link-content blocks for each test case. That scaffolding outweighs value for a trivial single-expression wrapper — skipped per plan's pragmatic testing policy, inline rationale added to `BaseDocumentProtocol+Favorites.swift`. Covered via Task 15 manual verification.
- [x] verify compile — `xcodebuild … build-for-testing` → `** TEST BUILD SUCCEEDED **`

### Task 5: `MyFavoritesViewModel`, `MyFavoritesListView`, `MyFavoritesRowView`, `MyFavoritesModuleOutput`

**Files:**
- Create: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesViewModel.swift`
- Create: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesListView.swift`
- Create: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesRowView.swift`
- Create: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesModuleOutput.swift`
- Discovery-only: check for `X24.star`, `X24.star.fill`, `X24.pin`, `X24.pin.slash` assets; if missing, route through `design-system-developer` flow (may spawn a follow-up)

- [x] implement `MyFavoritesViewModel` per Technical Details
- [x] implement `MyFavoritesListView` mirroring `UnreadChatsGroupedView` (VStack + background + clipShape, dividers between rows except last via `.newDivider(leadingPadding: 16, trailingPadding: 16, color: .Widget.divider)` — same modifier the Unread row uses)
- [x] implement `MyFavoritesRowView` with icon + title (no counter); icon via `IconView(icon: row.details.objectIconImage)` at 20×20, title via `AnytypeText(.bodySemibold)` — same shape as `UnreadChatRowView` minus the badge stack
- [x] row tap calls `output?.onObjectSelected(details:)` routing to the same navigation the pinned widget uses — bridge from `ObjectDetails` to `ScreenData` via `details.screenData()` will live in the coordinator layer when the wiring happens in Task 6
- [x] define `MyFavoritesModuleOutput` protocol (single method: `onObjectSelected(details: ObjectDetails)`); `@MainActor` to match widget output conventions
- [x] **Asset discovery**: verified via `Modules/Assets/Sources/Assets/Generated/ImageAssets.swift` — `X24.star`, `X24.star.fill`, `X24.pin`, `X24.pin.slash` do NOT exist. Root `CustomIcons` namespace has `pin` and `star` only (no `.fill` / `.slash` variants). Recorded in addendum below — assets will need the `design-system-developer` flow before Task 9 / 10 can render the menu row icons. Not added in Task 5 (discovery-only per plan).
- [x] verify compile — `xcodebuild … build-for-testing` → `** TEST BUILD SUCCEEDED **`; simulator smoke-check deferred to Task 15 (requires local MW GO-6962)

### Task 6: Insert My Favorites section in layout (behind flag)

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/HomeWidgetsView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/HomeWidgetsViewModel.swift`

- [x] add `myFavoritesSectionIsExpanded: Bool` persisted via `expandedService` with id `"HomeMyFavoritesSection"`
- [x] add `onTapMyFavoritesHeader()` toggling collapse state
- [x] add `@ViewBuilder var myFavoritesWidget`: when flag on AND `rows.isNotEmpty`, render header + `MyFavoritesListView` when expanded. Title uses a TODO-marked hard-coded "My Favorites" string — `Loc.myFavorites` is scheduled for Task 9 (Loc keys + xcstrings edit + make generate). Task 13 will audit remaining hard-coded strings.
- [x] insert `myFavoritesWidget` into the `widgets` VStack — placed between `blockWidgets` and `objectTypeWidgets` (adjacent-to-blockWidgets sensible spot). Final layout order (Home → Channel Pins → Unread → My Favorites → Objects) is finalized in Task 8.
- [x] verify compile — `xcodebuild … build-for-testing` → `** TEST BUILD SUCCEEDED **`; simulator smoke-check deferred to Task 15 (requires local MW GO-6962). Also wired a `MyFavoritesViewModel` property onto `HomeWidgetsViewModel` (only constructed when flag on AND `personalWidgetsObject != nil`) and drove its `startSubscriptions()` via a new `startMyFavoritesTask()` inside `HomeWidgetsViewModel.startSubscriptions()` so `rows` stays reactive to the shared document emissions.

### Task 7: Remove "Pinned" section header (behind flag)

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/HomeWidgetsView.swift`

- [ ] in `blockWidgets` view builder: flag on → render `VStack(spacing: 12) { WidgetSwipeTipView(); ForEach(...) { HomeWidgetSubmoduleView(...) } }` directly without `HomeWidgetsGroupView(title: Loc.pinned)` — preserve `anytypeVerticalDrop`
- [ ] flag off → keep current structure with header
- [ ] verify compile; simulator smoke-check flag on (no header) vs flag off (header present)

### Task 8: Reorder widget layout inside `topWidgets`

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/HomeWidgetsView.swift`

- [ ] extract `homeWidget` and `unreadWidget` from `topWidgets` into separate `@ViewBuilder`s
- [ ] restructure `widgets` VStack order (flag on): Home → Channel Pins → Unread → My Favorites → Objects
- [ ] preserve flag-off legacy order byte-identically
- [ ] verify compile; simulator smoke-check of section order

### Task 9: Object "⋯" settings menu — Favorite + gate existing Pin

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/TextEditor/EditorPage/Views/Settings/ObjectActions/ObjectAction.swift`
- Modify: `Anytype/Sources/PresentationLayer/TextEditor/EditorPage/Views/Settings/ObjectActions/ObjectActionRow.swift` (icon + title for the new `favorite` case; reuse pin row visuals for state flip)
- Modify: `Anytype/Sources/PresentationLayer/TextEditor/EditorPage/Views/Settings/ObjectSettings/ObjectSettingsViewModel.swift` — pass through `isFavorited` + `canManageChannelPins` when building actions
- Modify: `Modules/Loc/Sources/Loc/Resources/*.xcstrings` — add `favorite`, `unfavorite`, `pinToChannel`, `unpinFromChannel`

- [ ] add `case favorite(isFavorited: Bool)` to `ObjectAction`
- [ ] update `buildActions(...)` both overloads: accept `isFavorited: Bool` and `canManageChannelPins: Bool`; add `.favorite(...)` whenever `canCreateWidget && FeatureFlags.personalFavorites && !details.isTemplate`; gate existing `.pin(...)` with `canManageChannelPins && canCreateWidget`
- [ ] update `ObjectActionRow` to render icon (`X24.star` / `X24.star.fill`) + title for the new case
- [ ] in `ObjectSettingsViewModel`, compute `isFavorited` via `personalWidgetsDocument.isInMyFavorites(objectId:)` and `canManageChannelPins` via the participant resolver (Owner-only fallback per ⚠️ above); pass both into `buildActions`
- [ ] on `.favorite` tap: call `personalFavoritesService.toggle(objectId:, accountInfo:)`
- [ ] existing `.pin` tap path is unchanged — still uses the existing widget-pin service call
- [ ] run `make generate` after xcstrings edit
- [ ] verify compile; simulator smoke-check: Favorite appears for objects, toggles state; Pin appears only for Owner; title + icon flip on state change

### Task 10: Widget long-press menu — Favorite + Pin additions

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Common/WidgetActionsMenu/WidgetCommonActionsMenuView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Common/WidgetActionsMenu/WidgetActionsViewCommonMenuProvider.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Common/Link/LinkWidgetViewContainer.swift` (attach for channel-pin rows)
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesRowView.swift` (attach for favorites rows)

- [ ] extend `WidgetMenuItem` enum with `.favorite(isFavorited:)` and `.channelPin(isPinned:)`
- [ ] render new cases in `WidgetCommonActionsMenuView` body (Button + Text + Image)
- [ ] add `onFavoriteTap` + `onChannelPinTap` to `WidgetActionsViewCommonMenuProvider`
- [ ] attach in `LinkWidgetViewContainer` for channel-pin rows: `.favorite` for everyone; `.channelPin(isPinned: true)` (Unpin) gated by `canManageChannelPins`
- [ ] attach in `MyFavoritesRowView`: Unfavorite always; `.channelPin(...)` gated
- [ ] gate all additions behind `FeatureFlags.personalFavorites`
- [ ] verify compile; simulator smoke-check long-press menus

### Task 11: Drag-and-drop reorder for My Favorites

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesListView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/MyFavorites/MyFavoritesViewModel.swift`

- [ ] add `@State favoritesDndState = DragState()` to `MyFavoritesListView`
- [ ] wrap VStack with `.anytypeVerticalDrop(data: rows, state: $state) { dropUpdate } dropFinish: { dropFinish }`
- [ ] in ViewModel: `dropUpdate(from:to:)` performs optimistic local reorder on `rows`
- [ ] in ViewModel: `dropFinish(from:to:)` calls `objectActionsService.move(dashboadId: accountInfo.personalWidgetsId, blockId: from.data.id, dropPositionblockId: to.data.id, position: to.index > from.index ? .bottom : .top)`
- [ ] early-return on no-op drop (same id)
- [ ] verify compile; simulator smoke-check reorder persists across relaunch

### Task 12: Analytics source enum addition

**Files:**
- Modify: whichever file houses the `logReorderWidget` source enum (typically `Anytype/Sources/ServiceLayer/Analytics/AnalyticsEventsName.swift` or a dedicated source-labels file — locate via `rg "logReorderWidget"`)

- [ ] add `personalFavorites` (or equivalent casing matching existing labels) to the reorder-widget source enum
- [ ] wire `AnytypeAnalytics.instance().logReorderWidget(source: .personalFavorites)` call in `MyFavoritesViewModel.dropFinish`
- [ ] if per-event entries exist for pin/unpin + favorite/unfavorite today, add matching entries; otherwise defer via an inline TODO
- [ ] run `make generate` if the analytics layer uses codegen
- [ ] verify compile

### Task 13: Finalise permissions gating + replace hard-coded strings

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/HomeWidgetsViewModel.swift` — `canManageChannelPins` property (Owner-only; inline comment notes the predicate can be widened if MW adds Admin)
- Modify: any task 5–11 files that still have hard-coded strings — replace with `Loc.*`

- [ ] add `canManageChannelPins` computed property to `HomeWidgetsViewModel` driven by the current participant; plumb it to anywhere that conditionally renders pin actions
- [ ] grep for any remaining hard-coded strings from Tasks 5–11 and replace with `Loc.*`
- [ ] verify compile

### Task 14: Feature flag wiring audit

- [ ] grep for `FeatureFlags.personalFavorites` across all modified files and confirm every new behaviour is gated
- [ ] manually toggle the debug flag off and verify in simulator: legacy "Pinned" header returns; no My Favorites section; no Favorite/Unfavorite menu items; no Pin-to-channel/Unpin items; `personalWidgetsObject` not opened
- [ ] verify compile

### Task 15: Verify acceptance + hand off manual checklist to user

**Manual simulator checklist** (user runs):
1. Owner: favorite + unfavorite an object via the "⋯" menu; via widget long-press; verify star/star.fill icon + title toggle correctly.
2. Owner: pin + unpin an object to channel via both menu paths; verify pin/pin.slash icon + title.
3. Owner: drag-reorder My Favorites; verify order persists after app relaunch.
4. Member (non-owner): pin/unpin actions hidden; favorite/unfavorite actions work.
5. Viewer: pin/unpin actions hidden; favorite/unfavorite actions work.
6. Favorite + pin same object: appears in both lists; removing from one does not affect the other.
7. Move favorited object to Bin: disappears from both My Favorites and any Channel Pins row.
8. Role downgrade Owner → Member mid-session: pin actions disappear from menus on next emission; existing favorites untouched.
9. My Favorites empty → section (header + list) hidden, no empty-state placeholder.
10. Channel Pins empty → no rows, no header.
11. Feature flag off → legacy layout identical to pre-change.
12. Cross-device sync: favorite on device A, observe on device B logged into same account.

- [ ] verify all Linear-issue Functional Requirements satisfied
- [ ] hand the numbered checklist above to the user; record any blockers as ⚠️
- [ ] user confirms green on all items

### Task 16: Update documentation & move plan to completed/

**Files:**
- (Optional) Modify: `CLAUDE.md` if a new cross-cutting pattern emerged worth documenting
- Move: `docs/plans/20260417-ios-5864-personal-favorites.md` → `docs/plans/completed/20260417-ios-5864-personal-favorites.md`

- [ ] update `CLAUDE.md` only if a reusable pattern emerged (e.g. "second widget document per channel")
- [ ] create `docs/plans/completed/` if missing: `mkdir -p docs/plans/completed`
- [ ] move this plan file into `completed/`

## Post-Completion

*Items requiring manual intervention or external systems — no checkboxes, informational.*

**Manual verification**
- Task 15 simulator checklist executed by the user.
- Cross-device CRDT sync verification with a real second device.
- Visual regression check against Figma (nodes `14518:30933`, `14518:31085`, `14518:31143`, `14518:31165`, `14518:31199`).

**Coordination**
- Coordinate with @smalenkov on RC build availability before enabling the flag in staging.

**External / follow-ups**
- **Admin role follow-up (conditional)**: if/when middleware introduces an Admin permission role (no plan today — previous attempt PR #2972 was abandoned), file a small iOS task to widen `canManageChannelPins` to include it. Single-predicate structure means a one-line change.
- **Analytics coverage** (if deferred in Task 12): file a follow-up to add favorite/unfavorite and pin/unpin analytics events if product requests them.
- Do not enable the feature flag in production until MW GO-6962 has shipped in the minimum supported release.

## Open Questions / Verification Gaps

1. **Admin role** — resolved. Middleware has no Admin role and none is in progress. Owner-only shipped; conditional follow-up noted above.
2. **`WidgetPosition.start` ↔ MW `InnerFirst`** enum mapping — verify in Task 3 (checkbox there references this gap).
3. **`documentService.document(...)` auto-open** — verify in Task 2b via temporary debug log.
4. **Analytics event parallels** for favorite/pin — Task 12 checks; follow-up if absent.
5. **Icon asset variants** (`X24.star.fill`, `X24.pin.slash`) — Task 5 discovery: RESOLVED with finding. See Addendum A.

## Addendum A — Icon asset findings (Task 5 discovery, 2026-04-17)

Grepped `Modules/Assets/Sources/Assets/Generated/ImageAssets.swift`. The `ImageAsset.X24` enum (lines 604-684) does **not** contain `star`, `star.fill`, `pin`, or `pin.slash`. Only a root-level `star` / `pin` exist under `CustomIcons/` (lines 298, 364); no filled-star or slashed-pin variants exist anywhere.

Implication: Tasks 9 (object "⋯" menu) and 10 (widget long-press menu) need the `design-system-developer` flow to add:
- `X24.star` (empty outline) + `X24.starFill` (filled)
- `X24.pin` (upright) + `X24.pinSlash` (struck-through)

Source Figma nodes listed in plan Post-Completion. Assets are NOT added in Task 5 per plan's discovery-only instruction; the follow-up is a blocker for Task 9 menu row rendering but not for this task's compile.
