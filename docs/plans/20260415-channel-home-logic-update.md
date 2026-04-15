# IOS-6059 Channel Home Logic Update

## Overview

Refine the homepage flow that shipped in the IOS-5856 epic so every Channel has a consistent Home entry point:

- Homepage picker: 3 options (Chat, Page, Collection) instead of 4 — drop the Widgets option.
- Rename picker buttons: "Create" → "Continue", "Later" → "Not now". "Not now" now sets homepage to `"widgets"` instead of leaving it empty.
- Remove the "Create Home" stub widget and its dismissal state. A channel is never left without a homepage.
- Repurpose the existing `SpaceChatWidget` (currently hard-coded to the chat object when homepage is Chat) into a generic **Home widget** that renders whatever object is set as homepage (Chat, Page, or Collection). Add a home-icon glyph on the right edge. Long-press offers a "Change Home" action that opens the Space Settings home picker.
- Space Settings → Home: preview shows "No home" instead of "Empty" when homepage is widgets; picker gets a "No home" row + divider + subtitle above the object list.
- 1-on-1 spaces: client skips the post-creation picker. Setting the Chat homepage is middleware's responsibility (not a client `SetHomepage` call). If homepage isn't set by middleware for 1-on-1 spaces, file a middleware bug.
- Treat empty homepage as `"widgets"` everywhere (display fallback). No client-side stub state.

Related: middleware GO-7175 (reset homepage to widgets on object deletion) — separate task, out of scope here.

## Context (from discovery)

