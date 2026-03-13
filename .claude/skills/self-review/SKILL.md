---
name: self-review
description: Agent self-reviews its own diff against TASTE_INVARIANTS.md before presenting to user. Catches mechanical violations early.
---

# Self-Review Skill

## Purpose
Verify your own code changes against `TASTE_INVARIANTS.md` before presenting them to the user. Catch mechanical violations before they reach human review.

## When to Use
- After completing any code implementation
- Before suggesting changes are ready
- When the `simplify` skill activates (complements it)

## Workflow

### Step 1: Gather Your Changes
Identify all files you modified or created in this session.

### Step 2: Run Invariant Checks
For each modified `.swift` file, check against `TASTE_INVARIANTS.md`:

```bash
# Check for deprecated APIs in changed files
rg '\.foregroundColor\(' <file>
rg '\.cornerRadius\(' <file>
rg 'NavigationView' <file>

# Check for plain Text (excluding AnytypeText)
rg '[^a-zA-Z]Text\(' <file> | grep -v AnytypeText | grep -v searchable | grep -v navigationTitle

# Check for hardcoded strings in UI
rg '(Text|AnytypeText)\("[^"]*"\)' <file> | grep -v 'Loc\.'

# Check for hardcoded colors
rg 'Color\(red:|UIColor\(red:|#[0-9a-fA-F]{6}' <file>

# Check for force unwraps (rough)
rg '!\.' <file> | grep -v '//' | grep -v 'test'

# Check for print statements
rg 'print\(' <file>

# Check for String(format: Loc.)
rg 'String\(format: Loc\.' <file>

# Check for Group with lifecycle modifiers
rg -A5 'Group\s*\{' <file> | rg '\.onAppear|\.task'
```

### Step 3: Check Refactoring Completeness
If you renamed anything:
```bash
rg "oldName" --type swift
```
Ensure 0 results outside generated files.

### Step 4: Report
- If violations found: fix them before presenting to user
- If clean: proceed silently (don't announce the self-review)
- If uncertain about an exception: note it to the user

## Key Principle
> "When the agent struggles, the fix is never 'try harder' — it's 'what capability is missing?'"
>
> If you keep violating the same invariant, add better tooling or documentation, not more willpower.

## Related
- `TASTE_INVARIANTS.md` — the source of truth for mechanical rules
- `code-review-developer` — for reviewing others' code
- `simplify` — for code quality improvements
