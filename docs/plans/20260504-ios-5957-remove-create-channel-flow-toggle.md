# IOS-5957 Remove createChannelFlow toggle and clean up legacy create-space flow

## Overview

The `createChannelFlow` feature toggle (defaultValue: true since release 18) gates the unified "Channels" creation flow that replaces the legacy "Spaces" creation flow (Chat / Data / Stream picker → simple modal). With release 18 shipped, the FALSE branches are unreachable.

This task removes the toggle and inlines the TRUE branches everywhere, then cleans up everything the toggle removal exposes as dead: orphan UI components, image assets, localization strings, and the now-redundant `spaceUxType` field in `SpaceCreateData`.

Out of scope (deferred to follow-up tasks):
- Removing `spaceUxType:` overloads in `SearchHelper`, `SearchFiltersBuilder`, `DetailsLayout.*`, `ObjectAction.buildActions`, `SetSubscriptionData`, `ObjectTypeSection.supportedLayouts`, `objectTypesWithObjectsCreatedService.startSubscription`
- Removing `SpaceView.uxType` and `SpaceUxType.supportsMultiChats`
- Sibling Release-18 toggles `fixChannelHomeBackNavigation` (IOS-6067) and `fixAvatarTapFreeze` (IOS-5998)

## Context (from discovery)

- 36 call sites of `FeatureFlags.createChannelFlow` across 25 Swift files
- Toggle definition: `Modules/AnytypeCore/AnytypeCore/Utils/FeatureFlags/FeatureDescription+Flags.swift:32-36`
- ~21 mechanical sites: parametric `spaceType` vs `spaceUxType` swap (no orphans exposed)
- ~5 UI conditional sites: orphan `SpaceCreateView`, `SpaceCreateTypePickerView`, `SpaceTypePickerRow`, dead toolbar button branches, dead empty-state branches
- 3 image assets become orphan (`Channel/Chat`, `Channel/Space`, `Channel/Stream`)
- 3 localization keys in `Workspace.xcstrings` become orphan (`SpaceCreate.Chat.Title`, `SpaceCreate.Space.Title`, `SpaceCreate.Stream.Title`)
- 1 localization key in `UI.xcstrings` becomes orphan (`Create Space`)
- 1 analytics event becomes orphan (`logScreenVaultCreateMenu`)
- No references in `AnyTypeTests/` or `Anytype/Sources/PreviewMocks/` — no test/mock churn for the toggle itself
- Today's date: 2026-05-04. Branch already checked out: `ios-5957-clean-up-code-and-feature-toggle-for-create-channel-flow`

## Development Approach

- **Testing approach**: Regression by existing test suite + Xcode compilation verification by user. This task only deletes unreachable code paths; no new behavior is introduced, so no new unit tests are required. Each task ends with the user verifying compilation in Xcode (per project preference; do NOT invoke `build-checker`).
- Complete each task fully before moving to the next.
- Make small, focused changes — one task = one logical batch.
- Update this plan file (mark `[x]` immediately) when each item completes.
- Add `➕` for newly discovered items, `⚠️` for blockers.

## Testing Strategy

- **Unit tests**: Existing `AnyTypeTests/` suite serves as regression check. No new tests required because all changes are deletions of unreachable branches or simple inlining.
- **Manual verification (after Task 8)**: User runs the app and exercises the create-channel flow end-to-end (personal channel creation, group channel creation, QR join, empty-state in SpacesManager and SpaceHub).
- **Compilation verification**: After each task, user verifies in Xcode locally.

## Progress Tracking

- Mark `[x]` immediately when an item is done.
- Add ➕ prefix for newly discovered tasks.
- Add ⚠️ prefix for blockers.
- Keep the plan file in sync with actual work.

## Solution Overview

Single PR, single branch. Tasks are sequenced from lowest blast radius (mechanical service-layer swaps) to highest (toggle definition + codegen + final verification), so any compilation problem surfaces close to the change that introduced it.

`SpaceCreateData` simplification (Option C) is sequenced AFTER UI orphan cleanup so that `channelType` becoming non-optional and `spaceUxType` being dropped only happens once all dead callers are gone.

## Technical Details