### Files involved
- **Post-creation picker**: `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepageCreatePickerView.swift`, `HomepageCreatePickerViewModel.swift`, `HomepagePickerOption.swift`, `HomepagePickerResult.swift`
- **Settings picker**: `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepageSettingsPickerView.swift`, `HomepageSettingsPickerViewModel.swift`
- **Existing chat-as-home widget (to generalise)**: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/SpaceChat/SpaceChatWidgetView.swift`, `SpaceChatWidgetViewModel.swift`, `SpaceChatWidgetData.swift`
- **Stub widget (to delete)**: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Stub/StubWidgetsView.swift`, `StubWidgetsViewModel.swift`
- **Onboarding storage**: `ChannelOnboardingStorage.swift` (strip homepage-related state; keep invite-members state)
- **Widgets list**: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/HomeWidgetsView.swift` (insertion point ~line 83)
- **Widgets coordinator**: `Anytype/Sources/PresentationLayer/Flows/HomeWidgetsCoordinator/HomeWidgetsCoordinatorView.swift` / `HomeWidgetsCoordinatorViewModel.swift` (lines 21, 40–50, 69, 80–85 — auto-show picker logic to remove). Note: this is also where the post-creation picker is triggered (on `.onAppear` when homepage is empty) — relevant for Task 8 too.
- **Space settings**: `Anytype/Sources/PresentationLayer/SpaceSettings/SpaceSettings/SpaceSettingsView.swift` (lines 317–338), `SpaceSettingsViewModel.swift` (lines 311–319 — `loadHomePageState`)
- **Settings home picker** (actual location): `Anytype/Sources/PresentationLayer/SpaceSettings/HomePage/HomepageSettingsPickerView.swift`, `HomepageSettingsPickerViewModel.swift`
- **Services**: `WorkspaceService.swift` (line 34 `setHomepage`, line 76 `createOneToOneSpace`), `HomepagePickerService.swift`
- **Model**: `SpaceHomepage.swift` (ServiceLayer/SpaceStorage/Models/)
- **Widget patterns**: `LinkWidgetViewContainer.swift` (long-press), `WidgetCommonActionsMenuView.swift` (context menu items)
- **Loc**: `Modules/Loc/Sources/Loc/Resources/Workspace.xcstrings`

### Related patterns found
- `WidgetScreenContext` enum (`.navigation` / `.overlay`) distinguishes widgets-list rendering mode. Home widget renders only for `.overlay`.
- `SpaceHomepage` enum already models `.empty`, `.widgets`, `.graph`, `.object(id)`. Add a display helper that collapses `.empty → .widgets` for fallback.
- Context menus use `.contextMenu { WidgetCommonActionsMenuView(...) }` or custom `ViewBuilder` items — pattern verified on `LinkWidgetViewContainer`.
- `ChannelOnboardingStorage` holds both homepage-dismiss flags and invite-members-dismiss flags. Only homepage flags are removed; invite-members flags stay.

### Dependencies identified
- No middleware changes needed on iOS side. GO-7175 is tracked separately.
- No protobuf regeneration (SetHomepage already wired).

## Development Approach

- **Testing approach**: Minimal — follow iOS repo norm. Unit tests exist for some ViewModels; add tests only where there is existing coverage or clear logic to validate. UI composition changes are verified via compile + simulator smoke-check.
- Complete each task fully before moving to the next.
- Run `make generate` after any `.xcstrings` edit.
- Report compile status to the user; the user verifies in Xcode.
- Keep the codebase compiling at each task boundary (ordering below is chosen to make this possible).
- Maintain backward compatibility where feasible (the stub widget is a hard delete — acceptable since it is client-internal UX state).

## Testing Strategy

- **Unit tests**: add/update for `HomepageCreatePickerViewModel` (option list, Not now behavior), `HomepageSettingsPickerViewModel` (No home row selection), `SpaceSettingsViewModel.loadHomePageState` (widgets → "No home") if existing tests already cover these. Skip if no test file exists — do not introduce new test targets for this task.
- **Manual verification by user**: simulator runs are performed by the user, not the agent. At the end of implementation the agent hands off a checklist of flows to verify (see Task 10). The agent writes down expected behavior per flow; the user executes in the simulator and reports issues.
- **E2E**: repo has no UI-based e2e harness.

## Progress Tracking

- Mark completed items with `[x]` immediately when done.
- Add newly discovered tasks with ➕ prefix.
- Document blockers with ⚠️ prefix.
- Update this plan file if scope shifts during implementation.

## Solution Overview

Architecture stays intact — this is refinement, not restructuring. Three surface areas change:

1. **Pickers** (Create + Settings): update Create picker title/subtitle per Figma; drop Widgets option; rename buttons; replace thumbnail-selected highlighting with an explicit checkbox per thumbnail. Settings picker renamed to "Channel home", gets a "No home" row (same row layout as object rows, design-system home icon, "Opens on navigation on entry" caption) followed by a divider consistent with other rows.
2. **Widgets overlay**: generalise the existing `SpaceChatWidget` into a Home widget that renders whichever object (Chat/Page/Collection) is set as homepage, with a home glyph on the trailing edge. Delete the stub widget module and the auto-show-picker logic (empty homepage is impossible after creation — Not now sets widgets).
3. **1-on-1 creation**: client only skips the picker. No `SetHomepage` call — middleware owns the Chat-as-homepage wiring.

### Key design decisions

- **Empty homepage handling**: add a `displayValue` computed property on `SpaceHomepage` that maps `.empty → .widgets`. Call sites that render UI read `displayValue`; call sites that write or inspect raw state keep using the enum as-is. Avoids branching logic at every consumer.
- **Home widget non-reorderability**: implement by omitting drag modifiers and context-menu remove actions — no new "locked widget" abstraction. Three similar lines beats a premature abstraction.
- **Generalise, don't replace**: the existing `SpaceChatWidget` already renders a tappable top-of-overlay row with the correct styling for Chat homepages. Extend its data/view model to accept any homepage object (Chat/Page/Collection), add the trailing home glyph, and add the long-press context menu. Avoids creating a parallel widget that duplicates styling and navigation wiring.
- **Rename decision (resolved)**: rename `SpaceChatWidget*` → `HomeWidget*` across all 5 files. Reviewer confirmed only 5 files touch these names (3 widget files + 2 container files). Clean signal, small diff — worth it.
- **Homepage change never deletes the previous homepage object**: the plan only ever calls `setHomepage(.widgets | .object(newId))`. Implementers must not add any "cleanup" of the previous homepage object — it stays in the space as a regular object.
- **Non-reorder/non-delete enforcement (concrete)**: `SpaceChatWidgetView` today uses `LinkWidgetViewContainer(dragId: nil, homeState: .constant(.readwrite), allowContent: false, ...)`. `dragId: nil` disables drag-reorder. No `WidgetCommonActionsMenuView` is attached. Preserving these two properties and not adding a remove action in the new context menu is sufficient to meet the "can't reorder/unpin/delete" requirement. Task 3 must not change these.
- **Change Home routing**: reuse `HomepageSettingsPickerView` verbatim from the widgets overlay. Expose it through `HomeWidgetsCoordinatorViewModel` as a new sheet state (`showHomepagePicker` is being deleted; add a new `showHomeChangePicker`).
- **Create picker thumbnail selection**: per Figma, each thumbnail row gets an explicit checkbox. Remove the current thumbnail-tinted / highlighted selected state — selection is communicated only via the checkbox.
- **Stub widget deletion**: delete files and remove all references in one task at the end, after the Home widget is wired and compiling. This keeps each earlier task compilable.

## Technical Details

### `SpaceHomepage.displayValue`

```swift
extension SpaceHomepage {
    var displayValue: SpaceHomepage {
        self == .empty ? .widgets : self
    }
}
```

Used by `SpaceSettingsViewModel.loadHomePageState`, the Home widget visibility check, and the Settings picker current-selection marker.

### Home widget (generalised from `SpaceChatWidget`)

- `SpaceChatWidgetViewModel` today hard-codes the chat object ID and chat icon (shown only when homepage == Chat). The row's **styling** is correct to reuse — what changes is the data source.
- Generalise the view model to accept any homepage object ID and subscribe to that object's details for **real name and real icon** (not the hard-coded chat icon). Rename types (`SpaceChatWidget*` → `HomeWidget*`) or keep names to minimise diff — decide during implementation based on call-site count.
- Add a **trailing home glyph** (design-system home icon) next to the right edge. This is new — Figma node `13073-14855`.
- Visibility (updated): `screenContext == .overlay` AND `spaceView.homepage.displayValue == .object(_)` (any object, not just chat).
- Tap: open the homepage object (existing navigation path from `SpaceChatWidget` works for chat — confirm it works for generic objects; if not, route via the same object-open API used by `LinkWidgetViewContainer`).
- **Long-press**: `.contextMenu` per Figma node `13071-15807` — **system context menu with a single item "Change Home"**. Selecting it opens the same `HomepageSettingsPickerView` ("Channel home" screen) used from Space Settings.
- Kept non-reorderable / non-deletable by construction — no drag modifiers, no remove action.

### Picker changes (post-creation)

- `HomepagePickerOption` keeps only `.object(ObjectHomepageType)` for picker use; the `.widgets` enum case can remain (used by Settings picker).
- Title and subtitle updated per Figma (node `13065-16304`). Add new Loc keys, do not reuse the current "Create Home" copy — exact strings from design:
  - Title: e.g. `Loc.HomepagePicker.titleNew` — copy per Figma
  - Subtitle: e.g. `Loc.HomepagePicker.subtitleNew` — copy per Figma
  - (Final key names + exact strings to be confirmed against Figma during Task 1.)
- Button labels: `Loc.continue` (add if missing), `Loc.notNow` (add).
- **Thumbnail selected state removed.** Each option row gains a checkbox control (design-system radio/checkbox component). Selection is represented solely via checkbox state — no tint/border/background change on the thumbnail itself. Delete the current selected-state styling in `HomepageCreatePickerView`.
- Blurred background from Figma is skipped intentionally (keep current sheet background).
- `onLater()` renamed to `onNotNow()` — calls `homepagePickerService.setHomepage(spaceId:, homepage: .widgets)` then dismisses. No more `ChannelOnboardingStorage.setHomepagePickerDismissed`.

### Settings picker changes (Figma node `13065-16290`)

- **Screen title** changes from current copy to "Channel home" — new Loc key `Loc.SpaceSettings.HomePage.channelHome` (value per Figma).
- **"No home" row** at the top, using the **same row component** as the object rows below it (not a bespoke row).
  - Leading: design-system home icon (same asset used for the Home widget trailing glyph — pick per `design-system-developer` guide).
  - Title: `Loc.SpaceSettings.HomePage.noHome` ("No home").
  - Caption: "Opens to navigation on entry" (exact copy per Figma) — new Loc key `Loc.SpaceSettings.HomePage.noHomeSubtitle`.
  - Tick when current homepage resolves to widgets/empty.
- **Divider** between the "No home" row and the object list — same divider component used between the other rows on this screen (consistent visual treatment, not a bespoke separator).
- Selecting "No home" calls `setHomepage(.widgets)` and dismisses.

### Space Settings preview

- `SpaceSettingsViewModel.loadHomePageState`: when `homepage.displayValue == .widgets`, set a new `.noHome` state (or reuse `.empty` but replace the rendered string with `Loc.SpaceSettings.HomePage.noHome`). Prefer the latter to minimise churn.

### 1-on-1 skip picker (no client-side homepage call)

- Client responsibility: skip presenting `HomepageCreatePickerView` when `spaceType == .oneToOne`. Verify the existing create flow (`SpaceCreateCoordinatorView` / `SpaceCreateViewModel`) — if already skipped, add an inline comment noting why (homepage is set by middleware for 1-on-1).
- **Do not** call `setHomepage` from the client for 1-on-1 spaces. Middleware is expected to set Chat as homepage server-side on 1-on-1 creation.
- Verification step during testing: create a 1-on-1 and confirm `spaceView.homepage` resolves to the chat object. If it does not, file a middleware bug (GO-*). Client-side workaround is explicitly out of scope.

### Loc keys

New/changed keys in `Workspace.xcstrings` (exact strings to be taken from Figma during Task 1):
- `Loc.continue` ("Continue") — check if it already exists; reuse if so.
- `Loc.notNow` ("Not now") — add.
- `Loc.HomepagePicker.title` — update value to new title from Figma node `13065-16304` (or add a new key if copy diverges significantly; prefer update in place).
- `Loc.HomepagePicker.description` — update value to new subtitle from the same Figma node.
- `Loc.SpaceSettings.HomePage.channelHome` ("Channel home") — screen title for the Settings picker.
- `Loc.SpaceSettings.HomePage.noHome` ("No home") — add.
- `Loc.SpaceSettings.HomePage.noHomeSubtitle` (caption under "No home" per Figma — e.g. "Opens to navigation on entry") — add.
- Remove any stub-widget-only strings if unused after stub deletion (verify with `rg` before deleting).

## What Goes Where

- **Implementation Steps** (`[ ]`): all code + Loc changes in this codebase.
- **Post-Completion** (no checkboxes): simulator smoke tests, PR description / Linear update.

## Implementation Steps

### Task 1: Add/update Loc keys and regenerate

**Files:**
- Modify: `Modules/Loc/Sources/Loc/Resources/Workspace.xcstrings`
- Regenerate: `Modules/Loc/Sources/Loc/Generated/Strings.swift` (via `make generate`)

- [x] add/verify "Continue" key — verified: `Loc.continue` already exists (backtick-escaped) at Strings.swift line 270, reused as-is. No new key added.
- [x] add `notNow` key (value "Not now") — added as top-level `NotNow` → `Loc.notNow`.
- [x] update `HomepagePicker.title` with new copy — en value changed to "Set Channel Home". Subtitle `HomepagePicker.description` left unchanged (existing copy "Select what you and channel members see when they open the channel. You can always change it in settings." still accurate for the 3-option picker; Figma exact string not accessible — flag for user verification in Task 10).
- [x] add `SpaceSettings.HomePage.channelHome` (value "Channel home")
- [x] add `SpaceSettings.HomePage.noHome` (value "No home")
- [x] add `SpaceSettings.HomePage.noHomeSubtitle` (value "Opens to navigation on entry")
- [x] run `make generate`; Strings.swift regenerated cleanly with all new keys present.
- [x] (no unit tests — pure resource change)

### Task 2: Add `SpaceHomepage.displayValue` helper

**Files:**
- Modify: `Anytype/Sources/ServiceLayer/SpaceStorage/Models/SpaceHomepage.swift`

- [ ] add `displayValue` computed property mapping `.empty → .widgets`, identity otherwise
- [ ] search for tests of `SpaceHomepage` (`rg "SpaceHomepage" --type swift -l`) — if a test file exists, add one case for `.empty.displayValue == .widgets` and one for `.object(_).displayValue == self`
- [ ] if no existing test file, skip (don't introduce a new test target)

### Task 3: Generalise `SpaceChatWidget` into the Home widget

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/SpaceChat/SpaceChatWidgetViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/SpaceChat/SpaceChatWidgetView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/SpaceChat/SpaceChatWidgetData.swift`

