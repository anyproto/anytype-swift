# IOS-6067 Fix Channel Home Back Navigation

## Overview

After a user creates a channel and selects a homepage via the post-creation picker, the navigation path becomes `[SpaceHubNavigationItem, HomeWidgetData, EditorScreenData]`. Tapping Back returns the user to the widgets screen instead of Space Hub — frustrating and misleading.

The same root issue affects two other flows:
- Changing homepage via **Space Settings → Home**: path[1] stays as `HomeWidgetData`, so Back from the new home does not reflect the new homepage.
- Changing homepage via the **"Change Home"** action in the widgets overlay (long-press on Home widget): same stale `path[1]`.

This plan fixes all three flows behind a single feature toggle `fixChannelHomeBackNavigation`, on by default in debug and release, with strict scope guardrails to avoid affecting unrelated navigation. It also moves the pending-share invite retry out of `HomeWidgetsCoordinator` (which this fix will deallocate earlier) into `SpaceHubCoordinatorViewModel` so offline-created group channels with invited members do not regress.

**Linear issue**: IOS-6067
**Branch**: `ios-6067-the-home-widget-appears-only-after-you-reopen-the-space`

## Context (from discovery)

**Files involved:**
- `Anytype/Sources/PresentationLayer/Flows/SpaceHub/Support/PageNavigation.swift` — owns the navigation API between coordinators (`open`, `pop`, `replace`, etc.)
- `Anytype/Sources/PresentationLayer/Flows/SpaceHub/SpaceHubCoordinatorViewModel.swift` — owns `navigationPath`, the `pageNavigation` closures, the existing `homeObjectScreenData(...)` helper, and the `startHandle…` subscription pattern
- `Anytype/Sources/PresentationLayer/Flows/HomeWidgetsCoordinator/HomeWidgetsCoordinatorViewModel.swift` — post-creation picker wire-up at `onHomepagePickerFinished` (lines 52-56); also hosts the to-be-moved `startPendingShareRetryTask`
- `Anytype/Sources/PresentationLayer/Flows/HomeWidgetsCoordinator/HomeWidgetsCoordinatorView.swift` — mounts `HomepageSettingsPickerView` for the Change Home flow (line 89), attaches `.task { … startPendingShareRetryTask() }`
- `Anytype/Sources/PresentationLayer/SpaceSettings/HomePage/HomepageSettingsPickerView.swift` and `HomepageSettingsPickerViewModel.swift` — Settings → Home picker; today only calls `setHomepage` + sets `dismiss`
- `Anytype/Sources/PresentationLayer/Flows/SpaceSettings/SpaceSettingsCoordinatorView.swift` — mounts the settings picker (line 61); already injects `pageNavigation` via `@Environment` (line 19)
- `Anytype/Sources/PresentationLayer/Modules/HomepagePicker/HomepageCreatePickerViewModel.swift` — post-creation picker (calls `createHomepage`, which ends up calling `setHomepage`)
- `Anytype/Sources/PresentationLayer/Modules/HomeNavigationContainer/HomePath.swift` — mutating path helpers (`replaceLast`, `popToFirstOpened`, etc.)
- `AnyTypeTests/Home/HomePathTests.swift` — existing unit tests for `HomePath`
- `Anytype/Sources/PresentationLayer/TextEditor/Assembly/ScreenData.swift` — the `ScreenData` enum; new `homeSlotValue` extension helper lands here
- `Modules/AnytypeCore/AnytypeCore/Utils/FeatureFlags/FeatureDescription+Flags.swift` — feature flag definitions

**Key architectural facts (confirmed during brainstorming):**
- `navigationPath` is always `[SpaceHubNavigationItem, homeObject, …pushed items]`. The home slot at path[1] is set once by `prepareSpacePath` via `homeObjectScreenData`.
- `HomeWidgetsCoordinator` is only alive when path[1] = `HomeWidgetData`, or when the widgets overlay (`.fullScreenCover`) is open. For homepage = Page/Chat/Discussion, the respective editor/chat/discussion coordinator sits at path[1] and HomeWidgetsCoordinator is not on the nav stack.
- All three homepage-mutating flows (post-creation, Settings → Home, Change Home) ultimately call `HomepagePickerService.setHomepage(...)` on middleware.
- `HomepageSettingsPickerView` is presented from exactly two places: `SpaceSettingsCoordinatorView.swift:61` and `HomeWidgetsCoordinatorView.swift:89`. Both presenters already have `pageNavigation` in scope (one via `@Environment`, one via view-model ivar).
- `HomePathTests` exists and covers existing mutating methods (`push`, `pop`, `popToRoot`, `replaceLast`). Any new mutating method on `HomePath` should come with matching tests.
- `participantSpacesStorage.participantSpaceViewPublisher(spaceId:)` is deduped upstream via `.removeDuplicates`.

