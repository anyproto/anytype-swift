# Claude Code Hooks System

Automated hooks for the Anytype iOS project that enhance Claude Code's capabilities with skill auto-activation, tool tracking, and code formatting.

## Overview

Hooks are shell scripts that run at specific points during Claude Code execution:
- **UserPromptSubmit**: Before Claude sees your message
- **PostToolUse**: After Claude uses a tool (Edit, Write, etc.)
- **Stop**: After Claude finishes responding

These hooks enable:
- Automatic skill suggestions
- Tool usage logging
- Automatic Swift code formatting
- Real-time monitoring

## 🪝 Installed Hooks

### 1. skill-activation-prompt.sh (UserPromptSubmit)

**Purpose**: Automatically suggest relevant skills based on prompt and context

**Event**: `UserPromptSubmit` (before Claude sees your message)

**What it does**:
1. Analyzes your prompt for keywords (e.g., "swift", "localization", "icon")
2. Checks file paths if you're editing files
3. Matches against patterns in `skill-rules.json`
4. Injects skill suggestions into Claude's context

**Example Output**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 SKILL ACTIVATION CHECK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📚 Relevant Skill: ios-dev-guidelines
   Description: Swift/iOS development patterns...

💡 Consider using these skills if relevant to this task.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**Logs**: `.claude/logs/skill-activations.log`

**Configuration**: `.claude/hooks/skill-rules.json`

---

### 2. post-tool-use-tracker.sh (PostToolUse)

**Purpose**: Track all file modifications for monitoring and debugging

**Event**: `PostToolUse` (after Edit/Write/MultiEdit/NotebookEdit)

**What it does**:
1. Logs which files were edited with timestamps
2. Categorizes by codebase area (UI/Presentation, Services, Models, etc.)
3. Creates detailed usage log for debugging
4. Enables other hooks to know what was modified

**Example Log Entry**:
```
[2025-01-30 14:23:45] Edit: Anytype/Sources/PresentationLayer/ChatView.swift
  └─ Area: UI/Presentation, File: Anytype/Sources/PresentationLayer/ChatView.swift
```

**Logs**: `.claude/logs/tool-usage.log`

---

### 3. swiftformat-auto.sh (Stop)

**Purpose**: Automatically format Swift files after Claude finishes

**Event**: `Stop` (after Claude finishes responding)

**What it does**:
1. Reads recently edited Swift files from tool-usage.log
2. Runs SwiftFormat on each file
3. Logs formatting results
4. Displays summary with token usage warning

**⚠️ Token Usage Warning**:

File modifications trigger `<system-reminder>` notifications that consume context tokens. Based on research from the showcase repository:
- Large files with many changes = more tokens consumed
- Strict formatting rules = more changes = more tokens
- Each change generates a system-reminder with full diff

**Enabled by default**: `ENABLED=true` (can be disabled in script)

**To disable**:
```bash
# Edit the script
vim .claude/hooks/swiftformat-auto.sh

# Change line:
ENABLED=false  # Set to false
```

**Or rename to disable**:
```bash
mv .claude/hooks/swiftformat-auto.sh .claude/hooks/swiftformat-auto.sh.disabled
```

**Logs**: `.claude/logs/swiftformat.log`

**Example Output**:
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✨ SwiftFormat Auto-Formatter
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Automatically formatted 3 Swift file(s)

⚠️  Note: File formatting consumes context tokens...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 📂 Directory Structure

```
.claude/hooks/
├── README.md (this file)
├── skill-rules.json              # Skill activation configuration
├── skill-activation-prompt.sh    # UserPromptSubmit hook
├── post-tool-use-tracker.sh      # PostToolUse hook
└── swiftformat-auto.sh           # Stop hook

.claude/logs/                      # Generated logs (gitignored)
├── skill-activations.log
├── tool-usage.log
└── swiftformat.log
```

## ⚙️ Configuration

### skill-rules.json

Defines which skills activate for which patterns:

```json
{
  "skills": {
    "ios-dev-guidelines": {
      "type": "domain",
      "priority": "high",
      "description": "Swift/iOS development patterns...",
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
    },
    ...
  },
  "config": {
    "maxSkillsPerPrompt": 2,
    "logActivations": true,
    "logPath": ".claude/logs/skill-activations.log"
  }
}
```