- [ ] read current implementation to confirm the chat object ID + chat icon are hard-coded
- [ ] change the view model to accept/resolve any homepage object ID (Chat/Page/Collection); subscribe to that object's details for **real name and real icon**, replacing the hard-coded chat icon
- [ ] update visibility to `spaceView.homepage.displayValue == .object(_)` (any object), still gated to `screenContext == .overlay`
- [ ] add trailing home glyph (design-system home icon — confirm asset name via `design-system-developer` / `Assets` module) per Figma `13073-14855`
- [ ] verify tap navigation works for Page and Collection objects, not just chat — if not, route via the same object-open API used by `LinkWidgetViewContainer`
- [ ] add `.contextMenu` (system context menu) with a **single** "Change Home" item per Figma `13071-15807`, exposing an `onChangeHome` callback
- [ ] keep widget non-reorderable/non-removable (no drag, no remove action)
- [ ] rename `SpaceChatWidget*` → `HomeWidget*` across all 5 files (decision resolved during review): `SpaceChatWidgetView.swift`, `SpaceChatWidgetViewModel.swift`, `SpaceChatWidgetData.swift`, and call sites in `HomeWidgetsView.swift` + `HomeWidgetsViewModel.swift`
- [ ] preserve `LinkWidgetViewContainer(dragId: nil, allowContent: false, ...)` — these keep the widget non-reorderable and non-expandable. Do not add `WidgetCommonActionsMenuView` to the new context menu; only the single "Change Home" item
- [ ] no unit tests unless a neighbor widget has them — then mirror