- **Removal pattern**: For each `if FeatureFlags.createChannelFlow { A } else { B }`, keep `A`, delete `B` (toggle defaults to `true`).
- **Inverted patterns**: `guard FeatureFlags.createChannelFlow else { return }` → drop guard. `FeatureFlags.createChannelFlow && expr` → keep `expr`.
- **`SpaceCreateData` post-cleanup**: `channelType: ChannelType` (non-optional), no `spaceUxType` field, no `title` getter, no `SpaceUxType.useCase` extension.
- **Codegen**: After deleting toggle definition, image assets, and localization keys, run `make generate` once at the end (Task 8) to regenerate `FeatureFlags+Flags.swift`, `ImageAssets.swift`, and `Strings.swift` in a single pass.
- **Analytics**: `logScreenVaultCreateMenu()` removed; `logClickVaultCreateMenu{Chat,Space,Join}()` STAY (still used by `SpaceHubViewModel` for the new menu).

## What Goes Where

- **Implementation Steps**: All deletions/edits in this codebase, including image asset folder removal, xcstrings edits, and codegen.
- **Post-Completion**: Manual app exercise on simulator/device, PR open against `develop`.

## Implementation Steps

### Task 1: Inline TRUE branch in ServiceLayer call sites (mechanical)

**Files:**
- Modify: `Anytype/Sources/ServiceLayer/Subscriptions/RecentSubscriptionService.swift`
- Modify: `Anytype/Sources/ServiceLayer/Object/TypesService/TypesService.swift`
- Modify: `Anytype/Sources/ServiceLayer/Object/Search/SearchService.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/Date/Subscription/DateRelatedObjectsSubscriptionService.swift`

- [ ] `RecentSubscriptionService.swift:46` — keep `spaceType` branch, drop `spaceUxType` branch
- [ ] `TypesService.swift:62` — same swap (in `searchObjectTypes`)
- [ ] `TypesService.swift:113` — same swap (in `searchListTypes`)
- [ ] `TypesService.swift:137` — same swap (in `searchLibraryObjectTypes`)
- [ ] `SearchService.swift:18` — keep TRUE in `search(text:spaceId:)`
- [ ] `SearchService.swift:85` — keep TRUE in `searchObjectsByTypes`
- [ ] `SearchService.swift:129` — keep TRUE in `searchObjects` with excludedLayouts
- [ ] `SearchService.swift:150` — keep TRUE in `searchRelationOptions(relationKey:)`
- [ ] `SearchService.swift:179` — keep TRUE in `searchRelationOptions(optionIds:)`
- [ ] `SearchService.swift:207` — keep TRUE in `searchRelations`
- [ ] `SearchService.swift:260` — keep TRUE in `searchObjectsWithLayouts`
- [ ] `DateRelatedObjectsSubscriptionService.swift:40` — keep TRUE
- [ ] After all edits: remove `import AnytypeCore` from any of these files if `FeatureFlags` was the sole consumer (verify by grep `FeatureFlags\|AnytypeCore` per file)
- [ ] User verifies Xcode compiles before next task