**Key Fields**:
- `keywords`: Terms that trigger skill suggestion
- `intentPatterns`: Regex for action patterns
- `pathPatterns`: File paths that activate skill
- `contentPatterns`: Code patterns to match
- `maxSkillsPerPrompt`: Limit suggestions (default: 2)

### Hook Configuration

Each hook script has configuration at the top:

**skill-activation-prompt.sh**:
```bash
# Paths
SKILL_RULES="$SCRIPT_DIR/skill-rules.json"
LOG_FILE="$LOG_DIR/skill-activations.log"
```

**swiftformat-auto.sh**:
```bash
# Configuration
ENABLED=true  # Set to false to disable
```

## 🔍 Monitoring & Debugging

### View Activation Logs

```bash
# Skill activations
tail -f .claude/logs/skill-activations.log

# Tool usage
tail -f .claude/logs/tool-usage.log

# SwiftFormat results
tail -f .claude/logs/swiftformat.log
```

### Check Hook Execution

```bash
# List hooks
ls -lh .claude/hooks/*.sh

# Verify executability
ls -l .claude/hooks/*.sh | grep -E "^-rwx"
```

### Test Hook Manually

```bash
# Test skill-activation-prompt
echo '{"prompt":"add a feature flag for chat"}' | .claude/hooks/skill-activation-prompt.sh

# Should output skill suggestion
```

## 🚀 Hook Lifecycle

### UserPromptSubmit Flow

```
User types prompt
       ↓
Claude Code calls hook
       ↓
skill-activation-prompt.sh runs
       ↓
Analyzes prompt + files
       ↓
Matches against skill-rules.json
       ↓
Outputs skill suggestions
       ↓
Claude sees prompt + suggestions
```

### PostToolUse Flow

```
Claude uses Edit/Write
       ↓
Tool completes
       ↓
post-tool-use-tracker.sh runs
       ↓
Logs file path + timestamp
       ↓
Categorizes by codebase area
       ↓
Updates tool-usage.log
```

### Stop Flow

```
Claude finishes response
       ↓
swiftformat-auto.sh runs
       ↓
Reads recently edited Swift files
       ↓
Runs SwiftFormat on each
       ↓
Logs results to swiftformat.log
       ↓
Displays summary to user
```

## 🛠️ Managing Hooks

### Enabling/Disabling Hooks

**To disable a hook temporarily**:
```bash
# Rename with .disabled extension
mv .claude/hooks/swiftformat-auto.sh .claude/hooks/swiftformat-auto.sh.disabled
```

**To re-enable**:
```bash
mv .claude/hooks/swiftformat-auto.sh.disabled .claude/hooks/swiftformat-auto.sh
```

**To disable via configuration** (swiftformat-auto.sh only):
```bash
# Edit the script
vim .claude/hooks/swiftformat-auto.sh

# Change ENABLED=true to ENABLED=false
```

### Adding New Hooks

1. **Create hook script**:
```bash
touch .claude/hooks/my-new-hook.sh
chmod +x .claude/hooks/my-new-hook.sh
```

2. **Add shebang and setup**:
```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
mkdir -p "$LOG_DIR"
```

3. **Read event data**:
```bash
EVENT_DATA=$(cat)
# Parse JSON with jq
```

4. **Implement logic**:
```bash
# Your hook logic here
echo "Hook executed successfully"
```

5. **Test**:
```bash
echo '{"test":"data"}' | .claude/hooks/my-new-hook.sh
```

## ⚠️ Important Warnings

### Token Usage with SwiftFormat

**From Research** (showcase repository + community feedback):

File formatting can consume significant context tokens:
- Each file change triggers a `<system-reminder>`
- System-reminders include full file diffs
- Can consume 160k+ tokens in 3 rounds for large files with strict formatting

**Recommendation**:
- Monitor your context usage
- Disable swiftformat-auto.sh if context depletes too quickly
- Alternative: Run SwiftFormat manually between Claude sessions

**How to check token usage**:
- Watch the context indicator in Claude Code
- Review system-reminders in conversation
- Check if context auto-compacts frequently

**If problematic**:
```bash
# Disable SwiftFormat hook
mv .claude/hooks/swiftformat-auto.sh .claude/hooks/swiftformat-auto.sh.disabled
```

### Hook Failures

