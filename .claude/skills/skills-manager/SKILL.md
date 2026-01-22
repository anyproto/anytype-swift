---
name: skills-manager
description: Context-aware routing to skills and hooks management. Use when troubleshooting skill activation, fine-tuning keywords, or managing the automated documentation system.
---

# Skills Manager (Smart Router)

## Purpose
Context-aware routing to skills and hooks management. Helps you troubleshoot, fine-tune, and manage the automated documentation system.

## When Auto-Activated
- Discussing skills activation or hooks
- Creating new skills
- Keywords: skill activation, hook, troubleshoot, fine-tune, keyword, skill-rules.json, create skill, new skill, agentskills
- Debugging why a skill didn't activate or activated incorrectly

## 🚨 CRITICAL RULES

1. **Logs are your friend** - Always check `.claude/logs/skill-activations.log` first
2. **Test after changes** - Always verify modifications to `skill-rules.json` work
3. **Validate JSON** - Use `jq` to validate skill-rules.json before committing
4. **Keywords should be specific** - Too-broad keywords cause false positives

## 📋 Quick Diagnostic Workflow

### Problem: Skill Didn't Activate

1. **Check logs**:
   ```bash
   tail -20 .claude/logs/skill-activations.log
   ```

2. **Check current keywords**:
   ```bash
   cat .claude/hooks/skill-rules.json | jq '.skills."SKILL-NAME".promptTriggers.keywords'
   ```

3. **Add missing keyword**:
   - Ask Claude: "Add 'KEYWORD' to SKILL-NAME"
   - Or edit `.claude/hooks/skill-rules.json` directly

4. **Test**:
   ```bash
   echo '{"prompt":"test prompt"}' | .claude/hooks/skill-activation-prompt.sh
   ```

### Problem: Skill Activated When Shouldn't

1. **Identify the trigger** - Check logs to see which keyword matched

2. **Remove or make more specific**:
   - Remove: "Remove 'text' from localization-developer"
   - Make specific: Replace "text" with "localized text"

3. **Verify**:
   ```bash
   tail .claude/logs/skill-activations.log
   ```

## 🎯 Common Tasks

### Add a Keyword

**Quick**: Ask Claude
```
"Add 'refactoring' to ios-dev-guidelines keywords"
```

**Manual**: Edit `.claude/hooks/skill-rules.json`
```json
"keywords": [
  "swift",
  "refactoring"  // ← Add here
]
```

### Remove a Keyword

**Quick**: Ask Claude
```
"Remove 'text' from localization-developer, it's too broad"
```

**Manual**: Edit and remove from keywords array

### Check What Activated

```bash
tail -20 .claude/logs/skill-activations.log
```

Look for:
```
✓ Matched: skill-name     # ← This skill activated
No matches found          # ← Nothing activated
```

### Test Activation Manually

```bash
echo '{"prompt":"add feature flag"}' | .claude/hooks/skill-activation-prompt.sh
```

Should output skill suggestion if match found.

### Auto-Learning Feature

**What it does**: When a substantial prompt (100+ chars OR 3+ lines) doesn't activate any skills, the system prompts you with available skills and auto-updates keywords based on your feedback.

**Workflow**:
1. You submit a substantial prompt
2. No skills activate
3. System shows: "Should any of these skills be activated?"
4. You respond: "Yes, localization-developer should activate"
5. Claude extracts keywords from your prompt
6. Claude runs: `.claude/hooks/utils/add-keywords-to-skill.sh localization-developer <keywords>`
7. skill-rules.json updated
8. Future similar prompts auto-activate

**Manual keyword extraction**:
```bash
# Test keyword extraction
echo "Update space settings localization for membership tiers" | .claude/hooks/utils/extract-keywords.sh
# Output: membership, settings, localization, tiers, update

# Add keywords manually
.claude/hooks/utils/add-keywords-to-skill.sh localization-developer "membership" "tiers"
```

**Logs**:
- Missed activations: `.claude/logs/skill-activations-missed.log`
- Learning updates: `.claude/logs/skill-learning.log`

## 🔧 The System Components

### Hooks (Automation)

**Location**: `.claude/hooks/`

**What they do**:
- `skill-activation-prompt.sh` - Suggests skills based on your prompt
- `post-tool-use-tracker.sh` - Tracks file edits
- `swiftformat-post-edit.sh` - Auto-formats Swift files immediately after edit
- `notification-alert.sh` - Sends macOS notifications when Claude needs input

### Skills (Routers)

**Location**: `.claude/skills/*/SKILL.md`

**The 7 skills**:
1. `ios-dev-guidelines` - Swift/iOS patterns
2. `localization-developer` - Localization
3. `code-generation-developer` - Feature flags, make generate
4. `design-system-developer` - Icons, typography, colors
5. `skills-manager` - This skill (meta!)
6. `code-review-developer` - Code review standards
7. `feature-toggle-developer` - Feature toggle removal, cleanup detection

