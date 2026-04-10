# IOS-6027: Remove auto-copy of recovery phrase

## Overview
Recovery phrase is automatically copied to clipboard whenever it's revealed — both during onboarding and in settings. This is a potential security leak. The fix decouples reveal from copy so the phrase is only copied by explicit user tap on the visible phrase (or a dedicated copy button in settings).

## Context
- **Linear issue**: IOS-6027
- **Parent**: IOS-5758 (Release 18 | Basic quality)
- **Branch**: `ios-6027-do-not-automatically-copy-recovery-phrase-during-onboarding`

### Files involved
| File | Role |
|------|------|
| `Anytype/Sources/PresentationLayer/Auth/Join/Shared/KeyPhraseView/KeyPhraseViewModel.swift` | Onboarding key phrase logic |
| `Anytype/Sources/PresentationLayer/Auth/Join/Shared/KeyPhraseView/KeyPhraseView.swift` | Onboarding key phrase UI |
| `Anytype/Sources/PresentationLayer/Settings/KeychainPhraseView/KeychainPhraseViewModel.swift` | Settings recovery phrase logic |
| `Anytype/Sources/PresentationLayer/Settings/KeychainPhraseView/KeychainPhraseView.swift` | Settings recovery phrase UI |
| `Anytype/Sources/PresentationLayer/Settings/KeychainPhraseView/View/SeedPhraseView.swift` | Settings phrase display component |
| `Modules/Loc/Sources/Loc/Resources/Auth.xcstrings` | Localization strings |

### Current auto-copy triggers
1. **Onboarding `onPrimaryButtonTap()`** — "Show" button reveals + copies
2. **Onboarding `onPhraseTap()`** — tapping blurred phrase reveals + copies
3. **Settings `onSuccessfullRecovery()`** — reveal always copies

## Development Approach
- Small, focused changes per task
- Update plan checkboxes as tasks complete
- No unit tests — these ViewModels have no existing test coverage and the changes are straightforward conditional rewiring

## Solution Overview

### Onboarding screen (`KeyPhraseView`)
- Tapping blurred phrase → reveals only (no copy)
- "Show" button → reveals only (no copy), then transforms to "Next" as before
- Tapping **visible** phrase → copies to clipboard + toast
- Update button label from "Reveal and copy" → "Show key"

### Settings screen (`KeychainPhraseView`)
- Button starts as "Show key" (was "Show and copy key")
- After reveal, button changes to "Copy key"
- Tapping visible phrase area also copies (consistent with onboarding)
- Remove auto-copy from `onSuccessfullRecovery()`

### Analytics
- `onPrimaryButtonTap()` analytics: change from `.showAndCopy` to `.show` (button no longer copies)
- `copy()` in onboarding: keep analytics event for explicit copy action
- Settings `copyPhrase()`: log copy analytics event with `Loc.Keychain.Key.Copy.Toast.title` toast

## Implementation Steps

### Task 1: Decouple reveal from copy in onboarding KeyPhraseViewModel

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Auth/Join/Shared/KeyPhraseView/KeyPhraseViewModel.swift`

- [ ] Remove `copy()` call from `onPrimaryButtonTap()` — keep only `keyShown = true` when key is hidden
- [ ] Update analytics in `onPrimaryButtonTap()` from `.showAndCopy` to `.show` (reveal-only action)
- [ ] Change `onPhraseTap()` to: if `keyShown` → call `copy()`, else → set `keyShown = true` (reveal only)
- [ ] Keep analytics event inside `copy()` so explicit copy actions are still tracked

### Task 2: Update onboarding button label + localization cleanup

**Files:**
- Modify: `Modules/Loc/Sources/Loc/Resources/Auth.xcstrings`

- [ ] Update `Auth.JoinFlow.Key.Button.Show.Title` English fallback from "Reveal and copy" to "Show key"

### Task 3: Decouple reveal from copy in settings KeychainPhraseViewModel

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Settings/KeychainPhraseView/KeychainPhraseViewModel.swift`

- [ ] Remove `UIPasteboard.general.string = recoveryPhrase` from `onSuccessfullRecovery()`
- [ ] Remove analytics copy event from `showToast()` (copy didn't happen on reveal)
- [ ] Remove `showToast()` call from `obtainRecoveryPhrase()` flow (no copy = no toast on reveal)
- [ ] Add `copyPhrase()` method: copies `recoveryPhrase` to clipboard, shows toast with `Loc.Keychain.Key.Copy.Toast.title`, logs analytics via `logKeychainPhraseCopy`

### Task 4: Update settings UI — button state + phrase tap to copy

**Files:**
- Modify: `Anytype/Sources/PresentationLayer/Settings/KeychainPhraseView/KeychainPhraseView.swift`
- Modify: `Anytype/Sources/PresentationLayer/Settings/KeychainPhraseView/View/SeedPhraseView.swift`
- Modify: `Modules/Loc/Sources/Loc/Resources/Auth.xcstrings`

- [ ] Update `Keychain.Show and copy key` English fallback in xcstrings to "Show key"
- [ ] Add new localization key `Keychain.Copy key` with English fallback "Copy key"
- [ ] Update `KeychainPhraseView` button: conditional label — `Loc.Keychain.showAndCopyKey` (now "Show key") when `recoveryPhrase == nil`, `Loc.Keychain.copyKey` when revealed
- [ ] Update button action: conditional — `model.onSeedViewTap()` when `recoveryPhrase == nil`, `model.copyPhrase()` when revealed
- [ ] Update `SeedPhraseView` tap action: when `model.recoveryPhrase != nil` → call `model.copyPhrase()`, when nil → call `model.onSeedViewTap()` (existing reveal behavior)

### Task 5: Run `make generate` and verify

- [ ] Run `make generate` to regenerate localization strings
- [ ] Verify `Strings.swift` has updated keys and new `copyKey` constant
- [ ] Report changes to user for Xcode verification

## Post-Completion

**Manual verification:**
- Onboarding: create new account, verify phrase is NOT copied on reveal, verify tap-to-copy works on visible phrase
- Settings: open recovery phrase, verify NOT copied on reveal, verify "Copy key" button works, verify tap-to-copy on visible phrase works
- Check clipboard is clean after reveal (paste into Notes to verify)