## Development Approach

- **Testing approach**: **Regular (code first, then manual QA)** for coordinator/navigation changes; **unit tests required** for the `HomePath.replaceHome(_:)` addition (project convention — existing `HomePathTests` covers the other mutating methods).
- Complete each task fully before moving to the next.
- Make small, focused changes.
- Feature flag OFF must preserve current behavior byte-for-byte (regression safety) for both the nav path fix and the pending-share retry move.
- Update this plan file immediately if scope changes during implementation.

## Testing Strategy

- **Unit tests**: `HomePath.replaceHome(_:)` — replace on valid path, no-op-on-equal, assertion guard when path has no home slot (added to existing `HomePathTests`).
- **No unit tests for coordinators**: coordinator-level navigation is not unit-tested in this repo; covered by manual QA.
- **Manual simulator QA** (required, see Task 7 scenarios): each scenario executed with flag ON; primary scenarios re-run with flag OFF to confirm zero regression.
- **Xcode build cadence**: do NOT build after every task — full Xcode builds are slow. Build at two explicit checkpoints only:
  - After Task 3 (once the new `PageNavigation.replaceHome` closure and `HomePath.replaceHome` are in place — catches struct-signature and API surface issues before call sites stack up).
  - After Task 6 (once all call sites + the pending-share retry move are wired — final integration compile).
  Tasks 1–2 produce small, self-contained files; rely on incremental compile via the IDE or `swift build` subset rather than a full Xcode build. If a compile error is suspected mid-task, trigger a build on demand — otherwise batch.
- Manual QA (Task 7) runs once at the end; no partial QA between tasks.

## Progress Tracking

- Mark completed items with `[x]` immediately when done.
- Add newly discovered tasks with ➕ prefix.
- Document issues/blockers with ⚠️ prefix.
- Update plan if implementation deviates from scope.

## Solution Overview

**Explicit output from each homepage-mutating picker, surfaced to SpaceHub via a new `PageNavigation.replaceHome(_:)` closure.**

