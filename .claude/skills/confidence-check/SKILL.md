---
name: confidence-check
description: Pre-implementation confidence assessment to prevent wrong-direction work. Evaluates readiness across 5 weighted criteria before proceeding with implementation.
---

# Confidence Check (Pre-Implementation Gate)

## Purpose
Prevent costly wrong-direction work by assessing implementation readiness before starting. Spend 100-200 tokens on assessment to save 5,000-50,000 tokens on misdirected implementation.

## When to Apply
- Before implementing new features
- Before significant refactoring
- Before fixing complex bugs
- When requirements seem ambiguous
- Keywords: implement, build, create, add feature, refactor

## The 5-Check Assessment

Evaluate each criterion and calculate a weighted confidence score:

| Check | Weight | What to Verify |
|-------|--------|----------------|
| **No Duplicates** | 25% | Search codebase for existing functionality |
| **Pattern Compliance** | 25% | Aligns with MVVM, Coordinator, `@Injected` DI |
| **Documentation Verified** | 20% | Checked middleware, protobuf, existing services |
| **Design System Applied** | 15% | Uses `Loc.*`, `Color.*`, `Image(asset:)` |
| **Root Cause Clear** | 15% | Understand actual problem vs symptoms |

## Decision Thresholds

```
Score >= 90%  -->  PROCEED with implementation
Score 70-89%  -->  PAUSE - present alternatives, ask clarifying questions
Score < 70%   -->  STOP - request more context before proceeding
```

## How to Score

### Check 1: No Duplicates (25%)
Before implementing, search for existing solutions:
```bash
# Search for similar functionality
rg "similar_function_name" --type swift
rg "RelatedClass" --type swift
```

**Pass**: No existing implementation found, or existing code needs extension
**Fail**: Duplicate functionality exists that should be reused

### Check 2: Pattern Compliance (25%)
Verify alignment with project architecture:
- [ ] Using MVVM pattern (ViewModel + View separation)
- [ ] Coordinator for navigation (not direct NavigationLink)
- [ ] `@Injected` for dependency injection
- [ ] `@MainActor` on ViewModels
- [ ] Repository pattern for data access

**Pass**: Planned approach follows all relevant patterns
**Fail**: Proposed solution violates established patterns

### Check 3: Documentation Verified (20%)
Confirm understanding of existing systems:
- [ ] Checked relevant service layer code
- [ ] Reviewed middleware/protobuf definitions if applicable
- [ ] Read existing related ViewModels/Coordinators
- [ ] Understood data flow

**Pass**: Have concrete evidence from code exploration
**Fail**: Assumptions without code verification

### Check 4: Design System Applied (15%)
Verify UI implementation uses project standards:
- [ ] Localization: `Loc.keyName` (not hardcoded strings)
- [ ] Colors: `Color.Text.primary`, `Color.Shape.*` (not custom colors)
- [ ] Icons: `Image(asset: .X24.iconName)` (not SF Symbols)
- [ ] Typography: Design system text styles

**Pass**: All UI elements use design system
**Fail**: Custom colors, hardcoded strings, or non-standard icons

### Check 5: Root Cause Clear (15%)
Ensure you understand the actual problem:
- [ ] Can explain why the current behavior is wrong
- [ ] Identified where the issue originates (not just symptoms)
- [ ] Understand the expected behavior clearly

**Pass**: Can articulate problem and solution clearly
**Fail**: Only treating symptoms or unclear on requirements

## Example Assessment

```
Task: Add a new settings toggle for notification preferences

CHECK 1 - No Duplicates: [PASS - 25%]
  - Searched: rg "notification.*toggle" --type swift
  - Found: No existing toggle, only NotificationService

CHECK 2 - Pattern Compliance: [PASS - 25%]
  - Will use SettingsViewModel (existing)
  - Will extend SettingsCoordinator for new screen
  - Will inject NotificationService via @Injected

CHECK 3 - Documentation Verified: [PASS - 20%]
  - Reviewed SettingsViewModel.swift
  - Checked NotificationService protocol
  - Confirmed UserDefaults storage pattern

CHECK 4 - Design System Applied: [PASS - 15%]
  - Will use Loc.Settings.notifications
  - Will use Toggle from DesignSystem
  - Will use Color.Text.primary

CHECK 5 - Root Cause Clear: [PASS - 15%]
  - Users need granular notification control
  - Currently only global on/off exists
  - Need per-category toggles

TOTAL SCORE: 100%  -->  PROCEED
```

## Quick Checklist Format

For faster assessment, use this condensed format:

```
CONFIDENCE CHECK:
[ ] No duplicates found (25%)
[ ] Follows MVVM/Coordinator/DI patterns (25%)
[ ] Verified existing code/docs (20%)
[ ] Uses Loc/Color/Image design system (15%)
[ ] Root cause understood (15%)

Score: ___% --> [PROCEED/PAUSE/STOP]
```

## When to Skip

Skip confidence check for:
- Trivial changes (typos, simple renames)
- Direct user instructions with clear requirements
- Following up on already-verified implementation

## ROI

| Scenario | Without Check | With Check |
|----------|--------------|------------|
| Duplicate implementation | 5,000+ tokens wasted | 100 tokens saved it |
| Wrong architecture | 10,000+ tokens rework | 150 tokens caught early |
| Missing context | 8,000+ tokens redoing | 200 tokens asked first |

**Rule of thumb**: If implementation will take >500 tokens, spend 100-200 on confidence check first.

---

**Navigation**: This skill integrates with `ios-dev-guidelines` and `design-system-developer` for pattern verification.