### Task 4: Wire Change Home routing into the overlay coordinator

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/HomeWidgetsView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/HomeWidgetsViewModel.swift` (only if visibility needs updating — existing chat widget visibility may already live here)
- Modify: `Anytype/Sources/PresentationLayer/Flows/HomeWidgetsCoordinator/HomeWidgetsCoordinatorView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Flows/HomeWidgetsCoordinator/HomeWidgetsCoordinatorViewModel.swift`

- [ ] update visibility check wherever the existing chat widget is gated (was: homepage == Chat; becomes: homepage is any object) — do not render Home widget in `.navigation` context
- [ ] add `showHomeChangePicker: Bool` state on `HomeWidgetsCoordinatorViewModel`; wire the widget's `onChangeHome` callback to set it true
- [ ] present `HomepageSettingsPickerView` via `.sheet` driven by `showHomeChangePicker`
- [ ] keep the existing `showHomepagePicker` sheet intact for now (it is deleted in Task 9) so earlier tasks compile

### Task 5: Update Settings picker ("Channel home" screen + "No home" row)

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/SpaceSettings/HomePage/HomepageSettingsPickerView.swift`
- Modify: `Anytype/Sources/PresentationLayer/SpaceSettings/HomePage/HomepageSettingsPickerViewModel.swift`