There are exactly three places in the codebase that mutate homepage and require a navigation update:
1. Post-creation picker (`HomeWidgetsCoordinatorViewModel.onHomepagePickerFinished`).
2. Space Settings → Home picker (`HomepageSettingsPickerViewModel.onObjectSelected` / `onNoHomeSelected`).
3. Widgets overlay long-press → Change Home (reuses the same `HomepageSettingsPickerView` + view model as #2).

Each call site, behind the feature flag, calls `pageNavigation.replaceHome(newHomeData)` after `setHomepage` succeeds. The `newHomeData` is the concrete home-slot type (not the `ScreenData` enum box) — see the shared `ScreenData.homeSlotValue` helper below.

**Product rule: discussion cannot be a homepage.** The homepage picker today does not expose discussion layouts as options, so the call-site `homeSlotValue` mapping explicitly returns `nil` for `.discussion`. The SpaceHub guard also excludes `DiscussionCoordinatorData` — if a legacy space happens to have path[1] = `DiscussionCoordinatorData` when the user changes homepage via Settings, `replaceHome` no-ops live; the new homepage becomes visible on next space entry (when `prepareSpacePath` recomputes path[1] from the updated homepage value). This defers a very rare legacy-data case in exchange for a cleaner, symmetric guard.

`SpaceHub` implements the closure with defensive guards: path depth ≥ 2, not in the middle of a path transition (`!pathChanging`), and — critically — path[1] must already be a **replaceable** home-slot type: `HomeWidgetData`, `EditorScreenData`, or `ChatCoordinatorData`. If path[1] is `SpaceChatCoordinatorData` (1-on-1 root — homepage is immutable per IOS-6070) or `DiscussionCoordinatorData` (discussion can't be a homepage per product rules), the replace is a no-op and an `anytypeAssertionFailure` logs the non-fatal so future bypasses of the picker-level guards become discoverable in assertion logs.

The guard accepts the union of picker outputs: `EditorScreenData` and `ChatCoordinatorData` produced by `homeSlotValue`, plus `HomeWidgetData` constructed directly by `HomepageSettingsPickerViewModel.onNoHomeSelected` (there's no `ScreenData` case that maps to `HomeWidgetData`, so the "No home" row bypasses `homeSlotValue` by design).

**Rejected alternatives:**
- *Reactive observation in SpaceHub subscribing to `participantSpaceViewPublisher`* — rejected because it places responsibility at the wrong layer. SpaceHub is about navigation between spaces; intra-space homepage semantics shouldn't be its concern. It would also force cross-space leakage guards on every emission.
- *Module output from `HomeWidgetsCoordinator` subscription alone* — rejected due to a fatal gap: `HomeWidgetsCoordinator` is not alive when homepage is an object (path[1] = editor/chat/discussion). Changes via Settings → Home in those states would never be detected.
- *Expanding existing `PageNavigation.replace(EditorScreenData)`* — rejected because `replace` targets the last path element, not path[1], and is typed to `EditorScreenData` while the home slot may be any of four types.

**1-on-1 channels cannot change homepage** (IOS-6070, merged earlier on this branch's base). The post-creation picker is suppressed for 1-on-1 via `!spaceView.isOneToOne` at `HomeWidgetsCoordinatorViewModel.swift:46`, and Settings → Home is hidden/disabled in 1-on-1 settings. Therefore none of the three picker call sites ever fires for a 1-on-1 space. The SpaceHub guard **excludes** `SpaceChatCoordinatorData` from the replaceable set; if a picker somehow did fire and path[1] were `SpaceChatCoordinatorData`, `replaceHome` no-ops (fail-safe).

**Part 2 — moving the pending-share retry task to SpaceHub** is required as a direct consequence of Part 1. Today, `HomeWidgetsCoordinatorViewModel.startPendingShareRetryTask` only runs while `HomeWidgetsCoordinator` is alive. Part 1 deallocates that coordinator earlier (immediately after homepage is set), so an offline-created Group channel with pending invite shares would regress — the retry subscription would die before the network returns. Moving the retry up to `SpaceHubCoordinatorViewModel`, scoped to active space via the child-`Task`-per-active-space pattern, fixes both the regression and a latent bug (1-on-1 and object-homepage channels never ran the retry because `HomeWidgetsCoordinator` was never alive at path[1]).

**Why this fits the existing architecture:**
- `SpaceHub` already owns active-space scope via `startHandleWorkspaceInfo` / `handleActiveSpace`. Adding one more `startHandle…` subscription matches the local pattern.
- `PageNavigation` already bridges picker-level events to SpaceHub-level path mutations (`open`, `replace`, `pushHome`); adding `replaceHome` follows the same convention.
- No subscription is added for homepage itself — pickers are the source of truth and they report explicitly.

## Technical Details

### Feature flag
- Name: `fixChannelHomeBackNavigation`
- File: `Modules/AnytypeCore/AnytypeCore/Utils/FeatureFlags/FeatureDescription+Flags.swift`
- Title: `"Fix channel home back navigation - IOS-6067"`
- Category: `.productFeature(author: "k@anytype.io", targetRelease: "18")`
- `defaultValue: true` (no `debugValue` override — same in debug and release)
- Regenerate helper: `make generate`
- Gates BOTH Part 1 (nav fix) and Part 2 (pending-share retry move).

### New `HomePath` API

The earlier draft exposed a generic `replaceAt(_:with:)` that took an index. That leaked the "home is at index 1" invariant into every call site. Replace the design with two domain-specific members on `HomePath` (same internal access level as `replaceLast`, `popToFirstOpened`, etc. — not private) that encapsulate the position knowledge:

```swift
extension HomePath {
    // Home slot is at index 1 (index 0 is SpaceHubNavigationItem).
    // Nil when path is rootless or has no home committed yet.
    var currentHome: AnyHashable? {
        path[safe: 1]
    }

    mutating func replaceHome(_ newHome: AnyHashable) {
        guard path.count >= 2 else {
            anytypeAssertionFailure("Path has no home slot", info: ["count": "\(path.count)"])
            return
        }
        guard path[1] != newHome else { return }
        path[1] = newHome
    }
}
```

This way `SpaceHubCoordinatorViewModel` reads `navigationPath.currentHome` and calls `navigationPath.replaceHome(newData)` — neither site hand-codes an index. If the "home is at index 1" invariant ever changes (e.g., multi-tab layouts), the fix is localized to `HomePath`.

Callers may still reach into `path` directly via existing code for other navigation patterns; we only add domain-specific helpers for the home slot — no renaming or removal of existing `HomePath` members.

### New `PageNavigation` closure

```swift
struct PageNavigation {
    let open: (ScreenData) -> Void
    let pushHome: () -> Void
    let pop: () -> Void
    let popToFirstInSpace: () -> Void
    let replace: (EditorScreenData) -> Void
    let replaceHome: (AnyHashable) -> Void   // ← new
}

extension EnvironmentValues {
    @Entry var pageNavigation = PageNavigation(
        open: { _ in }, pushHome: { }, pop: { }, popToFirstInSpace: {}, replace: { _ in },
        replaceHome: { _ in }
    )
}
```

**Aside — `pushHome` appears unused.** Audit found zero call sites (only the struct declaration and the default env no-op). `replaceHome` does NOT replace `pushHome` semantically — they mean different things (push onto stack vs. swap the home slot). Cleanup of `pushHome` is **out of scope** for this bug fix; flag for a follow-up. Leaving it in place keeps the API surface unchanged for unrelated reviewers.

### Shared `ScreenData.homeSlotValue` helper

`homeObjectScreenData(spaceId:spaceUxType:)` at `SpaceHubCoordinatorViewModel.swift:303-335` unwraps `ScreenData` to its concrete home-slot associated value: `.editor → EditorScreenData`, `.chat → ChatCoordinatorData` (plus `.discussion` for legacy data — see below). It also returns `HomeWidgetData` and `SpaceChatCoordinatorData` for the non-object cases. The picker call sites (Tasks 4 and 5) need to perform the same unwrap so they pass the correct concrete type — passing the raw `ScreenData` enum into `replaceHome` would fail every `is` check in SpaceHub's guard and silently no-op.

Add a small helper next to `ScreenData` so the mapping lives in one place. **This helper is the source of truth for "can this screen be a homepage?"** — discussion layouts return `nil` because the product does not allow discussion as a homepage (the picker UI already hides discussion options; this is the code-level enforcement):

```swift
extension ScreenData {
    // Returns the concrete home-slot value if this screen data represents a
    // *selectable* homepage via the pickers. Discussion is intentionally excluded
    // per product rules — the picker UI already hides it; this is the code-level
    // guard in case a future change exposes it.
    var homeSlotValue: AnyHashable? {
        switch self {
        case .editor(let data):  return data
        case .chat(let data):    return data
        default:                 return nil
        }
    }
}
```

Note: `homeObjectScreenData` still handles `.discussion` at the read side (line 326-327) to remain compatible with any pre-existing discussion homepages in stored data. We do not refactor `homeObjectScreenData` to use this helper — scope is kept minimal. The helper is used only by the new picker call sites.

### `SpaceHub` implementation of `replaceHome`

Uses the new `HomePath.currentHome` accessor and `HomePath.replaceHome(_:)` mutator — no hand-coded index literals on the SpaceHub side. SpaceHub owns the **type policy** (which types count as valid home slots); `HomePath` owns the **position policy** (where the home lives in the path).

```swift
replaceHome: { [weak self] newData in
    guard let self, FeatureFlags.fixChannelHomeBackNavigation else { return }
    guard !pathChanging, let current = navigationPath.currentHome else { return }
    let isReplaceableHomeSlot =
        current is HomeWidgetData ||
        current is EditorScreenData ||
        current is ChatCoordinatorData
    guard isReplaceableHomeSlot else {
        anytypeAssertionFailure(
            "replaceHome called with non-replaceable home slot",
            info: ["currentType": "\(type(of: current))"]
        )
        return
    }
    guard current != newData else { return }
    navigationPath.replaceHome(newData)
}
```

Three **replaceable** types: `HomeWidgetData` (no-home state), `EditorScreenData` (page homepage), `ChatCoordinatorData` (chat-object homepage). Explicitly excluded:
- `SpaceChatCoordinatorData` — the 1-on-1 space root; homepage is immutable for 1-on-1 channels (IOS-6070). If path[1] is this, picker guards upstream were bypassed — log non-fatal for diagnosability.
- `DiscussionCoordinatorData` — discussion cannot be a homepage per product rules. If legacy data lands here, the swap is deferred until the next space entry (when `prepareSpacePath` recomputes path[1] from the fresh homepage value). Same non-fatal log.

The guard and picker output are aligned: `HomeWidgetData` + `EditorScreenData` + `ChatCoordinatorData` are the only types the picker can produce *and* the only ones replaced in place. The `anytypeAssertionFailure` surfaces silent no-ops in assertion logs without affecting users.

The flag check lives inside the closure so the OFF path is a no-op while the old code (the `pageNavigation?.open(...)` call in `onHomepagePickerFinished`, which is only gated OFF→ON) still runs unchanged.

### `HomepageSettingsPickerViewModel` output
Add a new output closure, invoked after `setHomepage` succeeds:
```swift
private let onHomepageSet: ((AnyHashable) -> Void)?

init(spaceId: String, onHomepageSet: ((AnyHashable) -> Void)? = nil) {
    self.spaceId = spaceId
    self.onHomepageSet = onHomepageSet
    // … existing init
}

func onNoHomeSelected() async throws {
    try await homepagePickerService.setHomepage(spaceId: spaceId, homepage: .widgets)
    AnytypeAnalytics.instance().logChangeSpaceDashboard()
    onHomepageSet?(HomeWidgetData(spaceId: spaceId))
    dismiss = true
}

func onObjectSelected(_ details: ObjectDetails) async throws {
    try await homepagePickerService.setHomepage(spaceId: spaceId, homepage: .object(objectId: details.id))
    AnytypeAnalytics.instance().logChangeSpaceDashboard()
    if let homeData = details.screenData().homeSlotValue {
        onHomepageSet?(homeData)
    }
    dismiss = true
}
```
The `homeSlotValue` helper (above) unwraps `ScreenData` to the concrete `EditorScreenData` or `ChatCoordinatorData` only. Discussion and all other layouts return `nil` — the picker already prevents selection of non-homepage-eligible objects, so the optional-unwrap is defensive.

Both presenters wire the callback:
- `SpaceSettingsCoordinatorView.swift` — already has `@Environment(\.pageNavigation)`; pass `onHomepageSet: { pageNavigation.replaceHome($0) }` gated behind `FeatureFlags.fixChannelHomeBackNavigation` when constructing the picker.
- `HomeWidgetsCoordinatorView.swift` — already forwards `pageNavigation` to its view model; same wiring at the sheet site.

### `SpaceHub` pending-share retry (replacing the HomeWidgets one)

Sketch — `SpaceHubCoordinatorViewModel` is already `@MainActor`, no extra hop is needed inside the inner loop:
```swift
private func startHandlePendingShareRetry() async {
    guard FeatureFlags.fixChannelHomeBackNavigation else { return }
    var innerTask: Task<Void, Never>?
    for await info in activeSpaceManager.workspaceInfoStream {
        innerTask?.cancel()
        let spaceId = info?.accountSpaceId ?? ""
        guard !spaceId.isEmpty,
              pendingShareStorage.pendingState(for: spaceId) != nil else {
            innerTask = nil
            continue
        }
        innerTask = Task { [weak self] in
            guard let self else { return }
            for await participantSpaceView in participantSpacesStorage
                .participantSpaceViewPublisher(spaceId: spaceId).values {
                guard !Task.isCancelled else { return }
                guard pendingShareStorage.pendingState(for: spaceId) != nil else { return }
                if participantSpaceView.spaceView.isActive {
                    await pendingShareService.retryIfNeeded(spaceId: spaceId)
                }
            }
        }
    }
    innerTask?.cancel()
}
```
Wire into `startSubscriptions()` via `async let shareRetrySub: () = startHandlePendingShareRetry()`. The outer `for await info` advances on active-space change; the inner task is cancelled and replaced so no subscription leaks across spaces.

### Post-creation `Not now` flow
`HomepageCreatePickerViewModel.onNotNow` sets homepage to `.widgets`. Current state: path[1] is already `HomeWidgetData`, picker dismisses, user stays on widgets screen. No `replaceHome` call needed — the home slot is already correct.

## What Goes Where

- **Implementation Steps**: flag, helpers, coordinator wiring, pending-share retry move, unit tests for `HomePath`, manual QA, compilation.
- **Post-Completion**: QA scenarios on simulator with both flag states, Xcode build verification by the user, Linear comment + PR creation.

## Implementation Steps

### Task 1: Add feature flag `fixChannelHomeBackNavigation`

**Files:**
- Modify: `Modules/AnytypeCore/AnytypeCore/Utils/FeatureFlags/FeatureDescription+Flags.swift`
- Regenerated: `Modules/AnytypeCore/AnytypeCore/Generated/FeatureFlags+Flags.swift`

- [x] Add `fixChannelHomeBackNavigation` entry next to `createChannelFlow` in `FeatureDescription+Flags.swift` (author `k@anytype.io`, targetRelease `18`, `defaultValue: true`, no `debugValue`).
- [x] Run `make generate` to regenerate `FeatureFlags+Flags.swift`.
- [x] Compile check: ensure `FeatureFlags.fixChannelHomeBackNavigation` accessor is callable.
- [x] No unit tests — flag definitions are not unit-tested in this repo.

### Task 2: Add `currentHome` / `replaceHome(_:)` to `HomePath` with unit tests

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Modules/HomeNavigationContainer/HomePath.swift`
- Modify: `AnyTypeTests/Home/HomePathTests.swift`

- [x] Add `var currentHome: AnyHashable?` computed property returning `path[safe: 1]`. Same internal access level as existing members.
- [x] Add `mutating func replaceHome(_ newHome: AnyHashable)` with `path.count >= 2` guard via `anytypeAssertionFailure` (match style of `replaceLast`) and no-op when `path[1] == newHome`.
- [x] Keep all existing methods untouched.
- [x] Add test `testCurrentHomeReturnsIndexOne` — seed a 2-element path; verify `currentHome == path[1]`.
- [x] Add test `testCurrentHomeNilWhenPathEmpty` and `testCurrentHomeNilWhenOnlyRoot` — single-element / empty paths return nil.
- [x] Add test `testReplaceHomeOnValidPath` — replace on a 2-element path; verify path[1] updated and path[0] unchanged. Extend test with a 3-element path to confirm path[2] is NOT touched.
- [x] Add test `testReplaceHomeSameValueNoOp` — replace with equal value; verify path unchanged.
- [x] Add test `testReplaceHomeOnRootlessPath` — call `replaceHome` on `[root]` (no home yet) or empty path; verify path unchanged (assertion is non-fatal in test builds).
- [x] Run `HomePathTests` — must pass before next task.

### Task 3: Add `replaceHome` to `PageNavigation` and implement in `SpaceHubCoordinatorViewModel`

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Flows/SpaceHub/Support/PageNavigation.swift`
- Modify: `Anytype/Sources/PresentationLayer/Flows/SpaceHub/SpaceHubCoordinatorViewModel.swift`

- [x] Add `let replaceHome: (AnyHashable) -> Void` closure to `PageNavigation` struct. Update the default `EnvironmentValues` initializer with `replaceHome: { _ in }`.
- [x] Implement `replaceHome` in `SpaceHubCoordinatorViewModel.pageNavigation` with flag check inside the closure: guard `FeatureFlags.fixChannelHomeBackNavigation`, `!pathChanging`, bind `current = navigationPath.currentHome`, verify `current` is one of the three **replaceable** home-slot types (`HomeWidgetData` / `EditorScreenData` / `ChatCoordinatorData`), and `current != newData`. Call `navigationPath.replaceHome(newData)`. `SpaceChatCoordinatorData` and `DiscussionCoordinatorData` are intentionally excluded — see Technical Details for rationale.
- [x] Audit every `PageNavigation(...)` constructor invocation in the codebase (`rg "PageNavigation\("`) and add the `replaceHome:` argument — missing initializer argument will hard-fail the build. Known sites: `SpaceHubCoordinatorViewModel.pageNavigation`, `ChatCreateObjectCoordinatorViewModel` (use `{ _ in }` no-op), the default env `@Entry` declaration in `PageNavigation.swift`.
- [x] Compile check (Xcode build checkpoint #1 per Testing Strategy).
- [x] No unit tests for `SpaceHubCoordinatorViewModel` — not unit-tested in this repo.

### Task 4: Wire post-creation picker to `replaceHome`

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Flows/HomeWidgetsCoordinator/HomeWidgetsCoordinatorViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/TextEditor/Assembly/ScreenData.swift` (add `homeSlotValue` helper if not added in Task 3)

- [x] Add the `ScreenData.homeSlotValue` extension helper in `ScreenData.swift` (see Technical Details — `.editor` / `.chat` only; discussion returns `nil`).
- [x] In `onHomepagePickerFinished`, branch on the flag. ON: unwrap `details.screenData().homeSlotValue`; if non-nil, call `pageNavigation?.replaceHome(homeData)`. OFF: keep current `pageNavigation?.open(details.screenData())`.
- [x] Do NOT add a `// when flag is on …` comment — per CLAUDE.md, the WHAT is obvious from the flag name.
- [x] No compile/build checkpoint here — batch with Task 5 and 6.

### Task 5: Add `onHomepageSet` output on `HomepageSettingsPickerViewModel` and plumb through both presenters

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/SpaceSettings/HomePage/HomepageSettingsPickerViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/SpaceSettings/HomePage/HomepageSettingsPickerView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Flows/SpaceSettings/SpaceSettingsCoordinatorView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Flows/HomeWidgetsCoordinator/HomeWidgetsCoordinatorView.swift`

- [x] Add optional closure property `onHomepageSet: ((AnyHashable) -> Void)?` to `HomepageSettingsPickerViewModel`; accept via init.
- [x] Call `onHomepageSet?(HomeWidgetData(spaceId: spaceId))` in `onNoHomeSelected` after `setHomepage` succeeds.
- [x] Call `onHomepageSet?(details.screenData().homeSlotValue)` in `onObjectSelected` — safely via optional bind; skip when `homeSlotValue` is `nil` (defensive, shouldn't happen for valid homepage selections). Uses the `ScreenData.homeSlotValue` helper added alongside Task 3/4.
- [x] Thread the closure through `HomepageSettingsPickerView`'s init. Note: `HomepageSettingsPickerView` currently constructs its view model internally at the top of its body (verify exact site in the file). Extend the view's init to accept `onHomepageSet:` and forward it to the VM constructor so the closure flows end-to-end.
- [x] In `SpaceSettingsCoordinatorView.swift:61`, pass `onHomepageSet: { pageNavigation.replaceHome($0) }` when mounting the picker, gated behind `FeatureFlags.fixChannelHomeBackNavigation` (pass `nil` when flag is OFF so behavior is identical to today).
- [x] In `HomeWidgetsCoordinatorView.swift:89` (Change Home sheet), same wiring — the view has access to `pageNavigation` via `@Environment` (already used elsewhere in this file); pass the flag-gated closure identically.
- [x] No compile/build checkpoint here — batch with Task 6.

### Task 6: Move pending-share retry from `HomeWidgetsCoordinator` to `SpaceHub`

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Flows/SpaceHub/SpaceHubCoordinatorViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Flows/HomeWidgetsCoordinator/HomeWidgetsCoordinatorViewModel.swift`
- Modify: `Anytype/Sources/PresentationLayer/Flows/HomeWidgetsCoordinator/HomeWidgetsCoordinatorView.swift`

- [ ] Add `@Injected(\.pendingShareService)` and `@Injected(\.pendingShareStorage)` to `SpaceHubCoordinatorViewModel` if not already present.
- [ ] Add private `startHandlePendingShareRetry()` using the outer-loop-on-`activeSpaceManager.workspaceInfoStream` + inner-`Task`-per-active-space pattern shown in Technical Details. Gate with `FeatureFlags.fixChannelHomeBackNavigation`. Cancel `innerTask` on every outer advance and after the outer loop exits.
- [ ] Wire into `startSubscriptions()` as `async let shareRetrySub: () = startHandlePendingShareRetry()`.
- [ ] Gate the old call site with `!FeatureFlags.fixChannelHomeBackNavigation` so exactly one retry loop is active at any time. In `HomeWidgetsCoordinatorView`, wrap the modifier as: `.task { if !FeatureFlags.fixChannelHomeBackNavigation { await model.startPendingShareRetryTask() } }` (or equivalent). This avoids two concurrent subscriptions firing `pendingShareService.retryIfNeeded` during the brief window HomeWidgetsCoordinator is alive with flag ON — `retryIfNeeded` is not verified idempotent for this change, and deterministic single-source behavior is safer than relying on idempotency.
- [ ] Keep `startPendingShareRetryTask` method in `HomeWidgetsCoordinatorViewModel` (do not delete) — still used when flag is OFF.
- [ ] Compile check (Xcode build checkpoint #2 per Testing Strategy — full build after Tasks 4, 5, and 6 are all wired).

### Task 7: Manual simulator QA

Run on iOS 26 simulator. All scenarios with flag ON; Scenarios 1 and 5 re-run with flag OFF for regression safety.

**Scenario 1 — Post-creation picker, Page:**
- [ ] Create Group channel → picker appears → select Page → Continue.
- [ ] Page opens. Tap Back. Expected: land on Space Hub (not widgets).
- [ ] Watch sheet-dismiss animation for any "flash of widgets" between dismiss and home swap. Record if visible.
- [ ] Re-run with flag OFF: current buggy behavior (Back lands on widgets) — confirms zero regression when flag is OFF.

**Scenario 2 — Post-creation Not now → Settings → Home:**
- [ ] Create Group channel → picker → Not now → lands on widgets.
- [ ] Open Settings → Home → pick Collection → dismiss picker + Settings.
- [ ] Expected: user lands on Collection (new homepage); Back → Space Hub.

**Scenario 3 — Change Home from widgets overlay:**
- [ ] Channel with Page homepage. Tap channel header to open widgets overlay.
- [ ] Long-press Home widget → Change Home → pick Chat.
- [ ] Expected: overlay dismisses, user lands on Chat; Back → Space Hub.

**Scenario 4 — 1-on-1 space:**
- [ ] Enter a 1-on-1 space (homepage = chat, post-creation picker suppressed).
- [ ] Verify chat remains at path[1]; nothing about nav feels different with flag ON.

**Scenario 5 — Deep navigation regression:**
- [ ] Open homepage → navigate into a sub-page → sub-sub-page.
- [ ] Tap Back multiple times: must pop one item per tap; never skip.
- [ ] Re-run with flag OFF to confirm identical behavior.

**Scenario 6 — Offline pending-share retry (Part 2 fix):**
- [ ] Go offline. Create Group channel with invited members.
- [ ] In the offline state, change homepage to Page (triggers Part 1 path swap that deallocates HomeWidgetsCoordinator).
- [ ] Go online. Verify pending invite shares are retried and members are added without having to navigate back to the widgets screen.

**Scenario 7 — Path[1] guard:**
- [ ] With flag ON, trigger a `replaceHome` call while path has been manipulated artificially (e.g., during a rapid nav push). Not easily reproducible — treat as code-review confirmation that the type guard in SpaceHub short-circuits unrecognized path[1]. No simulator test required unless a reliable repro exists.

**Scenario 8 — Legacy discussion homepage (defer check):**
- [ ] If a QA account exists with a space whose homepage is discussion (legacy state — not selectable via today's picker), change homepage via Settings → Home to Page and observe behavior.
- [ ] Expected: Settings dismisses; homepage *value* is updated in middleware but the nav stack still shows the discussion at path[1] (live swap skipped, `anytypeAssertionFailure` logged non-fatal).
- [ ] Exit the space, re-enter: Expected path[1] = new Page editor.
- [ ] Document the observed defer in the PR description so reviewers and QA know this is intentional. If no legacy space exists, skip this scenario — the trigger is rare enough to not block ship.

### Task 8: Compile, final review, close out

**Files:**
- Affected files across the branch; no new files in this task.

- [ ] Full project compile clean.
- [ ] Report compilation status to user (per CLAUDE.md — user verifies in Xcode with warm caches).
- [ ] Self-review against TASTE_INVARIANTS.md (no dead code, no unused comments, no backwards-compat stubs for code we're removing, feature flag not leaking into public APIs).
- [ ] Move this plan to `docs/plans/completed/` when all above boxes are checked and user confirms build + QA.

## Post-Completion

**Manual verification (required before PR):**
- All Task 7 scenarios pass on iOS 26 simulator with flag ON.
- Scenarios 1 and 5 reproduce correctly with flag OFF (regression safety).
- Scenario 6 confirms the pending-share retry move behaves correctly end-to-end.

**External system updates:**
- Update Linear IOS-6067 with a comment summarizing the fix and linking the PR.
- PR target branch: `develop` (per CLAUDE.md).
- PR format: `## Summary` + 1-3 bullet points (no test plan needed).

**Scope guardrails (explicit do-NOTs):**
- Do NOT modify existing `open`, `pop`, `popToFirstInSpace`, `replace`, or `pushHome` closures on `PageNavigation`.
- Do NOT change behavior of `onHomeObjectSelected`, `onObjectSelected`, or overlay dismissal logic.
- Do NOT subscribe to homepage changes inside `SpaceHub` (the rejected approach).
- `SpaceHub`'s `replaceHome` closure must always type-guard `navigationPath.currentHome` before mutating; the position invariant ("home is at index 1") is encapsulated inside `HomePath.replaceHome`/`currentHome` — do NOT hand-code index literals anywhere else.
- Feature flag OFF must preserve byte-for-byte current behavior for both the nav path and the pending-share retry paths.
