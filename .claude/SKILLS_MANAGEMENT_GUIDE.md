# Skills & Hooks Management Guide

Complete guide to managing, troubleshooting, and fine-tuning the progressive disclosure documentation system.

*Last updated: 2025-01-30*

## Overview

This guide explains how to manage the **automated documentation system** that suggests relevant skills based on your prompts and file context.

## 🎯 System Components

### 1. Hooks (The Automation Layer)

**What**: Shell scripts that run automatically at specific events
**Where**: `.claude/hooks/`
**Purpose**: Analyze prompts and suggest relevant skills

**The 3 hooks**:
- `skill-activation-prompt.sh` - **UserPromptSubmit event** - Analyzes your prompt BEFORE Claude sees it, suggests relevant skills
- `post-tool-use-tracker.sh` - **PostToolUse event** - Tracks file edits after Claude uses Edit/Write tools
- `swiftformat-auto.sh` - **Stop event** - Auto-formats Swift files after Claude finishes

**Configuration**:
- `skill-rules.json` - Defines keywords and patterns for skill matching

### 2. Skills (The Documentation Routers)

**What**: Short markdown files (~100-200 lines) that act as "smart routers"
**Where**: `.claude/skills/*/SKILL.md`
**Purpose**: Provide critical rules + quick patterns + point to comprehensive guides

**The 4 skills**:
1. `ios-dev-guidelines` - Swift/iOS patterns → `IOS_DEVELOPMENT_GUIDE.md`
2. `localization-developer` - Localization workflow → `LOCALIZATION_GUIDE.md`
3. `code-generation-developer` - Feature flags, make generate → `CODE_GENERATION_GUIDE.md`
4. `design-system-developer` - Icons, typography, colors → `DESIGN_SYSTEM_MAPPING.md`

### 3. Specialized Guides (The Deep Knowledge)

**What**: Comprehensive documentation files (300-550 lines each)
**Where**: Various locations in the project
**Purpose**: Single source of truth for deep technical knowledge

## 🔄 How the System Works

### The Activation Flow

```
You type: "Add a feature flag for chat"
    ↓
[UserPromptSubmit hook runs - happens automatically]
    ↓
skill-activation-prompt.sh executes
    ↓
Reads skill-rules.json
    ↓
Checks keywords: "feature flag" ✓ matches code-generation-developer
    ↓
Outputs suggestion (Claude Code displays this):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 SKILL ACTIVATION CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📚 Relevant Skill: code-generation-developer
   Description: Smart router to code generation...

💡 Consider using these skills if relevant to this task.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    ↓
Claude sees the suggestion and can read the skill
    ↓
Claude uses skill to route you to CODE_GENERATION_GUIDE.md if needed
```

### What Gets Matched

**skill-rules.json** contains matching rules for each skill:

```json
{
  "skills": {
    "code-generation-developer": {
      "promptTriggers": {
        "keywords": ["feature flag", "make generate", "swiftgen"],
        "intentPatterns": ["(create|add|enable).*?(feature flag|flag)"]
      },
      "fileTriggers": {
        "pathPatterns": ["**/FeatureDescription+Flags.swift"],
        "contentPatterns": ["FeatureFlags\\."]
      }
    }
  }
}
```

**Matching logic**:
1. **Keywords**: Simple word/phrase matching in your prompt
2. **Intent patterns**: Regex patterns for detecting user intent (e.g., "add.*feature flag")
3. **File path patterns**: Matches when editing specific files
4. **Content patterns**: Matches when file contains specific code patterns

## 🔧 Troubleshooting & Fine-Tuning

### Scenario 1: Skill Didn't Activate (False Negative)

**Symptom**: You expected a skill to activate but it didn't

**How to diagnose**:

1. **Check the activation logs**:
   ```bash
   tail -20 .claude/logs/skill-activations.log
   ```

   Look for your prompt and see what matched:
   ```
   [2025-01-30 14:23:45] Analyzing prompt: "export SVG from Figma"
     No matches found
   ```

2. **Check current keywords for the expected skill**:
   ```bash
   cat .claude/hooks/skill-rules.json | jq '.skills."design-system-developer".promptTriggers.keywords'
   ```

3. **Identify missing keywords**:
   - Your prompt: "export SVG from Figma"
   - Current keywords: icon, figma, typography, color
   - Missing: "svg", "export"

**How to fix**:

**Ask Claude**:
```
"The design-system skill didn't activate when I asked about exporting SVG.
Can you add 'svg' and 'export' as keywords?"
```

**Or edit yourself**:
```bash
# Edit .claude/hooks/skill-rules.json
# Find design-system-developer section
# Add to keywords array:
"keywords": [
  "icon",
  "figma",
  "svg",      // ← Add this
  "export"    // ← Add this
]
```

