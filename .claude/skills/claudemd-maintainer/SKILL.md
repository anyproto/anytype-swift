# CLAUDE.md Maintainer (Smart Router)

## Purpose
Context-aware guidance for maintaining and improving CLAUDE.md files. Helps ensure the file stays effective, concise, and follows best practices for LLM instruction files.

## When Auto-Activated
- Editing or discussing CLAUDE.md
- Keywords: claude.md, project instructions, onboarding claude, context file
- Discussing documentation structure for AI assistants

## 🚨 CRITICAL RULES

1. **Keep under 300 lines** - Research shows LLMs handle ~150-200 instructions reliably; performance degrades with more
2. **Never auto-generate** - Manually craft each line; auto-generated content often contains noise
3. **Universal applicability only** - Remove task-specific or narrow-scope guidance
4. **File references over code snippets** - Code embeds become outdated; paths stay accurate

## 📊 Effective CLAUDE.md Principles

### What To Include (WHAT, WHY, HOW)
| Category | Include | Avoid |
|----------|---------|-------|
| **Stack** | Technologies, architecture overview | Exhaustive dependency lists |
| **Critical Rules** | Must-follow behaviors (consolidated) | Duplicate rules across sections |
| **Quick Commands** | Essential build/run commands | Full command reference |
| **File References** | Paths to detailed guides | Embedded code that can outdated |
| **Common Mistakes** | Documented actual failures | Hypothetical warnings |

### What To Exclude
- **Code style guidelines** → Use linters instead (SwiftFormat, ESLint, etc.)
- **Exhaustive command references** → Point to tool documentation
- **Task-specific instructions** → Put in skills or separate docs
- **Code snippets** → Use `file:line` references instead

## 🎯 Progressive Disclosure Pattern

```
Level 1: CLAUDE.md (~100-150 lines ideal, max 300)
├─ Critical rules (must-follow behaviors)
├─ Quick start (essential commands only)
├─ High-level architecture
└─ Pointers to Level 2 and 3

Level 2: Skills (.claude/skills/)
├─ Domain-specific quick references
├─ Decision trees and workflows
└─ "→ Routes to" comprehensive docs

Level 3: Specialized Guides
├─ Complete technical documentation
├─ Full examples and edge cases
└─ Troubleshooting guides
```

## 📋 Quick Audit Checklist

When reviewing CLAUDE.md:

- [ ] **Line count under 300?** (`wc -l CLAUDE.md`)
- [ ] **No duplicate rules?** (Search for repeated concepts)
- [ ] **Code snippets minimized?** (Replace with file path references)
- [ ] **Narrow-scope items removed?** (Move to skills)
- [ ] **Critical rules consolidated?** (Single authoritative location)
- [ ] **File references current?** (Paths still valid)
- [ ] **Common mistakes documented?** (Actual failures, not hypotheticals)

## 🔄 Optimization Workflow

### Reducing Line Count

1. **Find duplicates**: Search for repeated concepts
   ```bash
   # Find potential duplicates
   grep -n "NEVER" CLAUDE.md | head -20
   ```

2. **Consolidate rules**: Move all critical rules to one section

3. **Replace code with references**:
   ```markdown
   # ❌ Before (takes 10+ lines)
   ### Typography
   ```swift
   AnytypeText("Title", style: .uxTitle1Semibold)
   AnytypeText("Body", style: .bodyRegular)
   ```

   # ✅ After (1 line)
   **Typography** → `path/to/TYPOGRAPHY_MAPPING.md`
   ```

4. **Move narrow guidance to skills**: If it applies to < 20% of tasks, it's a skill

### Adding New Guidance

**Before adding, ask:**
1. Does this apply to most tasks? (If no → skill or specialized doc)
2. Is there existing guidance? (If yes → consolidate, don't duplicate)
3. Can a linter/tool enforce this? (If yes → use the tool instead)
4. Will this code example outdated quickly? (If yes → use file reference)

## ⚠️ Common Mistakes

### Accumulating Hotfixes
```markdown
# ❌ WRONG - Adding one-off rules
### Special Note (2025-01-15)
Remember to always check X when doing Y...

# ✅ CORRECT - Add to appropriate skill or remove
```

### Duplicating Rules
```markdown
# ❌ WRONG - Same rule in 3 places
## Critical Rules: NEVER add AI signatures
## Pre-Commit: NO AI signatures
## PR Format: No "Generated with Claude"

# ✅ CORRECT - Single consolidated rule
## Critical Rules
2. **NEVER add AI signatures anywhere** - No Co-Authored-By, no emoji signatures
```

### Embedding Code That Outdates
```markdown
# ❌ WRONG - Code will outdated
```swift
Image(asset: .X32.qrCode)  // What if asset name changes?
```

# ✅ CORRECT - File reference stays accurate
**Icons** → `Modules/Assets/.../ImageAsset.swift:45`
```

## 📚 Research & Best Practices

**Source**: Based on industry practices and LLM behavior research

### Key Findings
- LLMs handle ~150-200 instructions reliably
- Performance degrades with additional instructions
- Irrelevant context may be ignored entirely (Claude adds "this context may or may not be relevant")
- Code snippets in docs become maintenance burden
- Progressive disclosure reduces context overhead

### Recommended Metrics
| Metric | Target | Max |
|--------|--------|-----|
| Total lines | 100-150 | 300 |
| Code blocks | 2-4 | 6 |
| Critical rules | 3-5 | 10 |
| Sections | 6-8 | 12 |

## 🔗 Related

- `.claude/skills/README.md` - Skills system overview
- `.claude/skills/skills-manager/SKILL.md` - Managing the skills system
- Progressive disclosure architecture documentation

---

**Navigation**: This skill helps maintain CLAUDE.md quality. For skills system management, see `skills-manager`. For adding new skills, see `.claude/skills/README.md`.
