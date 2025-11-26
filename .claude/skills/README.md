# Claude Code Skills System

Smart routing system for the Anytype iOS project using **progressive disclosure** architecture. Skills act as lightweight routers that provide critical rules and point you to comprehensive documentation.

## Overview

This skills system uses a **3-level progressive disclosure** pattern:
- **Level 1**: CLAUDE.md - Lightweight overview + quick reference
- **Level 2**: Skills (this directory) - Smart routers with critical rules + navigation
- **Level 3**: Specialized guides - Deep technical documentation

Skills provide **automatic activation** based on your prompts and file context, eliminating the need to manually load documentation.

## 🎯 Available Skills

### 1. **ios-dev-guidelines** (Smart Router)
**Purpose**: Routes to Swift/iOS development patterns, architecture, and best practices

**Auto-activates when**:
- Working with `.swift` files
- Discussing ViewModels, Coordinators, or architecture
- Refactoring or formatting code
- Using keywords: swift, swiftui, mvvm, async, await

**Provides**:
- Critical rules (NEVER trim whitespace, update tests/mocks, etc.)
- Quick patterns (MVVM ViewModel, Coordinator, DI)
- Project structure overview
- Common historical mistakes
- **→ Routes to**: `Anytype/Sources/IOS_DEVELOPMENT_GUIDE.md` for comprehensive details

**Location**: `.claude/skills/ios-dev-guidelines/SKILL.md`

---

### 2. **localization-developer** (Smart Router)
**Purpose**: Routes to localization system for managing .xcstrings files and Loc constants

**Auto-activates when**:
- Working with `.xcstrings` files
- Using Loc constants
- Discussing hardcoded strings or user-facing text
- Using keywords: localization, strings, text, Loc.

**Provides**:
- Critical rules (NEVER duplicate keys, only edit English, etc.)
- 3-file decision tree (Auth/Workspace/UI)
- Quick workflow + key naming patterns
- Dynamic localization (format specifiers)
- **→ Routes to**: `Anytype/Sources/PresentationLayer/Common/LOCALIZATION_GUIDE.md` for comprehensive details

**Location**: `.claude/skills/localization-developer/SKILL.md`

---

### 3. **code-generation-developer** (Smart Router)
**Purpose**: Routes to code generation workflows (SwiftGen, Sourcery, Feature Flags, Protobuf)

**Auto-activates when**:
- Running or discussing `make generate`
- Adding feature flags
- Working with generated files
- Using keywords: swiftgen, sourcery, feature flags, FeatureFlags

**Provides**:
- Critical rules (NEVER edit generated files, always run make generate)
- Feature flags quick workflow (define → generate → use)
- When to run make generate table
- Quick SwiftGen, Sourcery, Middleware overviews
- **→ Routes to**: `Modules/AnytypeCore/CODE_GENERATION_GUIDE.md` for comprehensive details

**Location**: `.claude/skills/code-generation-developer/SKILL.md`

---

### 4. **design-system-developer** (Smart Router)
**Purpose**: Routes to design system patterns (icons, typography, colors, Figma-to-code)

**Auto-activates when**:
- Working with icons or typography
- Using keywords: icon, typography, design system, figma
- Editing files in DesignSystem/ or Assets.xcassets
- Discussing colors or UI components

**Provides**:
- Critical rules (use design system constants, spacing formula)
- Icon quick reference (x18/x24/x32/x40)
- Typography mapping (Figma → Swift) with caption exceptions
- Critical spacing formula: `Next.Y - (Current.Y + Current.Height)`
- **→ Routes to**: `DESIGN_SYSTEM_MAPPING.md` & `TYPOGRAPHY_MAPPING.md` for comprehensive details

**Location**: `.claude/skills/design-system-developer/SKILL.md`

---

### 5. **skills-manager** (Smart Router - Meta!)
**Purpose**: Routes to skills/hooks management and troubleshooting

**Auto-activates when**:
- Discussing skill activation or hooks
- Troubleshooting why a skill didn't activate
- Using keywords: skill activation, hook, troubleshoot, fine-tune, add keyword

**Provides**:
- Critical rules for managing the system
- Quick diagnostic workflows
- How to add/remove keywords
- Health check commands
- Common issues and fixes
- **→ Routes to**: `.claude/SKILLS_MANAGEMENT_GUIDE.md` for comprehensive management

**Location**: `.claude/skills/skills-manager/SKILL.md`

**Note**: This is a meta-skill - it helps you manage the skills system itself!

---

### 6. **code-review-developer** (Smart Router)
**Purpose**: Routes to code review guidelines for conducting thorough, actionable reviews