### Scenario 2: Skill Activated When Not Relevant (False Positive)

**Symptom**: A skill activates too often or in wrong contexts

**Example**: Every time you mention "text", localization-developer activates

**How to diagnose**:

1. **Check which keyword is causing it**:
   ```bash
   cat .claude/hooks/skill-rules.json | jq '.skills."localization-developer".promptTriggers.keywords'
   ```

   Result shows: `"text"` is in the keywords array

2. **Determine if keyword is too broad**:
   - "text" matches: "add text to UI", "text file", "raw text", etc.
   - Too broad! Should be more specific

**How to fix**:

**Ask Claude**:
```
"The word 'text' in localization-developer is too broad.
Replace it with 'localized text' and 'user-facing text'."
```

**Or edit yourself**:
```bash
# Edit .claude/hooks/skill-rules.json
# Before:
"keywords": ["localization", "text", "Loc."]

# After:
"keywords": ["localization", "localized text", "user-facing text", "Loc."]
```

### Scenario 3: Testing Changes

After modifying `skill-rules.json`, verify it works:

**Method 1: Try the prompt again in conversation**
```
"Add an SVG icon from Figma"
# Should now trigger design-system-developer
```

**Method 2: Check activation logs**
```bash
tail .claude/logs/skill-activations.log
# Look for: Matched: design-system-developer
```

**Method 3: Manual test (advanced)**
```bash
echo '{"prompt":"Add SVG from Figma"}' | .claude/hooks/skill-activation-prompt.sh
# Should output skill suggestion
```

## 📋 Common Adjustments

### Add a Keyword

**When**: You use a term that should trigger a skill but doesn't

**Example**: Add "component" to ios-dev-guidelines

```json
// .claude/hooks/skill-rules.json
{
  "skills": {
    "ios-dev-guidelines": {
      "promptTriggers": {
        "keywords": [
          "swift",
          "swiftui",
          "viewmodel",
          "component"  // ← Add here
        ]
      }
    }
  }
}
```

**Ask Claude**: "Add 'component' as a keyword for ios-dev-guidelines"

### Remove a Too-Broad Keyword

**When**: A skill activates too often due to a common word

**Example**: Remove "text" from localization-developer

```json
// Before
"keywords": ["localization", "text", "Loc."]

// After
"keywords": ["localization", "Loc."]
```

**Ask Claude**: "Remove 'text' from localization-developer keywords, it's too broad"

### Add an Intent Pattern (Advanced)

**When**: You want to match user actions/intents, not just keywords

**Example**: Trigger design-system when implementing from Figma

```json
{
  "skills": {
    "design-system-developer": {
      "promptTriggers": {
        "intentPatterns": [
          "(add|create|use).*?(icon|image|asset)",
          "(implement|build|create).*?from figma"  // ← Add regex pattern
        ]
      }
    }
  }
}
```

**Regex explanation**:
- `(implement|build|create)` - Matches any of these action words
- `.*?` - Matches any characters in between (non-greedy)
- `from figma` - Matches this phrase

**Ask Claude**: "When I say 'implement X from Figma', trigger design-system skill"

### Adjust Priority

**When**: Multiple skills match, you want to control which is suggested first

```json
{
  "skills": {
    "ios-dev-guidelines": {
      "priority": "high"    // Suggested first
    },
    "design-system-developer": {
      "priority": "medium"  // Suggested second
    }
  }
}
```

**Values**: `"high"`, `"medium"`, `"low"`

## 🔍 Diagnostic Commands

### View Activation Logs

```bash
# Last 20 activations
tail -20 .claude/logs/skill-activations.log

# Watch in real-time
tail -f .claude/logs/skill-activations.log

# Search for specific skill
grep "design-system-developer" .claude/logs/skill-activations.log
```

**Log format**:
```
[2025-01-30 14:23:45] Analyzing prompt: "add feature flag"
  ✓ Matched: code-generation-developer
  Suggested skills: code-generation-developer
```

### View Current Configuration

```bash
# All skills configuration
cat .claude/hooks/skill-rules.json

# Pretty print
cat .claude/hooks/skill-rules.json | jq .

# Specific skill keywords
cat .claude/hooks/skill-rules.json | jq '.skills."ios-dev-guidelines".promptTriggers.keywords'

# All keywords for all skills
cat .claude/hooks/skill-rules.json | jq '.skills[].promptTriggers.keywords'
```

### Test Skill Activation Manually

