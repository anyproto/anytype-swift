# Taste Invariants

Mechanical rules enforced on every code change. Each rule is grep-able and has a clear remediation.
When the agent struggles with a rule, the fix is encoding it here — not "trying harder."

*Inspired by: [Harness Engineering: Codex](https://openai.com/index/harness-engineering/) — "golden principles" pattern*

## How to Use

**Before submitting code**: Run the self-review skill (`/simplify` or manual check) against this file.
**When reviewing PRs**: Check diff against these invariants.
**When a new pattern violation recurs**: Add it here with grep pattern + remediation.

---

## SwiftUI API Invariants

### No `foregroundColor()` — use `foregroundStyle()`
- **Grep**: `\.foregroundColor\(`
- **Why**: Deprecated in iOS 16+
- **Fix**: Replace with `.foregroundStyle(Color.Text.primary)` (explicit `Color` type required)

### No plain `Text()` — use `AnytypeText()`
- **Grep**: `[^a-zA-Z]Text\(` (exclude `AnytypeText`)
- **Why**: Plain `Text` bypasses design system typography
- **Fix**: `AnytypeText("content", style: .bodyRegular)`
- **Exception**: Inside `.searchable()`, `.navigationTitle()`, or other SwiftUI modifiers that require `Text`

### No `NavigationView` — use `NavigationStack`
- **Grep**: `NavigationView`
- **Why**: Deprecated in iOS 16+
- **Fix**: Replace with `NavigationStack`

### No `cornerRadius()` — use `clipShape()`
- **Grep**: `\.cornerRadius\(`
- **Why**: Deprecated
- **Fix**: `.clipShape(.rect(cornerRadius: 16))`

### No `onTapGesture` for single taps — use `Button`
- **Grep**: `\.onTapGesture\s*\{` (without `count:` parameter)
- **Why**: Not accessible to VoiceOver
- **Fix**: Wrap in `Button { } label: { }` with `.buttonStyle(.plain)` if no visual styling needed
- **Exception**: Combined gestures (tap + long press), multi-tap (`count: 2+`), inside existing Button

## Architecture Invariants

### No computed properties accessing `@Injected` storage in ViewModels
- **Grep**: `var.*:.*\{` following `@Injected` in same class
- **Why**: Called on every view re-render, causes unnecessary work
- **Fix**: Use `let` constant captured in `init`, or `@Published` with subscription

### No business logic in Views
- **Grep**: Manual review — look for service calls, data transformation, or conditional logic beyond simple view branching in `View` bodies
- **Why**: MVVM violation
- **Fix**: Move to ViewModel

### No `Group` with lifecycle modifiers on conditional content
- **Grep**: `Group\s*\{` near `.onAppear` or `.task`
- **Why**: `Group` distributes modifiers — callbacks fire multiple times when branches switch
- **Fix**: Extract to `@ViewBuilder` computed property

### No nested types inside Views
- **Grep**: `struct.*View.*\{` containing `enum` or `struct` definitions
- **Why**: Project convention — extract to top-level with descriptive name
- **Fix**: `ChatMessageType` instead of `ChatView.MessageType`

## Localization Invariants

### No hardcoded user-facing strings
- **Grep**: `Text\("` or `AnytypeText\("` with literal string (not `Loc.`)
- **Why**: Breaks localization
- **Fix**: Add key to `.xcstrings`, run `make generate`, use `Loc.yourKey`
- **Exception**: Debug-only strings, format strings in non-UI code

### Use generated functions for parameterized strings
- **Grep**: `String(format: Loc\.`
- **Why**: SwiftGen generates type-safe functions
- **Fix**: `Loc.yourKey(value)` not `String(format: Loc.yourKey, value)`

## Design System Invariants

### No hardcoded colors
- **Grep**: `Color\(red:` or `Color\(hex:` or `#[0-9a-fA-F]{6}` or `UIColor\(red:`
- **Why**: Bypasses design system, breaks dark mode
- **Fix**: Use `Color.Text.primary`, `Color.Shape.secondary`, etc.

### No hardcoded font sizes
- **Grep**: `\.font\(.system\(size:` or `Font.system(size:`
- **Why**: Bypasses typography system
- **Fix**: Use `AnytypeText(_, style:)` or `AnytypeFontBuilder.font(anytypeFont:)`

### Icons must use asset catalog
- **Grep**: `Image(systemName:` for non-SF-Symbol custom icons
- **Why**: Custom icons live in asset catalog
- **Fix**: `Image(asset: .X32.iconName)`

## Code Quality Invariants

### No optional booleans for tri-state — use enums
- **Grep**: `:\s*Bool\?`
- **Why**: `Bool?` (true/false/nil) creates ambiguous logic — the meaning of `nil` is implicit and context-dependent (loading? not determined? unknown?)
- **Fix**: Define an enum with explicit named cases
- **Exception**: API/middleware parameters that simply pass through optionals

```swift
// ❌ WRONG — What does nil mean here?
var isEnabled: Bool?

// ✅ CORRECT — Intent is explicit
enum EnabledState {
    case enabled
    case disabled
    case loading
}
```

### No force unwraps in production code
- **Grep**: `[^/]![^=\s]` (rough — excludes `!=`, comments)
- **Why**: Runtime crash risk
- **Fix**: Use `guard let`, `if let`, or `??` with default
- **Exception**: `IBOutlet`, test code, truly guaranteed values (with comment explaining why)

### No `print()` — use structured logging
- **Grep**: `print\(` in non-test Swift files
- **Why**: Not captured in logging infrastructure
- **Fix**: Use `anytypeAssertionFailure()` or proper logging

### Generated files are never manually edited
- **Grep**: Changes to files containing `// Generated using Sourcery` or `// Generated using SwiftGen`
- **Why**: Overwritten on next `make generate`
- **Fix**: Edit source file, then run `make generate`

## Refactoring Invariants

### All references updated when renaming
- **Check**: `rg "oldName" --type swift` returns 0 results (excluding generated files)
- **Why**: Missed references cause build failures or dead code
- **Fix**: Search and update all: production, tests, mocks, DI registrations

### Unused code removed after refactoring
- **Check**: No orphaned files, unreferenced properties, or dead imports
- **Why**: Prevents bloat and confusion
- **Fix**: Search for usages, delete if unreferenced

### Unused localization keys removed
- **Check**: If `Loc.yourKey` is only in `Generated/Strings.swift`, it's orphaned
- **Why**: Bloats translations, confuses translators
- **Fix**: Remove from `.xcstrings`, run `make generate`

---

## Adding New Invariants

When you encounter a recurring pattern violation:

1. **Add it here** with: rule name, grep pattern, why, fix, exceptions
2. **Make it mechanical** — if it can be grepped, it can be enforced
3. **Include remediation** — the fix should be in the error message
4. **Keep it focused** — one rule per entry, no essays

The goal: every rule in this file should be verifiable without human judgment.