**Auto-activates when**:
- Reviewing pull requests or code changes
- Keywords: code review, PR review, review code, pull request, approve, issues
- Discussing review comments or feedback

**Provides**:
- Critical rules (be lean, no praise sections, no design suggestions)
- Quick review workflow (read changes → check CLAUDE.md → find issues → format review)
- Common analysis mistakes (assuming unused code, not understanding flags)
- Review sections format (bugs, best practices, performance, security)
- **→ Routes to**: `.claude/CODE_REVIEW_GUIDE.md` for complete review standards
- **→ Routes to**: `.github/workflows/pr-review-automation.md` for CI/GitHub Actions integration

**Location**: `.claude/skills/code-review-developer/SKILL.md`

---

### 7. **tests-developer** (Smart Router)
**Purpose**: Routes to testing patterns and practices for writing unit tests and creating mocks

**Auto-activates when**:
- Writing or discussing unit tests
- Creating test mocks or mock helpers
- Working with test files (AnyTypeTests/)
- Keywords: test, testing, mock, unit test, @Test, @Suite, XCTest, edge case, TDD

**Provides**:
- Critical rules (use Swift Testing for new tests, test edge cases, update tests when refactoring)
- Swift Testing vs XCTest patterns
- Edge case testing checklist
- Mock helper patterns (in-file extensions vs separate mocks)
- Dependency injection in tests (Factory pattern)
- Testing protobuf models
- When to make methods internal for testing
- **→ Routes to**: `IOS_DEVELOPMENT_GUIDE.md` for comprehensive testing architecture

**Location**: `.claude/skills/tests-developer/SKILL.md`

---

### 8. **feature-toggle-developer** (Smart Router)
**Purpose**: Routes to feature toggle removal workflows and unused code cleanup

**Auto-activates when**:
- Removing or enabling feature flags
- Discussing feature toggles or cleanup
- Keywords: remove toggle, feature flag, cleanup, unused code, defaultValue, FeatureFlags.

**Provides**:
- Critical rules for systematic toggle removal
- Automated cleanup detection
- Unused code identification patterns
- Step-by-step removal workflow
- Common mistakes to avoid

**Location**: `.claude/skills/feature-toggle-developer/SKILL.md`

---

### 9. **analytics-developer** (Smart Router)
**Purpose**: Routes to analytics event logging and route tracking patterns

**Auto-activates when**:
- Adding analytics events or route tracking
- Working with AnytypeAnalytics
- Keywords: analytics, logEvent, route tracking, AnalyticsConstants, track route

**Provides**:
- Critical rules for event logging
- Route tracking enum patterns
- AnalyticsConstants organization
- Event properties naming
- **→ Routes to**: `ANALYTICS_PATTERNS.md` for comprehensive patterns

**Location**: `.claude/skills/analytics-developer/SKILL.md`

---

## 📊 Progressive Disclosure Architecture

This documentation system follows the principle of **progressive disclosure** - load only what's needed, when it's needed.

### 3-Level Information Architecture

```
Level 1: CLAUDE.md
├─ Quick start + critical rules
├─ Essential commands
├─ Quick workflows with "→ See [GUIDE]" pointers
└─ Links to Level 2 (Skills) and Level 3 (Specialized Docs)

Level 2: Skills
├─ Critical rules worth duplicating
├─ Quick reference patterns
├─ Decision trees and checklists
├─ Common mistakes
└─ "→ Routes to" pointers to Level 3

Level 3: Specialized Guides (Comprehensive documentation)
├─ IOS_DEVELOPMENT_GUIDE.md
├─ LOCALIZATION_GUIDE.md
├─ CODE_GENERATION_GUIDE.md
├─ SKILLS_MANAGEMENT_GUIDE.md [meta!]
├─ DESIGN_SYSTEM_MAPPING.md
└─ TYPOGRAPHY_MAPPING.md
```

### Why This Architecture?

**Single Source of Truth**: Each piece of knowledge lives in exactly one place
- Critical rules duplicated in skills for visibility
- Everything else lives in Level 3 specialized docs
- Skills act as routers with clear navigation paths

**Context Token Efficiency**: Load only what's needed
- CLAUDE.md: Always loaded, lightweight overview
- Skills: Auto-activated based on context
- Specialized docs: Referenced when deep knowledge needed

**Maintainability**: Easy to update without duplication
- Update specialized docs once
- Skills reference docs, don't duplicate content
- Clear separation of concerns

## 🔄 How Auto-Activation Works

### Automatic Suggestion

When you start a conversation, the system:

1. **Analyzes your prompt** for keywords and patterns
2. **Checks file paths** if you're editing files
3. **Matches against skill rules** (defined in `.claude/hooks/skill-rules.json`)
4. **Suggests relevant skills** with a formatted message:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 SKILL ACTIVATION CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📚 Relevant Skill: ios-dev-guidelines
   Description: Swift/iOS development patterns, architecture, and best practices