### Task 2: Inline TRUE branch in PresentationLayer non-UI call sites (mechanical)

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/ObjectTypeSearch/ObjectTypeSearchViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/ObjectCreationSettings/Views/Selection/Dataview/SetObjectCreationSettingsInteractor.swift`
- Modify: `Anytype/Sources/PresentationLayer/TextEditor/EditorPage/Views/Settings/ObjectSettings/ObjectSettingsViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/TextEditor/AccessoryView/Mention/MentionViewController/MentionsViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/TextEditor/Set/EditorSetViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Common/SwiftUI/Search/ObjectSearchWithMeta/ObjectSearchWithMetaViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Common/SwiftUI/Search/GlobalSearch/GlobalSearchViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/SharingExtensionShareTo/SharingExtensionShareToViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Container/HomeWidgetsViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/SpecificInternalModels/SetObjectWidgetInternalViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeWidgets/Widgets/Stub/InviteMembersStubWidgetViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeNavigationContainer/Panel/HomeBottomNavigationPanelViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/SharingExtension/SharingExtensionViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Flows/SpaceHub/SpaceHubCoordinatorViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Flows/HomeWidgetsCoordinator/HomeWidgetsCoordinatorViewModel.swift`

- [ ] `ObjectTypeSearchViewModel.swift:84` — keep TRUE
- [ ] `SetObjectCreationSettingsInteractor.swift:158` — keep TRUE
- [ ] `ObjectSettingsViewModel.swift:177` and `:205` — keep TRUE in both
- [ ] `MentionsViewModel.swift:58` — keep TRUE
- [ ] `EditorSetViewModel.swift:571` — keep TRUE
- [ ] `ObjectSearchWithMetaViewModel.swift:121` — keep TRUE
- [ ] `GlobalSearchViewModel.swift:187` — keep TRUE
- [ ] `SharingExtensionShareToViewModel.swift:48` and `:92` — keep TRUE in both
- [ ] `HomeWidgetsViewModel.swift:229` — keep TRUE
- [ ] `SetObjectWidgetInternalViewModel.swift:244` — keep TRUE
- [ ] `InviteMembersStubWidgetViewModel.swift:45` — drop `FeatureFlags.createChannelFlow &&` from the AND expression (keep the rest)
- [ ] `HomeBottomNavigationPanelViewModel.swift:198` — keep TRUE
- [ ] `SharingExtensionViewModel.swift:60` and `:80` — keep TRUE in both
- [ ] `SpaceHubCoordinatorViewModel.swift:165` — keep TRUE (drop the `if`, keep `Task { await contactsService.prefetch() }`)
- [ ] `HomeWidgetsCoordinatorViewModel.swift:39` — drop the `guard FeatureFlags.createChannelFlow else { return }` line (method always proceeds)
- [ ] After all edits: remove `import AnytypeCore` from any of these files if `FeatureFlags` was the sole consumer
- [ ] User verifies Xcode compiles before next task

### Task 3: Inline TRUE branch in UI views and delete orphan UI files

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceCreate/Coordinator/SpaceCreateCoordinatorView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpacesManager/SpacesManagerView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpacesManager/SpacesManagerViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Subviews/SpaceHubEmptyStateView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Subviews/SpaceHubNewSpaceButton.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Subviews/SpaceHubToolbar.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/Subviews/SpaceHubList.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/SpaceHubView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceHub/SpaceHubViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Flows/SpaceHub/SpaceHubCoordinatorView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Flows/SpaceHub/SpaceHubCoordinatorViewModel.swift`
- Delete: `Anytype/Sources/PresentationLayer/Modules/SpaceCreate/SpaceCreateView.swift`
- Delete: `Anytype/Sources/PresentationLayer/Modules/SpaceTypePicker/SpaceTypePickerView.swift`
- Delete: `Anytype/Sources/PresentationLayer/Modules/SpaceTypePicker/SpaceTypePickerRow.swift`

- [ ] `SpaceCreateCoordinatorView.swift:16` — keep TRUE branch (`ChannelCreateView`); delete FALSE branch and the `if/else`
- [ ] `SpacesManagerView.swift:59` — keep TRUE branch (`CreateChannelEmptyStateView`); delete FALSE branch and the `if/else`
- [ ] `SpacesManagerView.swift:32-38` — delete the `.sheet(isPresented: $model.showSpaceTypeForCreate)` block (legacy picker entry)
- [ ] `SpacesManagerViewModel.swift` — delete `var showSpaceTypeForCreate`, `func onTapCreateSpace()`, `func onSpaceTypeSelected(_:)` (no remaining callers); leave `onTapCreatePersonalChannel`, `onTapCreateGroupChannel`, `onSelectQrCodeScan`
- [ ] `SpaceHubEmptyStateView.swift:13` — keep `channelMenuEmptyState`; delete FALSE branch and the `if/else`; drop `let onTapCreateSpace: () -> Void` callback param
- [ ] `SpaceHubNewSpaceButton.swift:14` — keep `menuContent`; delete `buttonContent` private view; drop `let onTap: () -> Void` callback param; collapse body to `menuContent` directly
- [ ] `SpaceHubToolbar.swift:81` — delete the FALSE branch in `ios26ToolbarItems` (keep the Menu); inspect `legacyToolbarItems` — `SpaceHubNewSpaceButton` no longer takes `onTap:`, so remove `onTap: { onTapCreateSpace() }` arg
- [ ] `SpaceHubToolbar.swift` — drop `let onTapCreateSpace: () -> Void` callback param (no remaining usage after both branches simplified)
- [ ] `SpaceHubList.swift:44-45` — drop the `onTapCreateSpace:` argument when calling `SpaceHubEmptyStateView`
- [ ] `SpaceHubView.swift:74-75` — drop the `onTapCreateSpace:` argument when calling `SpaceHubToolbar`
- [ ] `SpaceHubViewModel.swift:57-59` — delete `func onTapCreateSpace()` (no remaining callers); also check `output?.onSelectCreateObject()` — if no other caller, drop the protocol method too
- [ ] `SpaceHubCoordinatorView.swift:87-94` — delete the `.sheet(isPresented: $model.showSpaceTypeForCreate)` block (and the `.navigationZoomTransition(sourceID: "SpaceCreateTypePickerView", in: namespace)` modifier)
- [ ] `SpaceHubCoordinatorViewModel.swift` — delete `var showSpaceTypeForCreate`, `func onSpaceTypeSelected(_:)`, and the legacy lines 247–249 block including the `// After dismiss spaceCreateData, alert will appear again. Fix it.` comment
- [ ] `SpaceHubToolbar.swift` — also check the `.matchedTransitionSource(id: "SpaceCreateTypePickerView", in: namespace)` modifier on the Menu (line ~99) — keep if it still serves the new menu's transition; otherwise drop
- [ ] Delete file: `Anytype/Sources/PresentationLayer/Modules/SpaceCreate/SpaceCreateView.swift`
- [ ] Delete file: `Anytype/Sources/PresentationLayer/Modules/SpaceTypePicker/SpaceTypePickerView.swift`
- [ ] Delete file: `Anytype/Sources/PresentationLayer/Modules/SpaceTypePicker/SpaceTypePickerRow.swift`
- [ ] After file deletions: verify no remaining grep hits for `SpaceCreateView\b`, `SpaceCreateTypePickerView`, `SpaceTypePickerRow` (excluding `ChannelCreateView` and `SpaceCreateCoordinatorView`)
- [ ] User verifies Xcode compiles before next task

