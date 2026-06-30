# Implementation Plan — Membership Activation-Code Flow (IOS-6260)

## Context

Desktop (anytype-ts) ships a membership code-redemption flow; iOS has none. This is **iteration 1**:
add the business logic + new redemption flow on top of the **existing** membership UI. A later
iteration redesigns the membership screen (out of scope here).

A user with an activation code taps an entry on the Membership screen, enters the code in a modal,
and the app runs a two-step middleware sequence (`Membership.CodeGetInfo` → `Membership.CodeRedeem`)
to redeem it. On success the membership state refreshes and the existing confetti success screen
shows the new tier. A deep link (`code` param, used returning from Stripe) opens the same modal
pre-filled (user taps Activate — desktop parity, no auto-submit).

Full requirements + locked decisions live in `SPEC.md` (repo root). This plan is the executable
breakdown. All product decisions were settled in the brainstorm interview — see SPEC §2.

Key simplifications discovered during exploration:
- The code modal maps onto the existing **`BottomAlertView`** (DesignKit) — same component the
  success screen uses — with `FramedTextField` in its `bodyView` and one `BottomAlertButton`.
- RPC error types **already conform to `LocalizedError`** (generated `Error+Localization.swift`,
  `LocalizableError` table). Error handling = `error.localizedDescription`, mirroring
  `MembershipNameValidationViewModel`. No hand-rolled error mapping.
- Name selection is **not** part of this flow — `nsName` sent empty (desktop parity). The
  team-code / tier-1000 "treat as free" risk is avoided by reading the post-redeem
  `MembershipStatus.tier` for the success screen, and because iOS already maps `1000 → .seatBasedTier`.

---

## Step 1 — Service layer (RPC wrappers)

**File:** `Modules/Services/Sources/Services/Membership/MembershipService.swift`

Add to `MembershipServiceProtocol` + `MembershipService`, mirroring `validateName` (line 91-97):

```swift
// returns the tier the code targets (informational); errors propagate as LocalizedError
func codeGetInfo(code: String) async throws -> MembershipTierType?

func codeRedeem(code: String) async throws
```

Impl:
```swift
public func codeGetInfo(code: String) async throws -> MembershipTierType? {
    let response = try await ClientCommands.membershipCodeGetInfo(.with {
        $0.code = code
    }).invoke()
    return MembershipTierType(intId: response.requestedTier)
}

public func codeRedeem(code: String) async throws {
    try await ClientCommands.membershipCodeRedeem(.with {
        $0.code = code
        $0.nsName = ""
        $0.nsNameType = .anyName
    }).invoke()
}
```

- `.invoke()` throws the typed `CodeGetInfo.Response.Error` / `CodeRedeem.Response.Error` on a
  non-null error code; both conform to `LocalizedError` already — let them propagate.
- No `ignoreLogErrors` initially (open item: decide which codes to silence in logs).
- DI: no change — `MembershipService` is registered via `ServicesDI.swift:125` factory.

**Generated symbols (confirmed):** `ClientCommands.membershipCodeGetInfo` / `membershipCodeRedeem`
(`service+invocation.swift:2877`, `:2887`); requests expose `code` / `nsName` / `nsNameType`;
responses expose `requestedTier`.

---

## Step 2 — Code-activation module (View + ViewModel)

**New folder:** `Anytype/Sources/PresentationLayer/Modules/Membership/CodeActivation/`
- `MembershipCodeActivationView.swift`
- `MembershipCodeActivationViewModel.swift`