💡 Consider using these skills if they're relevant to this task.
   You can manually load a skill by reading its SKILL.md file.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Manual Loading

You can also manually load a skill:

```
Read the file .claude/skills/ios-dev-guidelines/SKILL.md
```

## 📂 Directory Structure

```
.claude/skills/
├── README.md (this file)
│
├── ios-dev-guidelines/
│   └── SKILL.md (smart router)
│
├── localization-developer/
│   └── SKILL.md (smart router)
│
├── code-generation-developer/
│   └── SKILL.md (smart router)
│
├── design-system-developer/
│   └── SKILL.md (smart router)
│
├── skills-manager/
│   └── SKILL.md (smart router - meta!)
│
├── code-review-developer/
│   └── SKILL.md (smart router)
│
├── tests-developer/
│   └── SKILL.md (smart router)
│
├── feature-toggle-developer/
│   └── SKILL.md (smart router)
│
└── analytics-developer/
    └── SKILL.md (smart router)
```

**Note**: Resource files removed in favor of specialized documentation at Level 3.

## ⚙️ Configuration

### Skill Rules

**Location**: `.claude/hooks/skill-rules.json`

Defines activation patterns for each skill:
- **Keywords**: Terms that trigger skill suggestion
- **Intent Patterns**: Regex patterns for actions (e.g., "create.*feature")
- **File Triggers**: Path patterns that activate skills
- **Content Patterns**: Code patterns that match skills

### Example Configuration

```json
{
  "skills": {
    "ios-dev-guidelines": {
      "type": "domain",
      "priority": "high",
      "promptTriggers": {
        "keywords": ["swift", "viewmodel", "refactor"],
        "intentPatterns": [
          "(create|add).*?(view|viewmodel|coordinator)"
        ]
      },
      "fileTriggers": {
        "pathPatterns": ["**/*.swift"],
        "contentPatterns": ["class.*ViewModel", "@Published"]
      }
    }
  }
}
```

## 🪝 Hooks Integration

The skills system uses hooks for auto-activation:

### UserPromptSubmit Hook

**File**: `.claude/hooks/skill-activation-prompt.sh`

- Runs before Claude sees your message
- Analyzes prompt and file context
- Injects skill suggestions into conversation
- Logs activations to `.claude/logs/skill-activations.log`

### Activation Flow

```
User Prompt → Hook Analyzes → Matches Skills → Suggests to Claude
```

## 🎨 Best Practices

### For Users

1. **Trust the suggestions** - If a skill is suggested, it's likely relevant
2. **Don't manually load skills repeatedly** - Auto-activation handles it
3. **Use specific keywords** - Helps trigger the right skills
4. **Check activation logs** - See which skills were suggested

### For Skill Authors (Smart Router Pattern)

1. **Keep SKILL.md** - Skills are routers, not comprehensive guides
2. **Add clear "Critical Rules" section** - Worth duplicating for visibility
3. **Provide quick reference only** - Tables, examples, common patterns
4. **Point to Level 3 docs** - Use "**→ Routes to**: path/to/GUIDE.md" pattern
5. **No resource files** - All comprehensive content lives in Level 3 specialized docs
6. **Update skill-rules.json** - Add relevant keywords and patterns

## 📊 Monitoring

### Activation Logs

**Location**: `.claude/logs/skill-activations.log`

Shows which skills were suggested and when:

```
[2025-01-30 14:23:45] Analyzing prompt...
  ✓ Matched: ios-dev-guidelines
  Suggested skills: ios-dev-guidelines
```

### Tool Usage Logs

**Location**: `.claude/logs/tool-usage.log`

Tracks file modifications:

```
[2025-01-30 14:24:12] Edit: Anytype/Sources/PresentationLayer/ChatView.swift
  └─ Area: UI/Presentation, File: ...
```

## 🚀 Usage Examples

### Example 1: Adding a Feature Flag

**Your Prompt**: "Add a feature flag for the new chat interface"

**Auto-Activated**: `code-generation-developer`

**Why**: Keyword "feature flag" matches code-generation-developer rules

**What You Get**: Guidance on:
- Where to add FeatureDescription
- How to run `make generate`
- How to use FeatureFlags in code

### Example 2: Implementing Figma Design

**Your Prompt**: "Implement the empty state design with icons and typography"

**Auto-Activated**: `design-system-developer`

**Why**: Keywords "icons", "typography" match design-system-developer

**What You Get**: Guidance on:
- Icon size selection
- Typography mapping
- Spacing extraction from Figma
- Color constants usage