- [ ] change screen title to `Loc.SpaceSettings.HomePage.channelHome` ("Channel home")
- [ ] add "No home" row at the top using the **same row component** as the object rows (not a bespoke row)
  - leading: design-system home icon
  - title: `Loc.SpaceSettings.HomePage.noHome`
  - caption: `Loc.SpaceSettings.HomePage.noHomeSubtitle`
  - tick when current homepage resolves to widgets/empty
- [ ] place a divider between the No home row and the object list, using the **same divider component** already used between object rows on this screen
- [ ] tapping "No home" calls `setHomepage(.widgets)` and dismisses
- [ ] remove the previous `Loc.empty` row that toggled to widgets
- [ ] add unit test if `HomepageSettingsPickerViewModel` already has a test file — case: selecting No home issues `setHomepage(.widgets)`

### Task 6: Update Space Settings preview text

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/SpaceSettings/SpaceSettings/SpaceSettingsViewModel.swift`

- [ ] in `loadHomePageState`, when `homepage.displayValue == .widgets`, set caption to `Loc.SpaceSettings.HomePage.noHome` (not `Loc.empty`)
- [ ] leave `.object(_)` branch unchanged
- [ ] add test case if a `SpaceSettingsViewModel` test file exists

### Task 7: Update post-creation Homepage picker

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepageCreatePickerView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepageCreatePickerViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepagePickerOption.swift` (if option list is defined here)