**ViewModel** (`@MainActor @Observable`), pattern from `MembershipNameValidationViewModel`:
- `@Injected(\.membershipService)`.
- State: `var code: String = ""`, `var errorText: String? = nil`. (Loading is owned by the
  button's async action — no `isLoading` flag needed.)
- Init takes `initialCode: String?`, `route: String`, and closures: `onRedeemed: (MembershipTier?) async -> Void`, `onDismiss: () -> Void`.
- `activate()`:
  ```swift
  func activate() async {
      errorText = nil
      AnytypeAnalytics.instance().logClickMembershipCode()
      do {
          _ = try await membershipService.codeGetInfo(code: code)   // validates; throws on error
          try await membershipService.codeRedeem(code: code)        // its OWN error checked (not desktop bug)
          await onRedeemed(nil)                                      // coordinator refreshes status + shows success
      } catch {
          errorText = error.localizedDescription
      }
  }
  ```
- On appear: `logScreenMembershipCode(route:)`. If `initialCode` present → set `code` and auto-call `activate()` once.

**View** — build on `BottomAlertView` (full init with `headerView`/`bodyView`/`buttons`):
```swift
BottomAlertView(
    title: Loc.Membership.Code.title,
    message: Loc.Membership.Code.subtitle,
    headerView: { Image(asset: <pin-code illustration>) },   // see Open items
    bodyView: {
        VStack(spacing: 6) {
            FramedTextField(placeholder: Loc.Membership.Code.placeholder, text: $model.code)
            if let errorText = model.errorText {
                AnytypeText(errorText, style: .relation2Regular)
                    .foregroundStyle(Color.Dark.red)
            }
        }
    },
    buttons: {
        BottomAlertButton(
            text: Loc.Membership.Code.activate,
            style: .primary,
            disable: model.code.isEmpty
        ) { await model.activate() }
    }
)
```

Reused components (APIs confirmed):
- `BottomAlertView` — `Modules/DesignKit/.../BottomAlert/BottomAlertView.swift` (full init w/ body slot).
- `BottomAlertButton(text:style:disable:action:)` — async action + built-in in-flight loading via `AsyncStandardButton`.
- `FramedTextField` — `Anytype/Sources/PresentationLayer/Common/SwiftUI/RoundedTextFieldWithTitle/FramedTextField.swift`.
- Inline error styling copied from `MembershipNameValidationView:52` (`.relation2Regular` / `Color.Dark.red`).

---

## Step 3 — Coordinator wiring + entry point

**File:** `Anytype/Sources/PresentationLayer/Flows/MembersipCoordinator/MembershipCoordinatorModel.swift`
- Add state: `var showCodeActivation: MembershipCodeActivationData? = nil` (Identifiable struct carrying `route` + optional prefilled `code`).
- Add `init(initialTierId:initialCode:)` — if `initialCode != nil`, set `showCodeActivation` with `route = "Stripe"` so the modal auto-opens on launch.
- Add handler reusing the existing success path:
  ```swift
  func onCodeRedeemed() async {
      showCodeActivation = nil
      await loadStatusAndTiers(noCache: true)              // refresh
      if let tier = membershipStatusStorage.currentStatus.tier {
          AnytypeAnalytics.instance().logActivateMembershipCode(tier: tier)
          showSuccessScreen(tier: tier)                    // existing confetti path (line 71)
      }
  }
  ```
  (`membershipStatusStorage` is already injected at model line ~21; `MembershipStatus.tier` is a
  resolved `MembershipTier?`.)
- Add a callback to open the modal from the membership screen: `func onActivateCodeTap()` → sets
  `showCodeActivation` with `route = "ScreenSettingsMembership"`.

**File:** `MembershipCoordinator.swift`
- Add presentation alongside the existing sheets (line 31-36), matching the success screen's
  `.anytypeSheet(item:)`:
  ```swift
  .anytypeSheet(item: $model.showCodeActivation) { data in
      MembershipCodeActivationView(data: data, model: model)
  }
  ```

**Entry point** — `Anytype/Sources/PresentationLayer/Modules/Membership/InitialScreen/MembershipModuleView.swift`
- Add an "Activate Code" row/button near the legal / restore-purchases section, calling
  `onActivateCodeTap()` (thread the callback from the coordinator like the existing `onTierTap`).

---

## Step 4 — Deep link (`code` param)

- `Modules/DeepLinks/Sources/DeepLinks/DeepLink.swift:10` — extend:
  `case membership(tierId: Int?, code: String?)` (tierId becomes optional; update existing
  construction sites).
- `DeepLinkParser.swift:80` — parse `code` query item; allow tier-less membership links:
  ```swift
  case LinkPaths.membership:
      let tier = queryItems.intValue(key: "tier")
      let code = queryItems.stringValue(key: "code")
      guard tier != nil || code != nil else { return nil }
      return .membership(tierId: tier, code: code)
  ```
  Also update the URL-builder branch (`:144`) to emit `code`.
- `SpaceHubCoordinatorViewModel.swift:585` — replace `membershipTierId: IntIdentifiable?` with an
  Identifiable struct carrying optional `tierId` + `code`; set it in the `.membership` case.
- `SpaceHubCoordinatorView.swift:33` — present `MembershipCoordinator(initialTierId:initialCode:)`
  from that struct.

> Open: confirm the exact deep-link host/path the Stripe-return uses for the `code` param.

---

## Step 5 — Analytics

**File:** `Anytype/Sources/Analytics/AnytypeAnalytics/AnytypeAnalytics+Events.swift` (near line 1225),
mirroring `logScreenMembership` / `logClickMembership`:
```swift
func logScreenMembershipCode(route: String) {
    logEvent("ScreenMembershipCode", withEventProperties: [AnalyticsEventsPropertiesKey.route: route])
}
func logClickMembershipCode() { logEvent("ClickMembershipCode") }
func logActivateMembershipCode(tier: MembershipTier) {
    logEvent("ActivateMembershipCode", withEventProperties: [AnalyticsEventsPropertiesKey.name: tier.name])
}
```
- Route values: `"Stripe"` (deep link) and `"ScreenSettingsMembership"` (manual) — strings already
  used elsewhere; reuse rather than adding a new enum unless one fits. Confirm
  `AnalyticsEventsPropertiesKey.route` exists; add if missing.

---

## Step 6 — Localization

3-file `.xcstrings` workflow, then `make generate`.

- New UI keys in `Modules/Loc/Sources/Loc/Resources/Workspace.xcstrings` under `Membership.Code.*`:
  `title` ("Activate Your Code"), `subtitle`, `placeholder` ("Paste activation code…"),
  `activate` ("Activate"), and the entry-row label (e.g. `Membership.Code.entry`).
- Error wording: the RPC error localization keys already exist in
  `LocalizableError.xcstrings` (`Membership.CodeGetInfo.*`, `Membership.CodeRedeem.*` via
  `Error+Localization.swift`). **Verify the wording matches desktop** (SPEC §5 table); fill/adjust
  any empty strings. Do **not** add a parallel mapping.
- Run `make generate` to regenerate `Loc.*` accessors.

---

## Verification

1. **Build** — user verifies in Xcode (per project convention).
2. **Manual happy path** — Membership screen → "Activate Code" → enter a valid paid code → button
   shows loading → modal dismisses → confetti success screen shows the correct tier → membership
   state updated without manual refresh.
3. **Team code (tier 1000)** — redeem a team code → success screen shows the seat-based/real tier,
   not the free-membership state.
4. **Errors** — invalid code → inline error under the input, code stays populated, retry works.
   Verify each `CodeGetInfo` error code surfaces a sensible localized message.
5. **Deep link** — open the membership deep link with a `code` param → modal opens pre-filled →
   user taps Activate → success.
6. **Analytics** — confirm `ScreenMembershipCode` (route Stripe vs ScreenSettingsMembership),
   `ClickMembershipCode`, `ActivateMembershipCode` fire (debug logger / Amplitude).

---

## Open items (non-blocking; resolve during impl)

1. Exact deep-link host/path carrying `code` (confirm vs desktop/Stripe).
2. Header icon: the Figma "Settings / Pin Code" 56×56 alert illustration — confirm the
   `ImageAsset` exists or export/add it.
3. Inline-error exact position (inside card under input vs under button) — confirm vs design.
4. Whether to add any error codes to `ignoreLogErrors`.
5. `AnalyticsEventsPropertiesKey.route` existence; add if missing.

## Out of scope (iteration 1)
Membership screen redesign; `.any` name collection (sent empty); post-redeem survey; clipboard
auto-detect; feature flag (ships unflagged).