```bash
# Test a specific prompt
echo '{"prompt":"add a feature flag"}' | .claude/hooks/skill-activation-prompt.sh

# Should output:
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# 🎯 SKILL ACTIVATION CHECK
# ...
# 📚 Relevant Skill: code-generation-developer
```

### Verify Hook Permissions

```bash
# Hooks should be executable
ls -l .claude/hooks/*.sh

# Should show: -rwxr-xr-x
# If not, fix with:
chmod +x .claude/hooks/*.sh
```

## 🎓 Advanced: Understanding skill-rules.json

### Full Structure

```json
{
  "skills": {
    "skill-name": {
      "type": "domain",                    // Type of skill
      "priority": "high",                  // Suggestion priority
      "description": "...",                // Shown in activation message
      "promptTriggers": {
        "keywords": [...],                 // Simple word matching
        "intentPatterns": [...]            // Regex for intent matching
      },
      "fileTriggers": {
        "pathPatterns": [...],             // File path glob patterns
        "contentPatterns": [...]           // Code pattern matching
      }
    }
  },
  "config": {
    "maxSkillsPerPrompt": 2,              // Max skills to suggest at once
    "logActivations": true,               // Enable logging
    "logPath": ".claude/logs/skill-activations.log"
  }
}
```

### Keyword Matching (Simple)

**Keywords**: Array of words/phrases to match in prompt

```json
"keywords": [
  "swift",           // Matches: "swift code", "Swift programming"
  "feature flag",    // Matches: "add a feature flag"
  "Loc."            // Matches: "use Loc.title"
]
```

**Case insensitive**: "Swift" = "swift" = "SWIFT"

### Intent Pattern Matching (Advanced)

**Intent patterns**: Regex for matching user actions/intents

```json
"intentPatterns": [
  "(create|add|implement).*?(view|viewmodel|coordinator)",
  "(how to|best practice).*?(swift|ios|architecture)"
]
```

**Examples**:
- `"(create|add).*?view"` matches:
  - "create a new view"
  - "add view for settings"
  - "create chat view"

**Regex cheatsheet**:
- `(word1|word2)` - Match either word
- `.*?` - Match any characters (non-greedy)
- `\\.` - Match literal dot (escaped)
- `\\(` - Match literal parenthesis (escaped)

### File Trigger Matching

**Path patterns**: Glob patterns for file paths

```json
"pathPatterns": [
  "**/*.swift",                    // Any .swift file
  "**/PresentationLayer/**",       // Any file in PresentationLayer
  "**/FeatureDescription+Flags.swift"  // Specific file
]
```

**Content patterns**: Regex for code content

```json
"contentPatterns": [
  "class.*ViewModel",              // Classes ending in ViewModel
  "@Published",                    // @Published property wrapper
  "FeatureFlags\\.",              // FeatureFlags usage
  "import SwiftUI"                 // SwiftUI import
]
```

## 🛠️ Creating a New Skill

### When to Create a New Skill

Create a new skill when:
- ✅ You have a distinct domain of knowledge (e.g., testing, CI/CD, performance)
- ✅ There's comprehensive documentation to route to
- ✅ The topic comes up frequently
- ❌ DON'T create for one-off topics or rarely-used info

### Steps to Create a New Skill

**1. Create the specialized guide** (Level 3):
```bash
# Example: Create testing guide
touch Anytype/Sources/TESTING_GUIDE.md
# Fill with comprehensive testing documentation
```

**2. Create the skill** (Level 2):
```bash
mkdir -p .claude/skills/testing-developer
touch .claude/skills/testing-developer/SKILL.md
```

**3. Use the smart router template**:
```markdown
# Testing Developer (Smart Router)

## Purpose
Context-aware routing to testing patterns and practices.

## When Auto-Activated
- Working with test files
- Keywords: test, mock, unittest, xctest

## 🚨 CRITICAL RULES
1. ALWAYS update tests when refactoring
2. NEVER skip test execution

## 📋 Quick Reference
[Quick testing patterns]

## 📚 Complete Documentation
**Full Guide**: `Anytype/Sources/TESTING_GUIDE.md`

---
**Navigation**: This is a smart router. For details, refer to TESTING_GUIDE.md.
```

**4. Add to skill-rules.json**:
```json
{
  "skills": {
    "testing-developer": {
      "type": "domain",
      "priority": "medium",
      "description": "Smart router to testing guide. Unit tests, mocks, XCTest patterns",
      "promptTriggers": {
        "keywords": ["test", "unittest", "mock", "xctest", "testing"],
        "intentPatterns": ["(write|add|create).*?test"]
      },
      "fileTriggers": {
        "pathPatterns": ["**/*Tests.swift", "**/Mocks/**"],
        "contentPatterns": ["XCTestCase", "import XCTest"]
      }
    }
  }
}
```

