# Code Review Developer (Smart Router)

## Purpose
Context-aware routing to code review guidelines. Helps you conduct thorough, actionable code reviews following project standards.

## When Auto-Activated
- Reviewing pull requests or code changes
- Keywords: code review, PR review, review code, pull request, approve, issues
- Discussing review comments or feedback

## 🚨 CRITICAL RULES (NEVER VIOLATE)

1. **Be LEAN and ACTIONABLE** - Only report actual issues, no noise
2. **NO praise sections** - No "Strengths", no "no concerns" statements
3. **NO design suggestions** - You cannot see visual design (padding, margins, colors)
4. **Reference file:line** - Always include specific locations for issues
5. **If clean, just approve** - "✅ **Approved** - No issues found" (nothing else!)
6. **Check CLAUDE.md** - Review against project conventions

## 📋 Quick Review Workflow

### 1. Read the Changes
- Understand what the PR is trying to do
- Check file diffs thoroughly

### 2. Check Against CLAUDE.md
- Localization: Using `Loc` constants?
- Generated files: Not editing generated code?
- Code style: Following Swift best practices?
- Tests: Updated when refactoring?

### 3. Look for Real Issues
**ONLY include sections if issues exist:**
- **Bugs/Issues** - Logic errors, potential bugs
- **Best Practices** - Violations of CLAUDE.md guidelines
- **Performance** - Actual performance problems
- **Security** - Real security vulnerabilities

### 4. Format Your Review

**If clean**:
```
✅ **Approved** - No issues found
```

**If issues found**:
```
## Bugs/Issues

**ChatView.swift:45**
Potential race condition when...

---

⚠️ **Minor Issues** - Fix race condition
```

## ⚠️ Common Mistakes to Avoid

### Assuming Code is Unused After UI Removal

**Scenario**: PR removes a menu button but leaves the `menu` parameter

**❌ WRONG**:
```
"The menu parameter is now unused and should be removed"
```

**✅ CORRECT**:
```
Check if menu is used elsewhere:
- Long-press context menu?
- Dual UX pattern (button + long-press)?
- Multiple consumers?
```

**Example**:
```swift
// menu() is used in BOTH places
.toolbar { Menu { menu() } }     // Visible button (removed)
.contextMenu { menu() }          // Long-press (still there!)
```

**Before suggesting removal**:
- [ ] Searched ALL usages in the file
- [ ] Checked for dual UX patterns
- [ ] Understood purpose of each flag
- [ ] Asked about design intent if unsure

### Not Understanding Conditional Flags

**Scenario**: Component has `allowMenuContent` and `allowContextMenuItems`

**❌ WRONG**:
```
"These flags serve the same purpose, consolidate them"
```

**✅ CORRECT**:
```
They control DIFFERENT UI elements:
- allowMenuContent: Visible button
- allowContextMenuItems: Long-press menu
- Can be independently enabled/disabled
```

## 🎯 Review Sections (Include ONLY If Issues Exist)

### Bugs/Issues
Logic errors, potential bugs that need fixing

**Format**:
```
**FileName.swift:123**
Description of the bug and why it's a problem.
```

### Best Practices
Violations of Swift/SwiftUI conventions or CLAUDE.md guidelines (code quality only, not design)

**Format**:
```
**FileName.swift:45**
Using hardcoded strings instead of Loc constants.
```

### Performance
Actual performance problems (not theoretical)

**Format**:
```
**ViewModel.swift:89**
N+1 query in loop - will cause performance issues with large datasets.
```

### Security
Real security vulnerabilities

**Format**:
```
**AuthService.swift:34**
Storing credentials in UserDefaults - should use Keychain.
```

## 📊 Summary Format

**End with ONE sentence with status emoji**:

```
✅ **Approved** - Clean implementation following guidelines
⚠️ **Minor Issues** - Fix hardcoded strings and race condition
🚨 **Major Issues** - Critical security vulnerability in auth flow
```

## 🔍 Analysis Checklist

Before finalizing your review:
- [ ] Checked against CLAUDE.md conventions
- [ ] Verified localization (no hardcoded strings)
- [ ] Checked for generated file edits
- [ ] Looked for race conditions
- [ ] Verified tests/mocks updated if refactoring
- [ ] Searched for ALL usages before suggesting removal
- [ ] Only included sections with actual issues
- [ ] No design/UI suggestions (padding, margins, colors)
- [ ] Referenced specific file:line for each issue
- [ ] Ended with status emoji summary

## 📚 Complete Documentation

**Full Guide**: `.claude/CODE_REVIEW_GUIDE.md`

For comprehensive coverage of:
- Core review rules
- Common analysis mistakes (with examples)
- Review sections and formats
- Complete checklist

**CI/Automation**: `.github/workflows/pr-review-automation.md`

For GitHub Actions integration:
- Context variables (REPO, PR_NUMBER, COMMIT_SHA)
- Valid runners and Xcode versions
- Review comment strategies
- How to post reviews via `gh` CLI

## 💡 Quick Reference

### What to Check

**From CLAUDE.md**:
- [ ] No hardcoded strings (use `Loc` constants)
- [ ] No generated file edits (`// Generated using...`)
- [ ] Tests/mocks updated when refactoring
- [ ] Feature flags for new features
- [ ] No whitespace trimming
- [ ] Async/await over completion handlers

**Code Quality**:
- [ ] Swift best practices (guard, @MainActor)
- [ ] Proper error handling
- [ ] No force unwraps in production code
- [ ] Memory leaks (weak/unowned where needed)

### What NOT to Comment On

- ❌ Design/UI spacing (padding, margins)
- ❌ Colors or visual appearance
- ❌ Praise or "Strengths" sections
- ❌ "No concerns" statements
- ❌ Theoretical performance issues
- ❌ Style preferences not in CLAUDE.md

## 🎓 Example Reviews

### Example 1: Clean PR
```
✅ **Approved** - No issues found
```

**That's it! Don't add explanations, don't list changes.**

### Example 2: Minor Issues
```
## Best Practices

**ChatView.swift:34**
Using hardcoded string "Send Message" instead of localization constant.
Should be: `Text(Loc.sendMessage)`

**ChatViewModel.swift:89**
Tests not updated after renaming `sendMessage()` to `send()`.
Update `ChatViewModelTests.swift` to use new method name.

---

⚠️ **Minor Issues** - Fix hardcoded string and update tests
```

### Example 3: Critical Issue
```
## Bugs/Issues

**AuthService.swift:45**
Storing password in UserDefaults (line 45). This is a security vulnerability.
Should use Keychain instead: `KeychainService.store(password, for: key)`

---

🚨 **Major Issues** - Fix password storage security vulnerability
```

## 🔗 Related Skills & Docs

- **ios-dev-guidelines** → `IOS_DEVELOPMENT_GUIDE.md` - Swift/iOS patterns to check against
- **localization-developer** → `LOCALIZATION_GUIDE.md` - Verify no hardcoded strings
- **code-generation-developer** → `CODE_GENERATION_GUIDE.md` - Verify no generated file edits

---

**Navigation**: This is a smart router. For detailed review standards and common mistakes, always refer to `.claude/CODE_REVIEW_GUIDE.md`.

**For CI/automation**: See `.github/workflows/pr-review-automation.md` for GitHub Actions integration.