### Configuration

**Location**: `.claude/hooks/skill-rules.json`

**What it contains**:
- Keywords for each skill
- Intent patterns (regex)
- File path patterns
- Priority settings

## 📊 Configuration Structure

```json
{
  "skills": {
    "skill-name": {
      "type": "domain",
      "priority": "high",  // or "medium", "low"
      "description": "Smart router to...",
      "promptTriggers": {
        "keywords": ["keyword1", "keyword2"],
        "intentPatterns": ["(create|add).*?something"]
      },
      "fileTriggers": {
        "pathPatterns": ["**/*.swift"],
        "contentPatterns": ["SomePattern"]
      }
    }
  },
  "config": {
    "maxSkillsPerPrompt": 2,
    "logActivations": true
  }
}
```

## 📝 Creating New Skills (agentskills.io Spec)

Skills must follow the [agentskills.io specification](https://agentskills.io/specification).

### Required SKILL.md Format

Every skill must start with YAML frontmatter:

```yaml
---
name: skill-name
description: What this skill does and when to use it (max 1024 chars).
---

# Skill Title

## Purpose
...
```

### Name Field Rules

- **1-64 characters**
- **Lowercase only**: `a-z`, `0-9`, `-`
- **No start/end hyphens**: `skill-name` ✅, `-skill-` ❌
- **No consecutive hyphens**: `my-skill` ✅, `my--skill` ❌
- **Must match directory name**: `skills/my-skill/SKILL.md` → `name: my-skill`

### Description Field

- **1-1024 characters**
- **Must describe**: What it does AND when to use it
- **Include keywords** that help agents identify relevant tasks

**Good example**:
```yaml
description: Context-aware routing to the iOS localization system. Use when working with .xcstrings files, Loc constants, or user-facing text.
```

### Optional Frontmatter Fields

```yaml
---
name: skill-name
description: Required description.
license: MIT
compatibility: Designed for Claude Code
metadata:
  author: anytype
  version: "1.0"
---
```

### Directory Structure

```
skill-name/
├── SKILL.md          # Required - main skill file
├── scripts/          # Optional - executable scripts
├── references/       # Optional - additional docs
└── assets/           # Optional - templates, images
```

### Quick Checklist for New Skills

- [ ] Directory name matches `name` field
- [ ] YAML frontmatter with `name` and `description`
- [ ] Name is lowercase with hyphens only
- [ ] Description explains what AND when
- [ ] SKILL.md under 500 lines (use references/ for details)
- [ ] Added to `skill-rules.json` with keywords
- [ ] Tested activation with sample prompts

## ⚠️ Common Issues

### Hook Not Executing

**Symptom**: No activation messages, empty logs

**Fix**:
```bash
# Make hooks executable
chmod +x .claude/hooks/*.sh

# Verify
ls -l .claude/hooks/*.sh  # Should show rwx
```

### Invalid JSON

**Symptom**: Hook fails silently

**Fix**:
```bash
# Validate
jq . .claude/hooks/skill-rules.json

# If error, ask Claude to fix it
```

### Too Many False Positives

**Symptom**: Skill activates too often

**Fix**: Make keywords more specific
- ❌ "text" → activates for everything
- ✅ "localized text" → more specific

## 📚 Complete Documentation

**Full Guide**: `.claude/SKILLS_MANAGEMENT_GUIDE.md`

For comprehensive coverage of:
- Detailed troubleshooting workflows
- Advanced regex patterns for intent matching
- Creating new skills from scratch
- Monitoring and maintenance
- Log rotation and cleanup
- Complete skill-rules.json reference
- Examples for every scenario

## ✅ Health Check Commands

```bash
# Check hook permissions
ls -l .claude/hooks/*.sh

# Validate configuration
jq . .claude/hooks/skill-rules.json

# View recent activations
tail -20 .claude/logs/skill-activations.log

# Count activations by skill
grep "Matched:" .claude/logs/skill-activations.log | sort | uniq -c

# Test specific prompt
echo '{"prompt":"your test"}' | .claude/hooks/skill-activation-prompt.sh
```

## 💡 Pro Tips

1. **Ask Claude to check logs** - "Check the logs for my last prompt"
2. **Use logs for tuning** - Review regularly to spot patterns
3. **Start broad** - Add broad keywords, narrow if too many false positives
4. **Test everything** - Always test after modifying skill-rules.json
5. **Document changes** - Add comments in skill-rules.json

## 🔗 Related Docs

- `.claude/hooks/README.md` - Complete hooks documentation
- `.claude/skills/README.md` - Skills system overview
- `CLAUDE.md` - Main documentation

---

**Navigation**: This is a smart router. For deep troubleshooting and management details, always refer to `SKILLS_MANAGEMENT_GUIDE.md`.

**Quick help**: Just ask "Check skills system health" or "Why didn't X skill activate?"