- [ ] options array = `[.object(.chat), .object(.page), .object(.collection)]` — drop `.widgets`
- [ ] update title and subtitle to use the new Loc keys from Task 1 (per Figma `13065-16304`)
- [ ] primary button label → `Loc.continue`
- [ ] secondary button label → `Loc.notNow`
- [ ] **remove thumbnail selected-state styling** (tint/border/background change on the active thumbnail)
- [ ] **add a checkbox per option row** using the design-system checkbox/radio component — checkbox state reflects selection; thumbnail itself is always neutral
- [ ] keep current (non-blurred) sheet background — Figma's blurred background is intentionally skipped
- [ ] rename `onLater()` → `onNotNow()`; implementation = `setHomepage(spaceId:, homepage: .widgets)` then dismiss
- [ ] remove any `ChannelOnboardingStorage.setHomepagePickerDismissed(...)` call
- [ ] add test if `HomepageCreatePickerViewModel` has a test file — cases: option list has 3 entries; `onNotNow` calls `setHomepage(.widgets)`

### Task 8: Skip post-creation picker for 1-on-1 spaces (no client-side SetHomepage)

**Important correction from review**: the post-creation picker is NOT presented from SpaceCreate. It is triggered by `HomeWidgetsCoordinatorViewModel.onAppear()` (lines 40–51), gated on `spaceView?.homepage == .empty`. Task 8 therefore targets the coordinator, not SpaceCreate.

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Flows/HomeWidgetsCoordinator/HomeWidgetsCoordinatorViewModel.swift`

- [ ] in the `.onAppear` gate that presents `HomepageCreatePickerView`, add a guard: skip when `participantSpaceView.spaceView.isOneToOne` (or `spaceUxType == .oneToOne` / `spaceType == .oneToOne` — use whichever helper already exists in the codebase)
- [ ] **note**: once Task 9 deletes the whole auto-show-picker block, this 1-on-1 guard disappears with it — because the picker is no longer auto-shown from the coordinator at all. So this task becomes a no-op if Task 9 runs. Decide during implementation: if Task 9 runs fully in the same PR, skip Task 8 entirely and document here why (the empty-homepage scenario no longer auto-opens a picker, so there is nothing to gate for 1-on-1).
- [ ] do **not** add any `setHomepage` call for 1-on-1 spaces — middleware is expected to set Chat as homepage server-side
- [ ] during user verification (Task 10), confirm `spaceView.homepage` resolves to the chat object for a freshly created 1-on-1. If it does not, file a middleware bug and note it as a blocker ⚠️ — do not add a client workaround
- [ ] no tests unless caller has existing coverage

### Task 9: Delete stub widget and dismissal storage

**Files:**
- Delete: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Stub/StubWidgetsView.swift`
- Delete: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Stub/StubWidgetsViewModel.swift` (also references `isCreateHomeDismissed` around lines 99/105 — must be removed together)
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/HomeWidgetsView.swift` (remove stub insertion ~line 83)
- Modify: `Anytype/Sources/PresentationLayer/Flows/HomeWidgetsCoordinator/HomeWidgetsCoordinatorView.swift` (remove `showHomepagePicker` sheet, lines 80–85)
- Modify: `Anytype/Sources/PresentationLayer/Flows/HomeWidgetsCoordinator/HomeWidgetsCoordinatorViewModel.swift` (remove `showHomepagePicker`, auto-show logic lines 40–50, `onHomepagePickerFinished` line 69)
- Modify: `Anytype/Sources/ServiceLayer/Block/Widget/ChannelOnboardingStorage.swift` (remove `homepagePickerDismissed` + `createHomeDismissed` methods; keep invite-members methods)
- Modify: any DI containers if the stub widget had a factory registered

- [ ] run `rg "StubWidgets" --type swift` and `rg "homepagePickerDismissed" --type swift` — confirm no stragglers
- [ ] run `rg "createHomeDismissed" --type swift` and `rg "isCreateHomeDismissed" --type swift` — delete all references
- [ ] `rg "HomepagePicker.title" --type swift` — if no remaining refs, delete the key from `Workspace.xcstrings` and regenerate
- [ ] confirm `ChannelOnboardingStorage` still serves invite-members dismissal; if not, delete the file entirely
- [ ] UserDefaults key `"stubWidgetDismissals"` (or equivalent) used by `ChannelOnboardingStorage` for now-removed flags: leave stale keys in place for existing users (harmless; no migration needed). Document this decision in a one-line comment at the deletion site.

