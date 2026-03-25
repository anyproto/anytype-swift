---
name: decompose
description: Decompose a large Linear task into independent subtasks with a master plan. Analyzes issue, project, related tasks, PRs, and codebase to create PLAN.md and Linear sub-issues.
---

# Task Decomposition (Workflow)

## Purpose

Break down a large feature/task into independent, implementable subtasks. Produces a `PLAN_IOS_XXXX.md` at repo root and creates Linear sub-issues — all designed so future Claude sessions can pick up any subtask with full context.

## When Auto-Activated

- User shares a Linear issue URL and asks to decompose/break down/split
- Keywords: decompose, decomposition, break down, split task, subtasks, plan feature

## Workflow

### Phase 1: Gather Context (parallel)

Collect ALL of the following before proposing anything:

1. **Parent Linear issue** — read via `mcp__linear-server__get_issue` (with `includeRelations: true`)
2. **Linear project** — read via `mcp__linear-server__get_project` if projectId exists
3. **Related issues** — especially middleware/backend tasks (GO-XXXX). Read each to understand what APIs/commands are available
4. **Comments on the issue** — `mcp__linear-server__list_comments` for team discussion and decisions
5. **Existing PRs/branches** — check `gh pr list` and `git branch -a` for work already started
6. **Codebase exploration** — use Agent(Explore) to understand current implementation of the area being changed. Focus on:
   - Entry points (coordinators, views, view models)
   - Service layer (middleware calls, RPC commands)
   - Data models (structs, enums, protobuf types)
   - Existing patterns to follow

### Phase 2: Propose Decomposition

Present the decomposition to the user as a numbered list organized in **dependency layers**:

```
### Layer 0: Foundation (no dependencies)
1. Task A — brief description
2. Task B — brief description

### Layer 1: Components (depends on Layer 0)
3. Task C — brief description. Depends on: #1
4. Task D — brief description. Depends on: #2

### Layer 2: Integration (depends on Layer 1)
...
```

**Decomposition principles:**
- Each subtask must be independently implementable and testable
- Each subtask gets its own branch and PR
- Subtasks in the same layer can be done in parallel
- Dependencies flow downward only (Layer N depends on Layer N-1 or earlier)
- Prefer small, focused subtasks over large ones
- Separate middleware integration from UI work
- Separate reusable components from flow orchestration
- Edge cases and polish go in the last layer

**Include with the proposal:**
- Dependency graph (ASCII art)
- What can be parallelized
- Comparison with user's decomposition (if they provided one)

**Wait for user approval before proceeding to Phase 3.**

### Phase 3: Create Artifacts (after approval)

#### 3a. Create PLAN_IOS_XXXX.md

Create at **repo root** with this structure:

```markdown
# IOS-XXXX: Feature Title

## Overview
What the feature does, why, key concepts. 2-3 paragraphs max.

**Linear**: <link>
**Feature Toggle**: `toggleName`

## Key Concepts
Bullet list of domain terms and what they mean in this context.

## Middleware Commands
Table of RPC commands used by this feature.

## Flows
ASCII diagrams of user flows.

## Design Links
Figma URLs from the issue.

---

## Decomposition & Progress

### Layer N: Layer Name

#### X. Subtask Title — [IOS-YYYY](link)
- [ ] Checklist item 1
- [ ] Checklist item 2
- **Depends on**: #N (if any)
- **Branch**: `ios-YYYY-branch-name`
- **Status**: Not started

---

## Current Codebase Reference
Key files, models, services relevant to this feature.
Where things currently live. Entry points.
```

**The plan must contain enough context that a fresh Claude session can:**
- Understand the full feature scope
- Know which middleware commands to use
- Know which files to modify
- Understand how subtasks connect
- Track progress across sessions

#### 3b. Create Linear Sub-Issues

For each subtask, create a Linear issue with:
- **Title**: Concise, action-oriented
- **Parent**: The original issue ID
- **Assignee**: Same as parent (use `me`)
- **Project**: Same as parent
- **Team**: Same as parent
- **Priority**: High for foundation (Layer 0), Medium for others, Low for polish
- **Description**: Self-contained with:

```markdown
## Summary
One paragraph: what this subtask does.

## What to do
Concrete steps, key files, implementation hints.
Reference specific middleware commands, models, existing code.

### Dependencies
Which subtasks must be done first.

### Acceptance Criteria
- [ ] Criteria 1
- [ ] Criteria 2
```

**Each subtask description must be self-contained** — a fresh Claude session should be able to work on it by reading only:
1. `PLAN_IOS_XXXX.md` (full context)
2. The Linear sub-issue (specific instructions)

#### 3c. Update Memory

Save a project memory entry so future sessions know this decomposition exists:
- What the feature is
- How many subtasks
- Where the plan lives
- Key architectural decisions

### Phase 4: Commit

Commit `PLAN_IOS_XXXX.md` to the parent feature branch. Ask user before committing.

## Working on Subtasks (Future Sessions)

When starting a subtask in a new session:
1. Read `PLAN_IOS_XXXX.md` — full feature context + progress
2. Read Linear sub-issue — specific instructions
3. Checkout subtask branch from `origin/develop`
4. Implement
5. After PR merge, update PLAN.md status in the parent branch

## Common Mistakes

- **Starting Phase 3 without approval** — Always wait for user to confirm decomposition
- **Subtasks that are too coupled** — If subtask B can't be tested without subtask A being merged, reconsider the split
- **Missing middleware context** — Always read related GO-XXXX issues to understand available APIs
- **Vague subtask descriptions** — Each must be specific enough to implement without guessing
- **Forgetting to check existing work** — PRs/branches may already cover parts of the task
