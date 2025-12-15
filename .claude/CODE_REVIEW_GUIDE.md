# Code Review Guide

Comprehensive review standards for both local reviews and automated CI reviews.

## Core Review Rules

Review using CLAUDE.md for project conventions. Be LEAN and ACTIONABLE - only provide value, avoid noise.

- ONLY include sections when there are ACTUAL issues to report
- NO "Strengths" or praise sections
- NO "no concerns" statements (skip the section entirely)
- NO design/UI/spacing suggestions (padding, margins, colors, etc.) - you cannot see the visual design
- Reference specific file:line locations for issues
- **If no issues found**:
  - Comment ONLY: "✅ **Approved** - No issues found"
  - DO NOT describe what the changes do
  - DO NOT list changes made
  - DO NOT provide any summary or explanation
  - Zero noise, zero fluff - just the approval statement

## Review Sections

Include ONLY if issues exist:

### Bugs/Issues
Logic errors, potential bugs that need fixing

### Best Practices
Violations of Swift/SwiftUI conventions or CLAUDE.md guidelines (code quality only, not design)

### Performance
Actual performance problems (not theoretical)

### Security
Real security vulnerabilities

## Summary Format

End with ONE sentence only with status emoji:
- ✅ **Approved** - [brief reason]
- ⚠️ **Minor Issues** - [what needs fixing]
- 🚨 **Major Issues** - [critical problems]

## Common Analysis Mistakes to Avoid

### Mistake: Assuming Unused Code After UI Element Removal

**Scenario**: A PR removes a visible UI element (e.g., a menu button) but leaves related parameters in the API.

**Wrong Analysis**:
- ❌ "Parameter is unused, should be removed"
- ❌ "Remove all related infrastructure"
- ❌ Not checking where else the parameter is used

**Correct Approach**:
1. **Trace all usages** of parameters/closures before declaring them unused
2. **Understand dual UX patterns**: iOS commonly uses button + long-press for same actions
3. **Check for multiple consumers**: A closure/parameter may serve multiple UI patterns

**Example - Menu Button + Context Menu Pattern**:
```swift
// Component accepts menu closure
struct Widget<MenuContent: View> {
    let menu: () -> MenuContent

    var body: some View {
        content
            .toolbar {
                // Visible menu button
                Menu { menu() } label: { Image(...) }
            }
            .contextMenu {
                // Long-press menu (same content!)
                menu()
            }
    }
}
```

**Analysis**:
- Removing the toolbar menu button does NOT make `menu` parameter unused
- The `menu()` closure is still actively used by `.contextMenu`
- Both are valid access patterns for the same functionality

**Key Questions to Ask**:
- Where else is this parameter/closure called in the file?
- Is this a dual-access pattern (button + long-press)?
- Was the removal intentional (UX change) or accidental?
- Are there separate flags controlling each access method?

### Mistake: Not Understanding Conditional Rendering Flags

**Scenario**: A component has multiple boolean flags like `allowMenuContent` and `allowContextMenuItems`.

**Wrong Analysis**:
- ❌ "These flags serve the same purpose, consolidate them"
- ❌ Not recognizing they control different UI elements

**Correct Approach**:
1. Each flag controls a specific UI element/pattern
2. `allowMenuContent`: Controls visible button
3. `allowContextMenuItems`: Controls long-press menu
4. They can be independently enabled/disabled

**Example**:
```swift
// Widget with independent menu controls
LinkWidgetViewContainer(
    allowMenuContent: false,      // No visible button
    allowContextMenuItems: true,  // Long-press still works
    menu: { MenuItem() }          // Used by context menu only
)
```

### Mistake: Flagging `try?` with Middleware Calls as Silent Error Handling

**Scenario**: A PR uses `try?` when calling middleware/service methods.

**Wrong Analysis**:
- ❌ "Error is silently ignored, should use `try await` for user feedback"
- ❌ "AsyncStandardButton won't show error toast"

**Why This Is Wrong**:
- All middleware errors are **automatically logged** internally
- Using `try?` is intentional when the operation should fail silently from user's perspective
- Not every failure needs user-facing feedback (e.g., creating a space quietly fails)

**Correct Approach**:
1. Middleware calls already have internal error logging
2. `try?` = intentional silent failure (logged but no user toast)
3. `try await` = propagate error for user feedback (toast/alert)
4. Both are valid patterns depending on UX requirements

**Example**:
```swift
// ✅ VALID: Silent failure - error is logged internally, user sees nothing
if let spaceId = try? await workspaceService.createOneToOneSpace(...) {
    pageNavigation?.open(.spaceChat(...))
}

// ✅ ALSO VALID: Propagate error - AsyncStandardButton shows toast
func onConnect() async throws {
    let spaceId = try await workspaceService.createOneToOneSpace(...)
    pageNavigation?.open(.spaceChat(...))
}
```

**When to flag `try?`**:
- Only if there's evidence the error SHOULD be shown to users
- If the surrounding code expects error handling (e.g., catch blocks nearby)
- If it's a user-initiated action that typically needs feedback

### Mistake: Flagging SF Symbols as Non-Design System

**Scenario**: Code uses `Image(systemName: "...")` instead of `Image(asset: ...)`.

**Wrong Analysis**:
- ❌ "Uses SF Symbol instead of design system asset"
- ❌ "Should use Image(asset: ...) for consistency"

**Why This Is Wrong**:
- SF Symbols (`Image(systemName:)`) are a **valid and common pattern** in this codebase
- 40+ usages across 24+ files confirm this is an accepted practice
- SF Symbols provide consistent iOS-native icons and accessibility

**Correct Approach**:
- ✅ `Image(systemName: "qrcode.viewfinder")` - Valid
- ✅ `Image(asset: .X24.qrCode)` - Also valid
- Both approaches are acceptable depending on context and availability

## Analysis Checklist

Before suggesting removal of "unused" code:
- [ ] Searched ALL usages in the file
- [ ] Checked for dual UX patterns (button + context menu)
- [ ] Understood purpose of each boolean flag
- [ ] Verified it's not used by multiple consumers
- [ ] Asked clarifying questions about design intent

If unsure, ask:
> "Was removing [UI element] intentional? The [parameter] is still used by [other pattern]. Should we keep both access methods or restore the [UI element]?"