### Task 10: Hand off manual verification checklist

The agent does not run the simulator. At the end of implementation, present this checklist to the user for verification and wait for feedback. Each item describes the flow to run and the expected outcome.

**User to verify** (agent waits for confirmation):

- [ ] project compiles cleanly; Loc generation has no warnings
- [ ] **Post-creation picker**: create a Personal channel. Picker appears with new title/subtitle per Figma. Exactly 3 options: Chat, Page, Collection (no Widgets). Primary button reads "Continue"; secondary reads "Not now".
- [ ] **Picker selection UI**: tapping a row toggles only its checkbox; the thumbnail itself does not highlight / tint / get a border.
- [ ] **Not now**: tapping "Not now" dismisses the picker; re-entering the channel shows the widgets overlay; no Home widget is rendered.
- [ ] **Continue with Chat**: pick Chat → Continue. Home widget appears at the top of the widgets overlay with the chat object's name + icon + trailing home glyph. Tapping opens the chat.
- [ ] **Continue with Page**: repeat for Page. Home widget shows the page's name and icon (not chat icon). Tapping opens the page.
- [ ] **Continue with Collection**: repeat for Collection. Same expectations.
- [ ] **Long-press Home widget**: system context menu appears with a single "Change Home" item per Figma `13071-15807`. Selecting it opens the "Channel home" settings picker.
- [ ] **Settings picker ("Channel home")**: title reads "Channel home". First row is "No home" with a design-system home icon and caption "Opens to navigation on entry" (exact copy per Figma). A divider matches the divider style used between the object rows.
- [ ] **Select No home**: tapping "No home" sets homepage to widgets; widgets overlay is shown on re-entry; Home widget disappears.
- [ ] **Space Settings → Home preview**: when homepage is widgets, the row caption reads "No home" (not "Empty").
- [ ] **1-on-1 space creation**: create a 1-on-1. No picker is shown. Verify that `spaceView.homepage` resolves to the chat object (entering the space lands on chat; Home widget appears in the overlay). If not, file a middleware bug — blocker for this acceptance item.
- [ ] **Stub widget gone**: no "Create Home" stub widget appears in any flow.
- [ ] **Widget non-reorder**: Home widget cannot be dragged / removed / hidden from the overlay.

### Task 11 (optional): Replace picker thumbnail assets with exported images

Current implementation draws the Chat / Page / Collection option thumbnails in code. They may look acceptable — user will evaluate after Task 10 hand-off.

**Files:**
- Modify: `Modules/Assets/Sources/.../` (design-system asset module — pick correct subfolder per `design-system-developer`)
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepageCreatePickerView.swift` (swap code-drawn thumbnail → `Image(asset:)`)

- [ ] only after user confirms code-drawn thumbnails are insufficient
- [ ] user exports thumbnail images from Figma and shares them
- [ ] add the assets to the `Assets` module; regenerate as needed
- [ ] replace the code-drawn thumbnail views in `HomepageCreatePickerView` with `Image(asset: ...)` per option
- [ ] user re-verifies picker visuals in simulator

### Task 12: Final — update plan and docs

- [ ] mark all checkboxes
- [ ] move this plan to `docs/plans/completed/`

## Post-Completion

**Manual verification**:
- User runs the Task 10 hand-off checklist in the iOS simulator and reports issues.
- Analytics: `rg "log.*[Hh]omepage"` during review found no analytics events tied to homepage picker / button labels / Widgets option. Nothing to break. (Re-verify during Task 1 if the codebase has changed.)
- Verify Figma parity for Home widget row (icon placement, spacing, typography) against design link in the issue.

**External updates / middleware dependencies**:
- GO-7175 (middleware resets homepage to widgets on object deletion): await deployment before shipping the "homepage object deleted" flow broadly. Without it, deleting a homepage object leaves homepage empty; the client's `displayValue` fallback renders widgets correctly — no blocker for client ship.
- 1-on-1 homepage: middleware must set Chat as homepage on 1-on-1 space creation. Verify during Task 10. If missing, file a middleware bug — this becomes a blocker for the 1-on-1 acceptance criterion. No client-side workaround.
- Linear IOS-6059: update status and link PR on completion.
