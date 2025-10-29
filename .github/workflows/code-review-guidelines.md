# Code Review Guidelines

Shared review standards for both local reviews and automated CI reviews.

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

## Analysis Checklist

Before suggesting removal of "unused" code:
- [ ] Searched ALL usages in the file
- [ ] Checked for dual UX patterns (button + context menu)
- [ ] Understood purpose of each boolean flag
- [ ] Verified it's not used by multiple consumers
- [ ] Asked clarifying questions about design intent

If unsure, ask:
> "Was removing [UI element] intentional? The [parameter] is still used by [other pattern]. Should we keep both access methods or restore the [UI element]?"