**5. Test the new skill**:
```bash
echo '{"prompt":"write unit tests for this"}' | .claude/hooks/skill-activation-prompt.sh
# Should suggest: testing-developer
```

## 🚨 Common Issues & Fixes

### Issue: Hook Not Executing

**Symptoms**: No skill suggestions appear, logs empty

**Diagnosis**:
```bash
# Check if hook exists
ls -l .claude/hooks/skill-activation-prompt.sh

# Check if executable
# Should show: -rwxr-xr-x
```

**Fix**:
```bash
chmod +x .claude/hooks/skill-activation-prompt.sh
```

### Issue: Invalid JSON in skill-rules.json

**Symptoms**: Hook fails silently, no activations

**Diagnosis**:
```bash
# Validate JSON
jq . .claude/hooks/skill-rules.json

# If error shown, there's invalid JSON
```

**Fix**:
- Check for missing commas
- Check for trailing commas in arrays/objects
- Use a JSON validator or `jq` to find the error
- Ask Claude: "Validate and fix my skill-rules.json"

### Issue: Skill Activates But Content Not Helpful

**Symptoms**: Right skill activates but doesn't help

**Diagnosis**: The skill might be outdated or routing to wrong guide

**Fix**:
1. Check the skill file: `cat .claude/skills/SKILL-NAME/SKILL.md`
2. Verify it points to the correct guide
3. Check if the guide exists and is up-to-date
4. Ask Claude: "Update the X skill to route to Y guide"

### Issue: Too Many Skills Suggested

**Symptoms**: Multiple skills activate for same prompt

**Diagnosis**: Keywords overlap between skills

**Fix**:
1. Check `maxSkillsPerPrompt` in skill-rules.json config
2. Make keywords more specific
3. Adjust priorities so most relevant skill appears first

```json
"config": {
  "maxSkillsPerPrompt": 2  // Limit to 2 skills max
}
```

## 📊 Monitoring & Maintenance

### Regular Checks

**Weekly**:
- Review activation logs for false positives/negatives
- Check if new common terms should be added as keywords

```bash
# See most recent activations
tail -50 .claude/logs/skill-activations.log

# Count activations by skill
grep "Matched:" .claude/logs/skill-activations.log | sort | uniq -c
```

**Monthly**:
- Review and update skill content
- Verify specialized guides are current
- Clean up outdated keywords

### Log Rotation

Logs can grow large over time:

```bash
# Archive old logs
cd .claude/logs
tar -czf logs-$(date +%Y%m%d).tar.gz skill-activations.log
rm skill-activations.log
```

## 🎯 Quick Reference

### I Want To...

**Add a keyword**:
```bash
# Ask Claude:
"Add 'architecture' to ios-dev-guidelines keywords"

# Or edit:
vim .claude/hooks/skill-rules.json
# Add to keywords array
```

**See what activated**:
```bash
tail -20 .claude/logs/skill-activations.log
```

**Test a prompt**:
```bash
echo '{"prompt":"your prompt here"}' | .claude/hooks/skill-activation-prompt.sh
```

**Check current keywords**:
```bash
cat .claude/hooks/skill-rules.json | jq '.skills."SKILL-NAME".promptTriggers.keywords'
```

**Fix permissions**:
```bash
chmod +x .claude/hooks/*.sh
```

**Validate JSON**:
```bash
jq . .claude/hooks/skill-rules.json
```

## 📚 Related Documentation

- `.claude/hooks/README.md` - Complete hooks system documentation
- `.claude/skills/README.md` - Skills system overview
- `CLAUDE.md` - Main project documentation (Level 1)

## 💡 Pro Tips

1. **Start broad, then narrow**: Add broad keywords first, remove if too many false positives
2. **Use logs for data**: Check logs regularly to see what's activating
3. **Ask Claude for help**: Let Claude analyze logs and suggest improvements
4. **Test changes**: Always test after modifying skill-rules.json
5. **Document custom keywords**: Add comments in skill-rules.json explaining why you added specific terms

## ✅ Checklist: System Health

- [ ] All hooks are executable (`ls -l .claude/hooks/*.sh` shows `rwx`)
- [ ] skill-rules.json is valid JSON (`jq . .claude/hooks/skill-rules.json`)
- [ ] Logs directory exists (`.claude/logs/`)
- [ ] Recent activations visible in logs (`tail .claude/logs/skill-activations.log`)
- [ ] All 4 skills exist and are readable
- [ ] Specialized guides exist and link correctly from skills

---

**Need help?** Just ask: "Check my skills system health" or "Help me troubleshoot skill activation"
