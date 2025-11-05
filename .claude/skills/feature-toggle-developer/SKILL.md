# Feature Toggle Developer

**Status**: Active
**Auto-activates on**: Feature flag/toggle removal, cleanup after refactoring toggles
**Related Skills**: `code-generation-developer`, `ios-dev-guidelines`, `code-review-developer`

## Purpose

Guides the systematic removal of feature toggles (feature flags) from the codebase with automated cleanup detection. Ensures no orphaned code, unused components, or forgotten files remain after toggle removal.

## When This Skill Activates

- User mentions: "remove toggle", "delete feature flag", "enable feature toggle permanently"
- User edits: `FeatureDescription+Flags.swift`
- After completing toggle removal: helps identify cleanup opportunities

## Feature Toggle Removal Workflow

### Phase 1: Pre-Removal Analysis

Before removing any toggle, gather complete information:

1. **Find the toggle definition**:
   ```bash
   # Location: Modules/AnytypeCore/AnytypeCore/Utils/FeatureFlags/FeatureDescription+Flags.swift
   rg "static let toggleName" --type swift
   ```

2. **Check the defaultValue** to determine which branch to keep:
   - `defaultValue: true` → Keep the TRUE branch, remove FALSE branch
   - `defaultValue: false` → Keep the FALSE branch, remove TRUE branch

3. **Search for ALL usages**:
   ```bash
   rg "toggleName" --type swift
   ```

4. **Identify usage patterns**:
   - Direct: `if FeatureFlags.toggleName { ... }`
   - Inverted: `if !FeatureFlags.toggleName { ... }` or `guard !FeatureFlags.toggleName`
   - Compound: `if FeatureFlags.toggleName && otherCondition { ... }`
   - Assignment: `let value = FeatureFlags.toggleName ? a : b`
   - State: `@State private var toggle = FeatureFlags.toggleName`

5. **List affected files** and present to user for review

### Phase 2: Toggle Removal

Systematic removal process:

1. **Remove conditional checks and simplify**:

   **Example 1 - Simple conditional (defaultValue: true)**:
   ```swift
   // BEFORE
   if FeatureFlags.toggleName {
       // feature code
   }

   // AFTER (keep true branch)
   // feature code
   ```

   **Example 2 - Ternary operator (defaultValue: true)**:
   ```swift
   // BEFORE
   VStack(spacing: FeatureFlags.toggleName ? 8 : 0)

   // AFTER
   VStack(spacing: 8)
   ```

   **Example 3 - Inverted logic (defaultValue: true)**:
   ```swift
   // BEFORE
   guard !FeatureFlags.toggleName else { return }
   oldCode()

   // AFTER (flag is true, so guard fails, remove entire block)
   // [entire block deleted]
   ```

   **Example 4 - State variable (defaultValue: true)**:
   ```swift
   // BEFORE
   @State private var toggle = FeatureFlags.toggleName
   if toggle { newUI() } else { oldUI() }

   // AFTER
   newUI()
   // Note: @State variable removed in cleanup phase
   ```

2. **Remove feature flag definition**:
   ```swift
   // Delete from: Modules/AnytypeCore/AnytypeCore/Utils/FeatureFlags/FeatureDescription+Flags.swift
   static let toggleName = FeatureDescription(...)
   ```

3. **Run code generation**:
   ```bash
   make generate
   ```
   This updates `FeatureFlags+Flags.swift` automatically.

4. **Verify removal**:
   ```bash
   rg "toggleName" --type swift  # Should return no results
   ```

### Phase 3: Automated Cleanup Detection ⭐

**CRITICAL**: After toggle removal, systematically check for orphaned code:

#### 3.1 Unused State Variables

Search for `@State` variables that were only used for the toggle:

```bash
# Look for patterns like: @State private var someToggle = FeatureFlags.toggleName
rg "@State.*=.*FeatureFlags" --type swift
```

**Action**: Remove the entire `@State` variable declaration if it's no longer used.

#### 3.2 Unused View Components

When a toggle controlled which UI component to show, one component may now be unused:

**Detection Pattern**:
- Toggle switched between ComponentA and ComponentB
- After removal, only one is used
- Search for the unused component's name across codebase