### Task 4: Simplify SpaceCreateData and SpaceCreateViewModel (Option C)

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceCreate/SpaceCreateData.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpaceCreate/SpaceCreateViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Flows/ChannelCreate/GroupChannelCreateCoordinatorViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Flows/SpaceHub/SpaceHubCoordinatorViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Modules/SpacesManager/SpacesManagerViewModel.swift`

- [ ] `SpaceCreateData.swift` — change `channelType: ChannelType?` to non-optional `channelType: ChannelType`; update initializer accordingly
- [ ] `SpaceCreateData.swift` — delete `let spaceUxType: SpaceUxType` field and its init parameter
- [ ] `SpaceCreateData.swift` — delete `var title: String { ... }` getter (only consumer was deleted `SpaceCreateView`)
- [ ] `SpaceCreateData.swift` — delete `extension SpaceUxType { var useCase: UseCase { ... } }` (only consumer was deleted `createLegacySpace`)
- [ ] `SpaceCreateViewModel.swift` — delete `private func createLegacySpace()` (lines ~134–155)
- [ ] `SpaceCreateViewModel.swift:53-73` — simplify `onTapCreate()`: replace the `if let channelType = data.channelType { ... } else { ... }` with direct `let spaceId = try await createChannel(channelType: data.channelType)` (channelType now non-optional)
- [ ] `SpaceCreateViewModel.swift:68` — replace `spaceUxType: data.spaceUxType` analytics arg with hardcoded `spaceUxType: .data` (channels are always `.data`)
- [ ] `SpaceCreateViewModel.swift:48, 88, 100` — collapse all three `let isCircular = data.channelType == nil && data.spaceUxType.isChat` to `let isCircular = false` and inline (channels are always square in creation; one-on-one circular rendering is at `SpaceCardModelBuilder` and unaffected). Verify each `IconView` rendering still passes the literal `false`.
- [ ] `GroupChannelCreateCoordinatorViewModel.swift:53` — drop `spaceUxType: .data` argument from `SpaceCreateData(...)` call
- [ ] `SpaceHubCoordinatorViewModel.swift:267` — drop `spaceUxType: .data` argument from `SpaceCreateData(...)` call
- [ ] `SpacesManagerViewModel.swift:79` — drop `spaceUxType: .data` argument from `SpaceCreateData(...)` call
- [ ] After edits: grep `SpaceCreateData(` to confirm only call sites remain are the three above (each with `channelType: .personal` or `.group` and `selectedContacts`)
- [ ] After edits: grep `data.spaceUxType\|data.title\|SpaceUxType\.useCase` in `SpaceCreate/` — should be zero hits
- [ ] User verifies Xcode compiles before next task

### Task 5: Delete orphan analytics event

**Files:**
- Modify: `Anytype/Sources/Analytics/AnytypeAnalytics/AnytypeAnalytics+Events.swift`
- Modify: `Anytype/Sources/Analytics/AnytypeAnalytics/AnalyticsConstants.swift` (if event name constant exists there)

- [ ] Delete `func logScreenVaultCreateMenu()` at `AnytypeAnalytics+Events.swift:1481` (only caller was deleted `SpaceTypePickerView:46`)
- [ ] Search for the underlying `AnalyticsEventsName` enum case used by that function (e.g. `screenVaultCreateMenu`); if no other reference, delete it from `AnalyticsConstants.swift`
- [ ] KEEP `logClickVaultCreateMenuChat()` (line 1473), `logClickVaultCreateMenuSpace()` (line 1477), and `logClickVaultCreateMenuJoin()` — still used by `SpaceHubViewModel:62, 67, 72` for the new menu
- [ ] User verifies Xcode compiles before next task

### Task 6: Delete orphan image assets and Channel asset folder

**Files:**
- Delete: `Modules/Assets/Sources/Assets/Resources/Assets.xcassets/DesignSystem/Channel/Chat.imageset/`
- Delete: `Modules/Assets/Sources/Assets/Resources/Assets.xcassets/DesignSystem/Channel/Space.imageset/`
- Delete: `Modules/Assets/Sources/Assets/Resources/Assets.xcassets/DesignSystem/Channel/Stream.imageset/`
- Delete: `Modules/Assets/Sources/Assets/Resources/Assets.xcassets/DesignSystem/Channel/` (entire folder, including `Contents.json`)

- [ ] Delete `Channel/Chat.imageset/` directory (only `.Channel.chat` ref was in deleted `SpaceTypePickerView`)
- [ ] Delete `Channel/Space.imageset/` directory (only `.Channel.space` ref was in deleted `SpaceTypePickerView`)
- [ ] Delete `Channel/Stream.imageset/` directory (`.Channel.stream` already had zero Swift refs before this PR; piggyback)
- [ ] Delete the now-empty `DesignSystem/Channel/` parent directory (including its `Contents.json`)
- [ ] Verify no remaining grep hits for `\.Channel\.chat\|\.Channel\.space\|\.Channel\.stream\|Channel/Chat\|Channel/Space\|Channel/Stream` across `--type swift` and `--type-add 'asset:*.{xcassets,json}'` (codegen `ImageAssets.swift` will still reference them until Task 8 runs `make generate`)
- [ ] User verifies Xcode compiles before next task — note: `ImageAssets.swift` may still reference removed assets until codegen runs in Task 8; if compile breaks, user can either run `make generate` early or proceed to Task 8

### Task 7: Delete orphan localization strings

**Files:**
- Modify: `Modules/Loc/Sources/Loc/Resources/UI.xcstrings`
- Modify: `Modules/Loc/Sources/Loc/Resources/Workspace.xcstrings`

- [ ] `UI.xcstrings` — delete the `"Create Space"` top-level key (the entry around line 23522, including all locale `value` translations); confirm `Loc.thereAreNoSpacesYet` ("There are no spaces yet") STAYS — still used by `SharingExtensionView.swift:123`
- [ ] `Workspace.xcstrings` — delete the `"SpaceCreate.Chat.Title"` key (only consumer was deleted `SpaceCreateData.title`)
- [ ] `Workspace.xcstrings` — delete the `"SpaceCreate.Stream.Title"` key (only consumer was deleted `SpaceCreateData.title`)
- [ ] `Workspace.xcstrings` — delete the `"SpaceCreate.Space.Title"` key (only consumer was deleted `SpaceCreateData.title`); double-check via `rg "SpaceCreate.Space.Title\|Loc.SpaceCreate.Space.title"` — should be zero non-generated hits
- [ ] If `SpaceCreate` was the only key under that grouping, ensure no orphan empty group remains (xcstrings JSON is flat by key, so this is just a sanity check)
- [ ] User verifies Xcode compiles before next task — note: `Strings.swift` still references the removed keys until codegen runs in Task 8

### Task 8: Remove toggle definition, run codegen, final verification

**Files:**
- Modify: `Modules/AnytypeCore/AnytypeCore/Utils/FeatureFlags/FeatureDescription+Flags.swift`
- Auto-regenerated: `Modules/AnytypeCore/AnytypeCore/Generated/FeatureFlags+Flags.swift`
- Auto-regenerated: `Modules/Assets/Sources/Assets/Generated/ImageAssets.swift`
- Auto-regenerated: `Modules/Loc/Sources/Loc/Generated/Strings.swift`

- [ ] Delete `static let createChannelFlow = FeatureDescription(...)` block at `FeatureDescription+Flags.swift:32-36`
- [ ] Run `make generate` from repo root — regenerates `FeatureFlags+Flags.swift`, `ImageAssets.swift`, and `Strings.swift` in one pass
- [ ] Verify generated `FeatureFlags+Flags.swift` no longer contains `createChannelFlow` (case in enum nor accessor)
- [ ] Verify generated `ImageAssets.swift` no longer contains `Channel.chat`, `Channel.space`, `Channel.stream` (and the `Channel` enum scope itself if empty)
- [ ] Verify generated `Strings.swift` no longer contains `createSpace`, `SpaceCreate.Chat.title`, `SpaceCreate.Stream.title`, `SpaceCreate.Space.title` (and the `SpaceCreate` enum scope itself if empty)
- [ ] Run grep checks (all should return empty):
  - `rg "createChannelFlow" --type swift`
  - `rg "SpaceCreateTypePickerView|SpaceTypePickerRow" --type swift`
  - `rg "\\bSpaceCreateView\\b" --type swift` (excluding `SpaceCreateCoordinatorView`)
  - `rg "Loc\\.createSpace\\b" --type swift`
  - `rg "SpaceCreate\\.Chat\\.title|SpaceCreate\\.Stream\\.title|SpaceCreate\\.Space\\.title" --type swift`
  - `rg "Channel\\.chat\\b|Channel\\.space\\b|Channel\\.stream\\b" --type swift`
  - `rg "showSpaceTypeForCreate|onSpaceTypeSelected\\b" --type swift`
  - `rg "data\\.spaceUxType|data\\.title|SpaceUxType\\.useCase" --type swift Anytype/Sources/PresentationLayer/Modules/SpaceCreate/`
  - `rg "logScreenVaultCreateMenu" --type swift`
- [ ] User verifies Xcode compiles cleanly with full clean build
- [ ] User runs the existing `AnyTypeTests/` suite and confirms green

### Task 9: Manual exercise + PR + plan archival

- [ ] User exercises the create-channel flow on simulator/device:
  - Create personal channel (from SpaceHub toolbar Menu)
  - Create group channel (from SpaceHub toolbar Menu) — confirm pre-create contact selection still works
  - Join via QR (from SpaceHub toolbar Menu)
  - SpaceHub empty state (no spaces) — `CreateChannelEmptyStateView` renders
  - SpacesManager empty state (no spaces) — `CreateChannelEmptyStateView` renders
  - One-to-one channel still renders with circular icon in SpaceHub (driven by `SpaceCardModelBuilder`, unaffected)
  - SharingExtension flow — confirm `SharingExtensionShareToViewModel` `isMultiChatSpace` and `search()` still pick correct layouts
  - Sharing-from-extension empty state still shows "There are no spaces yet" (`Loc.thereAreNoSpacesYet` retained)
- [ ] Open PR to `develop` with title `IOS-5957 Remove createChannelFlow toggle and clean up legacy create-space flow` and a 2–3 bullet body summarizing toggle removal + orphan UI cleanup + asset/localization cleanup
- [ ] Move this plan to `docs/plans/completed/`

## Post-Completion

**Manual verification on simulator/device** (covered in Task 9 — listed here for reference): create personal channel, group channel, QR join, both empty-state surfaces, one-to-one icon shape regression, sharing-extension regression.

**External system updates**: None. This is iOS-only and does not require middleware coordination, marketing copy review, or analytics dashboard updates (analytics events removed are the orphan `logScreenVaultCreateMenu` only — the click events that survive are unchanged).

**Follow-up tickets** (out of scope for this PR, candidate next tasks):
- Remove all `spaceUxType:` overloads in `SearchHelper`, `SearchFiltersBuilder`, `DetailsLayout.{visibleLayouts, visibleLayoutsWithFiles, widgetTypeLayouts, supportedForCreation, supportedForSharingExtension}`, `ObjectAction.buildActions(spaceUxType:)`, `SetSubscriptionData(spaceUxType:)`, `ObjectTypeSection.supportedLayouts(spaceUxType:)`, `objectTypesWithObjectsCreatedService.startSubscription(spaceUxType:)`
- Audit `SpaceView.uxType` and `SpaceUxType.supportsMultiChats` for remaining call sites; deprecate or remove
- Sibling Release-18 toggle removals: `fixChannelHomeBackNavigation` (IOS-6067), `fixAvatarTapFreeze` (IOS-5998)
