# Linear CLI Developer (Smart Router)

## Purpose
Context-aware routing to Linear issue tracking using `linctl` CLI. Replaces Linear MCP tools with faster, more reliable command-line operations.

**Reference Repository**: https://github.com/dorkitude/linctl

## When Auto-Activated
- Working with Linear issues, projects, or releases
- Keywords: linear, issue, linctl, IOS-XXXX, release task, sprint, cycle

## Why linctl Over MCP?
- **More reliable**: Direct CLI calls vs MCP server communication
- **Less context**: Simpler command syntax vs verbose MCP tool definitions
- **Faster**: No MCP overhead
- **Agent-optimized**: Built specifically for AI agents with `--json` output

## Installation
```bash
brew tap dorkitude/linctl
brew install linctl
linctl auth  # Interactive authentication
```

## Critical Rules

1. **Always use `--json` flag** for structured output parsing
2. **Use issue identifiers** (IOS-XXXX) not UUIDs for user-facing references
3. **Default filters exclude old/completed items** - use `--newer-than all_time` and `--include-completed` when needed
4. **Limit results** - Default is 50, use `--limit` for large datasets

## Quick Reference

### Issue Commands
| Task | Command |
|------|---------|
| Get issue details | `linctl issue get IOS-1234 --json` |
| List my issues | `linctl issue list --assignee me --json` |
| List team issues | `linctl issue list --team iOS --json` |
| Search issues | `linctl issue search "query" --json` |
| Create issue | `linctl issue create --title "Title" --team iOS --json` |
| Update issue | `linctl issue update IOS-1234 --state "Done" --json` |
| Assign to self | `linctl issue assign IOS-1234` |

### Project Commands
| Task | Command |
|------|---------|
| List projects | `linctl project list --json` |
| Get project | `linctl project get <project-id> --json` |
| Filter by team | `linctl project list --team iOS --json` |

### Team Commands
| Task | Command |
|------|---------|
| List teams | `linctl team list --json` |
| Get team | `linctl team get iOS --json` |
| Team members | `linctl team members iOS --json` |

### User Commands
| Task | Command |
|------|---------|
| Current user | `linctl whoami --json` |
| List users | `linctl user list --json` |
| Get user | `linctl user get email@example.com --json` |

### Comment Commands
| Task | Command |
|------|---------|
| List comments | `linctl comment list IOS-1234 --json` |
| Add comment | `linctl comment create IOS-1234 --body "Comment text"` |

### Cycle Commands
| Task | Command |
|------|---------|
| Current cycle | `linctl cycle list --team iOS --type current --json` |

## Common Workflows

### Get Branch Name for Task
```bash
# Instead of: mcp__linear-server__list_issues(query: "IOS-1234")
linctl issue get IOS-1234 --json | jq -r '.gitBranchName'
```

### Release Task Hierarchy (for /impact_linear)
```bash
# Step 1: Get release task
linctl issue get IOS-5467 --json

# Step 2: Get subtasks (need UUID from step 1)
linctl issue list --parent-id <uuid> --json --include-completed

# Step 3: Get epic subtasks (repeat for each epic UUID)
linctl issue list --parent-id <epic-uuid> --json --include-completed
```

### List All Issues for Sprint
```bash
linctl issue list --team iOS --cycle current --json
```

### Filter by State
```bash
linctl issue list --state "In Progress" --json
linctl issue list --state "Done" --include-completed --json
```

## MCP to linctl Migration Table

| MCP Tool | linctl Equivalent |
|----------|-------------------|
| `mcp__linear-server__get_issue(id)` | `linctl issue get <id> --json` |
| `mcp__linear-server__list_issues(...)` | `linctl issue list [filters] --json` |
| `mcp__linear-server__create_issue(...)` | `linctl issue create [options]` |
| `mcp__linear-server__update_issue(...)` | `linctl issue update <id> [options]` |
| `mcp__linear-server__list_comments(issueId)` | `linctl comment list <id> --json` |
| `mcp__linear-server__create_comment(...)` | `linctl comment create <id> --body "..."` |
| `mcp__linear-server__list_teams` | `linctl team list --json` |
| `mcp__linear-server__get_team(query)` | `linctl team get <key> --json` |
| `mcp__linear-server__list_projects` | `linctl project list --json` |
| `mcp__linear-server__get_project(query)` | `linctl project get <id> --json` |
| `mcp__linear-server__list_users` | `linctl user list --json` |
| `mcp__linear-server__get_user(query)` | `linctl user get <email> --json` |
| `mcp__linear-server__list_cycles(...)` | `linctl cycle list --team <key> --json` |

## Priority Values
| Priority | Name |
|----------|------|
| 0 | None |
| 1 | Urgent |
| 2 | High |
| 3 | Normal (default) |
| 4 | Low |

## Time Filters (`--newer-than`)
- `all_time` - No filter
- `6_months_ago` - Default
- `1_month_ago`
- `1_week_ago`
- ISO-8601 dates

## Output Formats
- `--json` - Structured JSON (recommended for agents)
- `--plaintext` - Markdown formatted
- Default: Table format

## Common Mistakes

### Forgetting --json
```bash
# Wrong - table output, hard to parse
linctl issue get IOS-1234

# Correct - structured JSON
linctl issue get IOS-1234 --json
```

### Missing --include-completed
```bash
# Wrong - misses completed/canceled items
linctl issue list --newer-than all_time --json

# Correct - includes all states
linctl issue list --newer-than all_time --include-completed --json
```

### Using UUID in User-Facing Output
```bash
# Wrong - UUIDs are internal
"Task: cab796c7-b58d-4876-b1a4-cc9f39da1431"

# Correct - identifiers are readable
"Task: IOS-5467"
```

## Related Skills & Docs

- **cpp** → Uses Linear for branch names
- **impact_linear** → Uses Linear for release context gathering
- **designReview** → Uses Linear for issue context

---

**Navigation**: This is a smart router. For CLI details, see: https://github.com/dorkitude/linctl