**Example from vaultBackToRoots**:
```swift
// BEFORE
if !vaultBackToRootsToggle {
    SpaceCardLabel(...)  // This became unused
} else {
    NewSpaceCardLabel(...)
}

// AFTER
NewSpaceCardLabel(...)

// CLEANUP: SpaceCardLabel is now unused
rg "SpaceCardLabel" --type swift  # Check if used anywhere else
# If only in its own file → DELETE the file
```

**Action**:
1. Search for unused component name: `rg "UnusedComponentName" --type swift`
2. If only found in its definition file and comments → DELETE the file
3. Update references in comments

#### 3.3 Unused ViewModels / Service Classes

Toggle removal may leave entire classes unused:

**Detection**:
```bash
# For each major component that was conditionally used:
rg "UnusedViewModel" --type swift
rg "class UnusedViewModel" --type swift
```

**Action**: Delete unused ViewModels, their files, and DI registrations.

#### 3.4 Unused Imports

After simplification, `import AnytypeCore` may only have been needed for `FeatureFlags`:

**Detection**:
- File imports `AnytypeCore`
- Only usage was `FeatureFlags.toggleName`
- After removal, no other `AnytypeCore` usage

**Action**: Remove unused import.

#### 3.5 Orphaned Parameters / Properties

Toggle-gated functionality may have parameters that are no longer needed:

**Example**:
```swift
// BEFORE
func configure(showFeature: Bool) {
    if showFeature && FeatureFlags.toggle { ... }
}

// AFTER toggle removal
func configure(showFeature: Bool) {
    if showFeature { ... }
}

// POTENTIAL CLEANUP: Is showFeature still needed?
```

**Action**: Review function signatures and remove unnecessary parameters.

#### 3.6 Test Cleanup

Toggle removal affects tests:

**Check**:
1. Mock objects with toggle-related properties
2. Test cases specifically for toggle behavior
3. Test setup code with toggle configurations

**Files to check**:
```bash
rg "toggleName" AnyTypeTests/ --type swift
rg "toggleName" "Anytype/Sources/PreviewMocks/" --type swift
```

**Action**: Update or remove tests for deleted code paths.

### Phase 4: Final Verification

Before committing:

1. **Grep verification**:
   ```bash
   rg "toggleName" --type swift  # Should be empty
   ```

2. **Compilation check**:
   - Remind user to verify compilation in Xcode
   - Claude cannot verify this due to caching

3. **Generate updated commit message**:
   ```
   IOS-XXXX Removed [toggleName] toggle
   ```

4. **Review cleanup summary**:
   - List all files modified
   - List all files deleted
   - Note any remaining manual checks needed

## Cleanup Checklist Template

Use this checklist after every toggle removal:

```markdown
## Cleanup Verification for [toggleName]

- [ ] Toggle definition removed from FeatureDescription+Flags.swift
- [ ] `make generate` run successfully
- [ ] All conditional usage removed
- [ ] No grep results for toggle name
- [ ] Unused @State variables removed
- [ ] Unused view components identified and deleted
- [ ] Unused ViewModels/services deleted
- [ ] Unused imports removed (especially AnytypeCore)
- [ ] Orphaned function parameters removed
- [ ] Tests updated (check AnyTypeTests/ and PreviewMocks/)
- [ ] Comments referencing old component updated
- [ ] Xcode compilation verified (by user)
```

## Common Patterns & Pitfalls

### Inverted Logic

**Watch out for** `!FeatureFlags.toggle`:

```swift
// If defaultValue: true
if !FeatureFlags.toggle {
    oldCode()  // This branch NEVER runs, delete it
}
```

### Compound Conditions

**Simplify** conditions properly:

```swift
// BEFORE (defaultValue: true)
if FeatureFlags.toggle && userHasPermission {
    showFeature()
}

// AFTER
if userHasPermission {
    showFeature()
}
```

### Guard Statements

**Be careful** with guards:

```swift
// BEFORE (defaultValue: true)
guard !FeatureFlags.toggle else { return }
performOldBehavior()

// AFTER (toggle is true, guard returns, entire block is dead code)
// DELETE ENTIRE BLOCK
```

## Integration with Other Skills

- **code-generation-developer**: References for `make generate` command and troubleshooting
- **ios-dev-guidelines**: Swift refactoring patterns, import management
- **code-review-developer**: Cleanup standards, ensuring no orphaned code in PRs

## Example Session

```
User: "remove vaultBackToRoots toggle"