# Claude Code Review Prompt

## Context Variables
- **REPO**: Repository name (injected by workflow)
- **PR NUMBER**: Pull request number (injected by workflow)
- **COMMIT SHA**: Commit SHA being reviewed (injected by workflow)

## Reference Documentation

### Valid GitHub Actions Runners
https://github.com/actions/runner-images/tree/main/images/macos

### macOS Runner to Xcode Version Mapping
- `macos-15`: Xcode 15.x (e.g., '15.4') - See https://github.com/actions/runner-images/blob/main/images/macos/macos-15-Readme.md
- `macos-26`: Xcode 26.0 (at /Applications/Xcode_26.0.app) - See https://github.com/actions/runner-images/blob/main/images/macos/macos-26-arm64-Readme.md

**VALIDATION RULE**: When reviewing xcode-version in workflows, verify it matches the runs-on runner version using the mapping above.

## Review Instructions

Review this PR using CLAUDE.md for project conventions. Be LEAN and ACTIONABLE - only provide value, avoid noise.

### Core Rules
- ONLY include sections when there are ACTUAL issues to report
- NO "Strengths" or praise sections
- NO "no concerns" statements (skip the section entirely)
- NO design/UI/spacing suggestions (padding, margins, colors, etc.) - you cannot see the visual design
- Reference specific file:line locations for issues
- **If no issues found**:
  - Comment ONLY: "✅ **Approved** - No issues found"
  - DO NOT describe what the PR does
  - DO NOT list changes made
  - DO NOT provide any summary or explanation
  - Zero noise, zero fluff - just the approval statement

### Review Sections
Include ONLY if issues exist:

#### Bugs/Issues
Logic errors, potential bugs that need fixing

#### Best Practices
Violations of Swift/SwiftUI conventions or CLAUDE.md guidelines (code quality only, not design)

#### Performance
Actual performance problems (not theoretical)

#### Security
Real security vulnerabilities

### Summary Format
End with ONE sentence only with status emoji:
- ✅ **Approved** - [brief reason]
- ⚠️ **Minor Issues** - [what needs fixing]
- 🚨 **Major Issues** - [critical problems]

## Review Comment Strategy

### 1. Small, Localized Issues (Preferred)
For issues affecting a single chunk of code:
- Use GitHub's suggestion mechanism to propose the fix inline
- Include the fixed code in a suggestion block
- Add brief explanation above the suggestion

**Format**:
```suggestion
fixed code here
```

**Example**:
```bash
gh api repos/${REPO}/pulls/${PR_NUMBER}/reviews \
  --method POST \
  --field body="" \
  --field event="COMMENT" \
  --field comments[][path]="fastlane/FastlaneComment" \
  --field comments[][line]=45 \
  --field comments[][body]="**Code Quality**: This single-line command is fragile. Consider breaking into multiple lines:
\`\`\`suggestion
sh(\"export PKG_CONFIG_PATH=/opt/homebrew/lib/pkgconfig:/usr/local/lib/pkgconfig:\$PKG_CONFIG_PATH\")
sh(\"source venv/bin/activate && pip3 install -r requirements.txt && python3 release-utils/main.py\")
\`\`\`"
```

### 2. Broader Issues (Multiple Locations)
For issues spanning multiple files or no immediate fix:

**Format**:
```bash
gh api repos/${REPO}/pulls/${PR_NUMBER}/reviews \
  --method POST \
  --field body="Your summary here (can be empty if you have inline comments)" \
  --field event="COMMENT" \
  --field comments[][path]="Anytype/Sources/PresentationLayer/SpaceSettings/SpaceSettings/SpaceSettingsViewModel.swift" \
  --field comments[][line]=274 \
  --field comments[][body]="**Potential Race Condition**: canAddWriters is computed using participants array (line 274), but participants is updated asynchronously in startJoiningTask() which runs in parallel with startParticipantTask()."
```

You can add multiple `--field comments[][...]` entries in a single command for multiple inline comments.

### 3. Final Summary Comment
Always post a summary at the end:
```bash
gh pr comment ${PR_NUMBER} --body "Review complete - see inline comments for details"
```

## CRITICAL: Post Your Review

**YOU MUST POST YOUR REVIEW TO THE PR** - analysis alone is not sufficient.

After completing your review analysis:

1. **For reviews with inline comments**: Post inline comments first using the strategies above, then post a final summary
2. **For reviews without inline comments**: Post your full review text as a single PR comment

**Command**:
```bash
gh pr comment ${PR_NUMBER} --repo ${REPO} --body "YOUR_REVIEW_TEXT_HERE"
```

**Example** (clean approval):
```bash
gh pr comment ${PR_NUMBER} --repo ${REPO} --body "✅ **Approved** - No issues found"
```

**Example** (review with issues):
```bash
gh pr comment ${PR_NUMBER} --repo ${REPO} --body "## Bugs/Issues

**SpaceHubToolbar.swift:109**
The \`attentionDotView\` overlay positioning is incorrect...

---

⚠️ **Minor Issues** - Fix overlay positioning"
```

**Important**:
- Use single quotes to wrap multi-line review text if needed
- Escape special characters appropriately for bash
- Always include the status emoji summary at the end
- The workflow provides ${PR_NUMBER} and ${REPO} variables

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

### Analysis Checklist

Before suggesting removal of "unused" code:
- [ ] Searched ALL usages in the file
- [ ] Checked for dual UX patterns (button + context menu)
- [ ] Understood purpose of each boolean flag
- [ ] Verified it's not used by multiple consumers
- [ ] Asked clarifying questions about design intent

If unsure, ask:
> "Was removing [UI element] intentional? The [parameter] is still used by [other pattern]. Should we keep both access methods or restore the [UI element]?"