If a hook fails:
1. Check logs for error messages
2. Test hook manually with sample input
3. Verify jq is installed (required for JSON parsing)
4. Check file permissions (should be executable)
5. Look for syntax errors in shell script

## 📊 Log Management

### Log Rotation

Logs can grow large over time. Rotate them periodically:

```bash
# Archive old logs
cd .claude/logs
tar -czf logs-$(date +%Y%m%d).tar.gz *.log
rm *.log
```

### Clear Logs

```bash
# Clear all logs
rm .claude/logs/*.log

# Or truncate without deleting
truncate -s 0 .claude/logs/*.log
```

### Git Ignore

Logs are gitignored by default (`.claude/logs/.gitignore`):
```
*.log
!.gitignore
```

## 🔧 Troubleshooting

### Hook Not Running

**Problem**: Hook doesn't seem to execute

**Solutions**:
1. Verify hook is executable:
   ```bash
   chmod +x .claude/hooks/skill-activation-prompt.sh
   ```

2. Check for syntax errors:
   ```bash
   bash -n .claude/hooks/skill-activation-prompt.sh
   ```

3. Test manually:
   ```bash
   echo '{"prompt":"test"}' | .claude/hooks/skill-activation-prompt.sh
   ```

### Skills Not Activating

**Problem**: No skill suggestions appear

**Solutions**:
1. Check activation log:
   ```bash
   tail .claude/logs/skill-activations.log
   ```

2. Verify skill-rules.json is valid:
   ```bash
   jq . .claude/hooks/skill-rules.json
   ```

3. Use more specific keywords in prompts

### SwiftFormat Not Running

**Problem**: Swift files not being formatted

**Solutions**:
1. Verify SwiftFormat is installed:
   ```bash
   which swiftformat
   ```

2. Install if missing:
   ```bash
   brew install swiftformat
   ```

3. Check if hook is enabled:
   ```bash
   grep "ENABLED" .claude/hooks/swiftformat-auto.sh
   ```

4. Check logs:
   ```bash
   tail .claude/logs/swiftformat.log
   ```

## 📚 Related Documentation

- **Skills System**: `.claude/skills/README.md` - What skills are available
- **Showcase Repository**: https://github.com/diet103/claude-code-infrastructure-showcase - Original inspiration
- **CLAUDE.md**: Main project documentation

## 🎓 Best Practices

### For Hook Usage

1. **Monitor logs regularly** - Check for errors and unusual patterns
2. **Keep skill-rules.json updated** - Add keywords as you discover them
3. **Watch token usage** - Disable SwiftFormat if context consumption is high
4. **Test hooks after updates** - Verify they still work correctly
5. **Keep hooks simple** - Complex logic should be in skills, not hooks

### For Hook Development

1. **Use set -euo pipefail** - Catch errors early
2. **Log extensively** - Makes debugging easier
3. **Handle edge cases** - Check for missing files, invalid JSON, etc.
4. **Test with sample data** - Don't just test in live Claude sessions
5. **Document configuration** - Explain what each setting does

## 📖 Hook Template

When creating a new hook:

```bash
#!/bin/bash

# [Hook Name] - [Description]
# Event: [UserPromptSubmit/PostToolUse/Stop]
# Purpose: [What this hook does]

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="$SCRIPT_DIR/../logs"
LOG_FILE="$LOG_DIR/my-hook.log"

# Ensure log directory exists
mkdir -p "$LOG_DIR"

# Read event data from stdin
EVENT_DATA=$(cat)

# Parse event data
FIELD=$(echo "$EVENT_DATA" | jq -r '.field // empty')

# Exit if no data
if [ -z "$FIELD" ]; then
    exit 0
fi

# Log activity
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Hook executed" >> "$LOG_FILE"

# Your logic here
# ...

# Output to Claude (if UserPromptSubmit hook)
# echo "Your message to Claude"

exit 0
```

## Summary

The hooks system provides:
- ✅ **Automatic skill activation** - No manual skill loading needed
- ✅ **Tool usage tracking** - Know what files were modified
- ✅ **Code formatting** - Keep Swift files formatted (with token awareness)
- ✅ **Comprehensive logging** - Debug issues and monitor activity
- ✅ **Easy configuration** - skill-rules.json for fine-tuning

**Usage**: Hooks run automatically - you don't need to do anything. Just monitor logs and adjust configuration as needed.