### Example 3: Refactoring ViewModel

**Your Prompt**: "Refactor ChatViewModel to use async/await"

**Auto-Activated**: `ios-dev-guidelines`

**Why**: Keywords "ViewModel", "async/await", "refactor" match ios-dev-guidelines

**What You Get**: Guidance on:
- ViewModel patterns
- Async/await best practices
- Property organization
- Code formatting rules

## 🔧 Troubleshooting

### Skills Not Activating

**Problem**: Expected skill not suggested

**Solutions**:
1. Check `.claude/logs/skill-activations.log` for activation attempts
2. Verify keywords in your prompt match `skill-rules.json`
3. Use more specific keywords (e.g., "localization" instead of "text")
4. Manually load skill if auto-activation fails

### Wrong Skill Suggested

**Problem**: Irrelevant skill suggested

**Solutions**:
1. Ignore the suggestion (it's just a recommendation)
2. Be more specific in your prompt
3. Update `skill-rules.json` to refine matching rules

### Multiple Skills Suggested

**Problem**: Too many skills suggested

**Solution**: This is normal - system limits to 2 skills max (configured in skill-rules.json)

## 📚 Related Documentation

- **Hooks System**: `.claude/hooks/README.md` - How hooks work
- **CLAUDE.md**: Main project documentation - Quick start and workflows
- **skill-rules.json**: Skill activation configuration

## 🎓 Learning Path

**New to the project?** Read skills in this order:

1. **ios-dev-guidelines** - Understand Swift/iOS patterns
2. **localization-developer** - Learn localization workflow
3. **code-generation-developer** - Master `make generate` workflows
4. **design-system-developer** - Understand design system usage

## 🔄 Updating Skills

### Adding a New Skill

1. Create directory: `.claude/skills/new-skill-name/`
2. Create `SKILL.md` with clear structure
3. Add resources to `resources/` subdirectory
4. Update `skill-rules.json` with activation patterns
5. Test activation with sample prompts
6. Update this README

### Modifying Existing Skill

1. Edit the SKILL.md file
2. Keep under 500 lines (move details to resources)
3. Update activation rules if keywords change
4. Test that auto-activation still works

## 📖 Smart Router Skill Template

When creating a new skill, follow this **smart router** pattern:

```markdown
# Skill Name (Smart Router)

## Purpose
Context-aware routing to [topic]. Helps you navigate [what it helps with].

## When Auto-Activated
- [File types or contexts]
- Keywords: [keyword1, keyword2, ...]

## 🚨 CRITICAL RULES (NEVER VIOLATE)

1. Must-follow rule 1 (worth duplicating for visibility)
2. Must-follow rule 2
3. Must-follow rule 3

## 📋 Quick Reference

[Tables, examples, common patterns - QUICK ONLY]

### Example Pattern
```swift
// Quick code example
```

## 🎯 Quick Workflow

1. Step 1
2. Step 2
3. Step 3

## ⚠️ Common Mistakes

### Mistake 1
```swift
// ❌ WRONG
...

// ✅ CORRECT
...
```

## 📚 Complete Documentation

**Full Guide**: `path/to/SPECIALIZED_GUIDE.md`

For comprehensive coverage of:
- Detailed topic 1
- Detailed topic 2
- Complete examples
- Troubleshooting

## ✅ Checklist

- [ ] Item 1
- [ ] Item 2

## 🔗 Related Skills & Docs

- **other-skill** → `path/to/OTHER_GUIDE.md` - How they relate
- **another-skill** → How they integrate

---

**Navigation**: This is a smart router. For deep technical details, always refer to `SPECIALIZED_GUIDE.md`.
```

**Key principles**:
- ~100-200 lines total
- Critical rules duplicated for visibility
- Quick reference only (no comprehensive guides)
- Clear "→ Routes to" pointers to Level 3 docs
- No resource files - all comprehensive content in Level 3

## Summary

The skills system provides:
- ✅ **Progressive disclosure architecture** - 3 levels of documentation
- ✅ **Automatic skill suggestions** based on context - Zero friction
- ✅ **6 smart router skills** - Lightweight and fast
- ✅ **Hook-based activation** - Analyzed prompts trigger relevant skills
- ✅ **Context token efficiency** - Load only what's needed
- ✅ **Single Source of Truth** - Each piece of knowledge lives in one place
- ✅ **Self-documenting** - skills-manager skill helps you manage the system
- ✅ **Logging and monitoring** for debugging

**Start using it**: Just work normally - skills auto-activate when relevant and route you to comprehensive docs!

**Need help managing the system?** The skills-manager skill auto-activates when you discuss troubleshooting or fine-tuning!